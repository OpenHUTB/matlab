classdef tunableParameterAssociateVarDDG < handle
properties 
m_ParentMaskDlgTag = '';
m_ParameterName = '';
m_VariableName = '';
m_VariableValue = '';
m_ModelName = '';
m_BlockName = '';
m_DialogTag = '';
m_modelCloseListener = [  ];
end 
methods 
function schema = getDialogSchema( obj )
varName.Type = 'edit';
varName.Name = DAStudio.message( 'Simulink:dialog:AssociatedVariableName' );
varName.Tag = 'associatedVarEdit';
varName.Value = obj.m_VariableName;
varName.RowSpan = [ 1, 1 ];
varName.ColSpan = [ 1, 1 ];

clearButton.Type = 'pushbutton';
clearButton.Name = DAStudio.message( 'Simulink:dialog:AssociatedVariableClear' );
clearButton.Tag = 'clearButton';
clearButton.RowSpan = [ 1, 1 ];
clearButton.ColSpan = [ 2, 2 ];
clearButton.MatlabMethod = 'tunableParameterAssociateVarDDG.clearButtonCB';
clearButton.MatlabArgs = { '%dialog', varName.Tag };

varNameClearButtonPanel.Type = 'panel';
varNameClearButtonPanel.LayoutGrid = [ 1, 2 ];
varNameClearButtonPanel.Items = { varName, clearButton };

variableValue.Type = 'edit';
variableValue.Name = DAStudio.message( 'Simulink:dialog:AssociatedVariableValue' );
variableValue.Tag = 'variableValue';
variableValue.Value = obj.m_VariableValue;
variableValue.Enabled = 0;
variableValue.RowSpan = [ 1, 1 ];
variableValue.ColSpan = [ 1, 2 ];

Location.Type = 'combobox';
Location.Name = DAStudio.message( 'Simulink:dialog:AssociatedVariableLocation' );
Location.Tag = 'location';
entries = { DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Base' ), DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Model' ) };
dataDictionaryName = get_param( obj.m_ModelName, 'DataDictionary' );

if ~isempty( dataDictionaryName )
ddConn = Simulink.dd.open( dataDictionaryName );
ddRefList = {  };
if ( ~isempty( ddConn.Dependencies ) )
dependencies = ddConn.DependencyClosure;
for idx = 2:length( dependencies )
[ ~, ddRefName, fileExt ] = fileparts( dependencies{ idx } );
ddRefList = [ ddRefList, { [ ddRefName, fileExt ] } ];
end 
end 
dataDictionaryName = [ DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Dictionary' ), ' (', dataDictionaryName, ')' ];
entries = [ entries, dataDictionaryName ];
ddRefList = sort( ddRefList );
if ~isempty( ddRefList )
entries = [ entries, ddRefList{ : } ];
end 
end 

Location.Entries = entries;
Location.RowSpan = [ 2, 2 ];
Location.ColSpan = [ 1, 1 ];

createButton.Type = 'pushbutton';
createButton.Name = DAStudio.message( 'Simulink:dialog:AssociatedVariableCreate' );
createButton.RowSpan = [ 2, 2 ];
createButton.ColSpan = [ 2, 2 ];
createButton.MatlabMethod = 'tunableParameterAssociateVarDDG.createButtonCB';
createButton.MatlabArgs = { '%source', '%dialog', Location.Tag, varName.Tag, variableValue.Tag };


createVarTogglePanel.Type = 'togglepanel';
createVarTogglePanel.Name = DAStudio.message( 'Simulink:dialog:AssociatedVariableCreateGroup' );
createVarTogglePanel.LayoutGrid = [ 1, 3 ];
createVarTogglePanel.Items = { variableValue, Location, createButton };

containerGroup.Type = 'group';
containerGroup.Name = DAStudio.message( 'Simulink:dialog:AssociatedVariableGroup' );
containerGroup.Items = { varNameClearButtonPanel, createVarTogglePanel };

schema.DialogTitle = DAStudio.message( 'Simulink:dialog:AssociatedVariableDilaogTitle' );
schema.DialogTag = obj.m_DialogTag;
schema.Items = { containerGroup };
schema.PreApplyCallback = 'preApplyCB';
schema.PreApplyArgs = { '%source', '%dialog', varName.Tag, variableValue.Tag };
schema.HelpMethod = 'helpview';
schema.HelpArgs = { fullfile( docroot, '/mapfiles/simulink.map' ), 'TunableMaskPopupParameterExample-6' };
end 

function obj = tunableParameterAssociateVarDDG( dilaogTag, parameterName, variableName, variableValue, modelName, blockName )
obj.m_ParameterName = parameterName;
obj.m_ParentMaskDlgTag = dilaogTag;
obj.m_VariableName = variableName;
obj.m_VariableValue = variableValue;
obj.m_ModelName = modelName;
obj.m_BlockName = blockName;
obj.m_DialogTag = [ 'tunableParameterAssociateVarDDG', '_', blockName, '_', parameterName ];
oModel = get_param( modelName, 'Object' );
obj.m_modelCloseListener = Simulink.listener( oModel, 'CloseEvent',  ...
@( src, eventData )obj.modelCloseListener( src, eventData, obj ) );
end 

function [ isValid, msg ] = preApplyCB( source, dlgHandle, varNameTag, varValueTag )

dialogs = DAStudio.ToolRoot.getOpenDialogs.find( 'dialogTag', source.m_ParentMaskDlgTag );
if ( ~isempty( dialogs ) )
associatedVarName = dlgHandle.getWidgetValue( varNameTag );
if isvarname( associatedVarName )
value = [  ];
if ~isempty( associatedVarName )
try 
value = slResolve( associatedVarName, source.m_BlockName );
catch 
end 
end 

if ~isempty( value )
varValue = dlgHandle.getWidgetValue( varValueTag );
enumName = extractBefore( varValue, '.' );
if ~isempty( enumName ) && isa( value, enumName )
index = find( ( enumeration( enumName ) == value ), 1 );
if ~isempty( index )
set_param( source.m_BlockName, source.m_ParameterName, index - 1 );
end 
end 
end 
else 
if ~isempty( associatedVarName )
isValid = false;
msg = DAStudio.message( 'Simulink:dialog:InvalidVarMustBeMatVar', associatedVarName );
return ;
end 
end 
associatedVarTag = [ source.m_ParameterName, '_Value' ];
associatedVarConnector = [ source.m_ParameterName, '_Connector' ];
associatedVarStateInMainDialog = ~isempty( associatedVarName );

for i = 1:length( dialogs )
dialog = dialogs( i );
dialog.setEnabled( associatedVarTag, false );
dialog.setVisible( associatedVarTag, associatedVarStateInMainDialog );
dialog.setVisible( associatedVarConnector, associatedVarStateInMainDialog );
dialog.setWidgetValue( associatedVarTag, associatedVarName );
dialog.enableApplyButton( true )
end 
end 

isValid = true;
msg = '';
end 
end 

methods ( Static, Access = public )

function obj = instatiateObject( dialogTag, parameterName, variableName, variableValue, modelName, blockName )
obj = tunableParameterAssociateVarDDG( dialogTag, parameterName, variableName, variableValue, modelName, blockName );
end 

function createButtonCB( source, dlgHandle, workspaceNameTag, varNameTag, varValueTag )
varname = dlgHandle.getWidgetValue( varNameTag );
varValueStr = dlgHandle.getWidgetValue( varValueTag );
varValue = eval( varValueStr );
locationTxt = dlgHandle.getComboBoxText( workspaceNameTag );
if strcmpi( locationTxt, DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Base' ) )
assignin( 'base', varname, varValue );
elseif strcmpi( locationTxt, DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Model' ) )
modelWS = get_param( source.m_ModelName, 'ModelWorkspace' );
assignin( modelWS, varname, varValue );
elseif contains( locationTxt, '.sldd' )
dataDictName = get_param( source.m_ModelName, 'DataDictionary' );
if ~contains( locationTxt, dataDictName )
dataDictName = locationTxt;
end 
if ~isempty( dataDictName )
dd = Simulink.dd.open( dataDictName );
if dd.entryExists( [ 'Global.', varname ], false )
dd.setEntry( [ 'Global.', varname ], varValue );
else 
dd.insertEntry( 'Global', varname, varValue );
end 
end 
end 
end 

function clearButtonCB( dlgHandle, editParamTag )
dlgHandle.setWidgetValue( editParamTag, '' );
end 
function modelCloseListener( ~, ~, obj )
dialog = DAStudio.ToolRoot.getOpenDialogs.find( 'dialogTag', obj.m_DialogTag );
if ~isempty( dialog )
dialog.delete;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp2CqT89.p.
% Please follow local copyright laws when handling this file.

