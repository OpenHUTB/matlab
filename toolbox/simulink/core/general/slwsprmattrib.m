function varargout = slwsprmattrib( varargin )





































































narginchk( 2, 4 );


nargoutchk( 0, 1 );

if isequal( 0, slfeature( 'NewTunableParameterDialog' ) ) && ~usejava( 'MWT' )
ex = MException( message( 'Simulink:dialog:NonJavaBasedPrmTunDlg' ) );
throw( ex );
end 

action = varargin{ 1 };
hModel = varargin{ 2 };

try 
switch lower( action )
case 'create'
if slfeature( 'NewTunableParameterDialog' ) > 0
d = Simulink.data.ParameterTuningDialog.ParameterTuningDialog( hModel );
dlg = DAStudio.Dialog( d );
d.setDialogObj( dlg );
dlg.enableApplyButton( false );

modelname = get_param( hModel, 'Name' );

Simulink.addBlockDiagramCallback( hModel, 'PreClose', 'slwsprmattrib',  ...
@(  )slwsprmattrib( 'modelclose', hModel ), true );
Simulink.addBlockDiagramCallback( hModel, 'PostNameChange', 'slwsprmattrib',  ...
@(  )slwsprmattrib( 'changename', hModel, modelname ), true );

varargout = { d };
else 
simprmChildren = varargin{ 3 };


CreateDialog( hModel, simprmChildren );


modelname = get_param( hModel, 'Name' );
appdata = getappdata( 0, modelname );
dialogFig = appdata.fWPA;

Simulink.addBlockDiagramCallback( hModel, 'PreClose', 'slwsprmattrib',  ...
@(  )slwsprmattrib( 'modelclose', hModel ), true );
Simulink.addBlockDiagramCallback( hModel, 'PostNameChange', 'slwsprmattrib',  ...
@(  )slwsprmattrib( 'changename', hModel, modelname ), true );

varargout = { dialogFig };
end 

case 'reshow'
if slfeature( 'NewTunableParameterDialog' ) > 0
dlgID = varargin{ 4 };
if ~isempty( dlgID ) || ~ishandle( dlgID )
dlg = dlgID.getDialogObj(  );
if isequal( class( dlg ), 'DAStudio.Dialog' )
dlg.showNormal;
varargout = { dlgID };
return ;
end 
end 
setappdata( 0, get_param( hModel, 'Name' ), '' );
rmappdata( 0, get_param( hModel, 'Name' ) );
d = Simulink.data.ParameterTuningDialog.ParameterTuningDialog( hModel );
dlg = DAStudio.Dialog( d );
d.setDialogObj( dlg );
dlg.enableApplyButton( false );

modelname = get_param( hModel, 'Name' );

Simulink.addBlockDiagramCallback( hModel, 'PreClose', 'slwsprmattrib',  ...
@(  )slwsprmattrib( 'modelclose', hModel ), true );
Simulink.addBlockDiagramCallback( hModel, 'PostNameChange', 'slwsprmattrib',  ...
@(  )slwsprmattrib( 'changename', hModel, modelname ), true );

varargout = { d };
else 
fWPA = varargin{ 4 };



appdata = getappdata( 0, get_param( hModel, 'Name' ) );
fWPA.setVisible( true );
doWsSelection( appdata.cVarsSelection, [  ], hModel );

appdata.tAttributes.repaint;
varargout = { fWPA };
end 

case 'changename'
oldModelName = varargin{ 3 };
if slfeature( 'NewTunableParameterDialog' ) > 0
d = getappdata( 0, oldModelName );
newname = get_param( hModel, 'Name' );
setappdata( 0, newname, d );
dlg = d.getDialogObj(  );
dlg.refresh;


Simulink.addBlockDiagramCallback( hModel, 'PostNameChange', 'slwsprmattrib',  ...
@(  )slwsprmattrib( 'changename', hModel, newname ), true );
else 
if isappdata( 0, oldModelName )
appdata = getappdata( 0, oldModelName );
dialogFig = appdata.fWPA;

set( dialogFig, 'Title', GetDialogName( hModel ) );


newname = get_param( hModel, 'Name' );
setappdata( 0, newname, appdata );
rmappdata( 0, oldModelName );


Simulink.addBlockDiagramCallback( hModel, 'PostNameChange', 'slwsprmattrib',  ...
@(  )slwsprmattrib( 'changename', hModel, newname ), true );

end 
end 
case 'modelclose'
if slfeature( 'NewTunableParameterDialog' ) < 1
if isappdata( 0, get_param( hModel, 'Name' ) )
appdata = getappdata( 0, get_param( hModel, 'Name' ) );
fWPA = appdata.fWPA;
hd = findobj( allchild( 0 ), 'Name', get( fWPA, 'Name' ) );
if ishandle( hd )
delete( hd );
end 
end 
end 


setappdata( 0, get_param( hModel, 'Name' ), '' );
rmappdata( 0, get_param( hModel, 'Name' ) );

case 'figdelete'

otherwise 
DAStudio.error( 'Simulink:dialog:InCorrectCallWksParamAttribDlgFunct' );
end 
catch 
if slfeature( 'NewTunableParameterDialog' ) > 0
setappdata( 0, get_param( hModel, 'Name' ), '' );
rmappdata( 0, get_param( hModel, 'Name' ) );
else 
if isappdata( 0, get_param( hModel, 'Name' ) )
appdata = getappdata( 0, get_param( hModel, 'Name' ) );
fWPA = appdata.fWPA;
hd = findobj( allchild( 0 ), 'Name', get( fWPA, 'Name' ) );

if ishandle( hd )
delete( hd );
end 


setappdata( 0, get_param( hModel, 'Name' ), '' );
rmappdata( 0, get_param( hModel, 'Name' ) );
else 

end 
end 
end 








function CreateDialog( hModel, simprmChildren )



if isappdata( 0, get_param( hModel, 'Name' ) ) &&  ...
~isempty( getappdata( 0, get_param( hModel, 'Name' ) ) )
appdata = getappdata( 0, get_param( hModel, 'Name' ) );
fWPA = appdata.fWPA;
hd = findobj( allchild( 0 ), 'Name', get( fWPA, 'Name' ) );
if ishandle( hd )

hd.setVisible( true );
fWPA.repaint;
return ;
end 
end 


fWPA = com.mathworks.mwt.MWFrame( GetDialogName( hModel ) );
appdata.fWPA = fWPA;
appdata.hModel = hModel;



fWPA.setLayout( java.awt.BorderLayout );


vCommonGeom = commonGeomFcn;


pDescription = com.mathworks.mwt.MWPanel(  ...
com.mathworks.mwt.MWBorderLayout( vCommonGeom.hGap, vCommonGeom.vGap ) );
pDescription.setInsets( vCommonGeom.insets );


gDescription = com.mathworks.mwt.MWGroupbox( DAStudio.message( 'Simulink:dialog:SlwsPrmDescription' ) );
gDescription.setLayout( java.awt.BorderLayout );


if slfeature( 'InlinePrmsAsCodeGenOnlyOption' )
descriptionStr = com.mathworks.mwt.MWStyledTextLabel( DAStudio.message( 'Simulink:dialog:StringDescForGlobalTunnableParams2' ) ); ...
else 
descriptionStr = com.mathworks.mwt.MWStyledTextLabel( DAStudio.message( 'Simulink:dialog:StringDescForGlobalTunnableParams1' ) ); ...
end 
appdata.descriptionStr = descriptionStr;
gDescription.add( descriptionStr, java.awt.BorderLayout.CENTER );
pDescription.add( gDescription );


fWPA.add( pDescription, java.awt.BorderLayout.NORTH );


pBottom = com.mathworks.mwt.MWPanel( java.awt.BorderLayout( vCommonGeom.vGap,  ...
vCommonGeom.hGap + vCommonGeom.vGap ) );

bStatus = com.mathworks.mwt.MWLabel;
bStatus.setText( DAStudio.message( 'Simulink:dialog:MsgReady' ) );
appdata.bStatus = bStatus;
pBottom.add( bStatus, java.awt.BorderLayout.CENTER );


pSystemButtons = com.mathworks.mwt.MWPanel( java.awt.FlowLayout( java.awt.FlowLayout.RIGHT,  ...
vCommonGeom.vGap * 2, vCommonGeom.vGap ) );


bOK = com.mathworks.mwt.MWButton( DAStudio.message( 'Simulink:dialog:DCDOK' ) );

bOK.setName( 'OKButton' );


bCancel = com.mathworks.mwt.MWButton( DAStudio.message( 'Simulink:dialog:DCDCancel' ) );

bCancel.setName( 'CancelButton' );


bHelp = com.mathworks.mwt.MWButton( DAStudio.message( 'Simulink:dialog:DCDHelp' ) );

bHelp.setName( 'HelpButton' );


bApply = com.mathworks.mwt.MWButton( DAStudio.message( 'Simulink:dialog:DCDPkgChangeApply' ) );
bApply.setEnabled( false );

bApply.setName( 'ApplyButton' );


appdata.bOK = bOK;
appdata.bCancel = bCancel;
appdata.bHelp = bHelp;
appdata.bApply = bApply;


pSystemButtons.add( bOK );
pSystemButtons.add( bCancel );
pSystemButtons.add( bHelp );
pSystemButtons.add( bApply );


pBottom.add( pSystemButtons, java.awt.BorderLayout.EAST );

fWPA.add( pBottom, java.awt.BorderLayout.SOUTH );






pMain = com.mathworks.mwt.MWPanel(  ...
com.mathworks.mwt.MWBorderLayout( vCommonGeom.hGap, vCommonGeom.vGap ) );
pMain.setInsets( vCommonGeom.insets );

pCentral = com.mathworks.mwt.MWSplitter;
pCentral.setOrientation( 0 );
pCentral.setDividerLocation( 1 );
pCentral.setDividerDark( 1 );
pCentral.setDividerLocation( 0.37 )





gWorkspaceVariables = com.mathworks.mwt.MWGroupbox( DAStudio.message( 'Simulink:dialog:SlwsPrmSourceList' ) );
gWorkspaceVariables.setLayout( java.awt.BorderLayout( vCommonGeom.vGap,  ...
vCommonGeom.vGap + vCommonGeom.hGap ) );


lVariables = com.mathworks.mwt.MWListbox;
appdata.lVariables = lVariables;

lVariables.setName( 'VarsListbox' );


lVariables.setHeaderVisible( 1 );
lVariables.setColumnCount( 1 );
varsListHeaderStr = { DAStudio.message( 'Simulink:dialog:DCDName' ) };

lVariables.setHeaders( varsListHeaderStr );
lVariables.setPreferredTableSize( 4, 1 );
lVariables.getColumnOptions.setHeaderVisible( 1 );
lVariables.getRowOptions.setHeaderVisible( 1 );
lVariables.getRowOptions.setHeaderWidth( 30 );
lVariables.getTableStyle.setHGridVisible( 1 );
lVariables.getColumnOptions.setResizable( 0 );
lVariables.setMultiSelection( 1 );
width = 50;
lVariables.setColumnWidth( 0, width );


gWorkspaceVariables.add( lVariables, java.awt.BorderLayout.CENTER );


wsList = { DAStudio.message( 'Simulink:dialog:MATLABWksVars' );DAStudio.message( 'Simulink:dialog:ReferencedWksVars' ) };
wsSrc = wsList{ 1 };
try 
wsSrc = get_param( hModel, 'ParamWorkspaceSource' );
if findstr( wsSrc, 'MATLAB' )
wsSrc = wsList{ 1 };
else 
wsSrc = wsList{ 2 };
end 
catch 

end 
cVarsSelection = com.mathworks.mwt.MWCombobox( wsSrc, wsList );

cVarsSelection.setTextEditable( 0 );
appdata.cVarsSelection = cVarsSelection;

cVarsSelection.setName( 'VarsSelectionPopup' );


gWorkspaceVariables.add( cVarsSelection, java.awt.BorderLayout.NORTH );


pAddRefresh = com.mathworks.mwt.MWPanel( java.awt.BorderLayout( vCommonGeom.vGap,  ...
vCommonGeom.vGap + vCommonGeom.hGap ) );


bAdd = com.mathworks.mwt.MWButton( DAStudio.message( 'Simulink:dialog:SlwsPrmAddToTable' ) );
set( bAdd, 'Name', 'AddToTableButton' );
appdata.bAdd = bAdd;
bAdd.setEnabled( false );

pAddRefresh.add( bAdd, java.awt.BorderLayout.EAST );


bRefresh = com.mathworks.mwt.MWButton( DAStudio.message( 'Simulink:dialog:SlwsPrmRefreshList' ) );
appdata.bRefresh = bRefresh;

bRefresh.setName( 'RefreshButton' );

pAddRefresh.add( bRefresh, java.awt.BorderLayout.WEST );


gWorkspaceVariables.add( pAddRefresh, java.awt.BorderLayout.SOUTH );


pCentral.add( gWorkspaceVariables );





gAttributesSettings = com.mathworks.mwt.MWGroupbox( DAStudio.message( 'Simulink:dialog:SlwsPrmGlobalTunableParameters' ) );
gAttributesSettings.setLayout( java.awt.BorderLayout( vCommonGeom.vGap,  ...
vCommonGeom.vGap + vCommonGeom.hGap ) );


tAttributes = com.mathworks.mwt.MWTable( 3, 3 );
appdata.tAttributes = tAttributes;

tAttributes.setName( 'AttributesTable' );
tAttributes.setTableBackground( tAttributes.getBackground );

tAttributes.getSelectionOptions.setMode( com.mathworks.mwt.table.SelectionOptions.SELECT_COMPLEX );

tAttributesHeadersStr = {  ...
DAStudio.message( 'Simulink:dialog:SlwsPrmName' );DAStudio.message( 'Simulink:dialog:SlwsPrmStorageClass' );DAStudio.message( 'Simulink:dialog:SlwsPrmStorageTypeQualifier' ) };
for i = 0:length( tAttributesHeadersStr ) - 1
tAttributes.setColumnHeaderData( i, tAttributesHeadersStr{ i + 1 } );
end 
tAttributes.setAutoExpandColumn( 2 );
tAttributes.getColumnOptions.setResizable( 1 );
tAttributes.getRowOptions.setHeaderVisible( 1 );
tAttributes.getRowOptions.setHeaderWidth( 30 );
tAttributes.getSelectionOptions.setSelectBy( com.mathworks.mwt.table.SelectionOptions.SELECT_BY_ROW );
tAttributes.setCursorType( java.awt.Cursor.DEFAULT_CURSOR );

tStyle = tAttributes.getTableStyle;
tStyle.setEditable( 1 );
tAttributes.setTableStyle( tStyle );

tAttributes.setMinAutoExpandColumnWidth( 30 );

nRows = 0;
tAttributes.getData.setHeight( nRows );


gAttributesSettings.add( tAttributes, java.awt.BorderLayout.CENTER );


pNew = com.mathworks.mwt.MWPanel( java.awt.FlowLayout( java.awt.FlowLayout.RIGHT, vCommonGeom.vGap * 2, 0 ) );


bNew = com.mathworks.mwt.MWButton( DAStudio.message( 'Simulink:dialog:SlwsPrmNew' ) );
appdata.bNew = bNew;

bNew.setName( 'NewButton' );


bRemove = com.mathworks.mwt.MWButton( DAStudio.message( 'Simulink:dialog:SlwsPrmRemove' ) );
bRemove.setEnabled( false );
appdata.bRemove = bRemove;

bRemove.setName( 'RemoveButton' );


pNew.add( bNew );
pNew.add( bRemove );


lStyle = com.mathworks.mwt.table.Style( com.mathworks.mwt.table.Style.H_ALIGNMENT );
lStyle.setHAlignment( com.mathworks.mwt.table.Style.H_ALIGN_CENTER );
tAttributes.setColumnStyle( 1, lStyle );
tAttributes.setColumnStyle( 2, lStyle );

for i = 0:nRows

tAttributes.setColumnWidth( 0, 60 );


tAttributes.setColumnWidth( 1, 150 );


tAttributes.setColumnWidth( 2, 120 );

end 


gAttributesSettings.add( pNew, java.awt.BorderLayout.SOUTH );


pCentral.add( gAttributesSettings );

pMain.add( pCentral );


fWPA.add( pMain, java.awt.BorderLayout.CENTER );


setappdata( 0, get_param( hModel, 'Name' ), appdata );


local_AddCallback( fWPA, 'WindowClosingCallback', { @doCloseFigure, fWPA } );


local_AddCallback( bOK, 'MouseEnteredCallback', { @doMouseEnterFcn, hModel } );
local_AddCallback( bOK, 'MouseExitedCallback', { @doMouseExitFcn, hModel } );
local_AddCallback( bCancel, 'MouseEnteredCallback', { @doMouseEnterFcn, hModel } );
local_AddCallback( bCancel, 'MouseExitedCallback', { @doMouseExitFcn, hModel } );
local_AddCallback( bHelp, 'MouseEnteredCallback', { @doMouseEnterFcn, hModel } );
local_AddCallback( bHelp, 'MouseExitedCallback', { @doMouseExitFcn, hModel } );
local_AddCallback( bApply, 'MouseEnteredCallback', { @doMouseEnterFcn, hModel } );
local_AddCallback( bApply, 'MouseExitedCallback', { @doMouseExitFcn, hModel } );
local_AddCallback( bOK, 'ActionPerformedCallback', { @doOK, hModel } );
local_AddCallback( bCancel, 'ActionPerformedCallback', { @doCancel, hModel } );
local_AddCallback( bHelp, 'ActionPerformedCallback', { @doHelp, fWPA } );
local_AddCallback( bApply, 'ActionPerformedCallback', { @doApply, hModel } );
local_AddCallback( bRemove, 'MouseEnteredCallback', { @doMouseEnterFcn, hModel } );
local_AddCallback( bRemove, 'MouseExitedCallback', { @doMouseExitFcn, hModel } );
local_AddCallback( bNew, 'ActionPerformedCallback', { @doNew, hModel } );
local_AddCallback( bRemove, 'ActionPerformedCallback', { @doRemove, hModel } );

local_AddCallback( bAdd, 'MouseEnteredCallback', { @doMouseEnterFcn, hModel } );
local_AddCallback( bAdd, 'MouseExitedCallback', { @doMouseExitFcn, hModel } );
local_AddCallback( bAdd, 'ActionPerformedCallback', { @doAdd, hModel } );

local_AddCallback( bRefresh, 'MouseEnteredCallback', { @doMouseEnterFcn, hModel } );
local_AddCallback( bRefresh, 'MouseExitedCallback', { @doMouseExitFcn, hModel } );
local_AddCallback( bRefresh, 'ActionPerformedCallback', { @doRefresh, hModel } );

local_AddCallback( bNew, 'MouseEnteredCallback', { @doMouseEnterFcn, hModel } );
local_AddCallback( bNew, 'MouseExitedCallback', { @doMouseExitFcn, hModel } );

local_AddCallback( lVariables, 'MouseEnteredCallback', { @doMouseEnterFcn, hModel } );
local_AddCallback( lVariables, 'MouseExitedCallback', { @doMouseExitFcn, hModel } );
local_AddCallback( lVariables, 'ItemStateChangedCallback',  ...
{ @ListboxItemStateChangedCallback, hModel } );
local_AddCallback( lVariables, 'MouseClickedCallback', { @doMouseClickFcn, hModel } );
local_AddCallback( lVariables, 'ValueChangedCallback', { @AddSelectedVarsIntoTable, hModel } );

local_AddCallback( cVarsSelection, 'MouseEnteredCallback', { @doMouseEnterFcn, hModel } );
local_AddCallback( cVarsSelection, 'MouseExitedCallback', { @doMouseExitFcn, hModel } );
local_AddCallback( cVarsSelection, 'ActionPerformedCallback', { @doWsSelection, hModel } );


local_AddCallback( tAttributes, 'ItemStateChangedCallback',  ...
{ @TableItemStateChangedCallback, hModel } );


local_AddCallback( tAttributes, 'ValueChangedCallback',  ...
{ @TableValueChangedCallback, hModel } );

fWPA.pack;
fWPA.setSize( 700, 500 );
awtinvoke( fWPA, 'show()' );









function doAdd( bAdd, evd, hModel )

appdata = getappdata( 0, get_param( hModel, 'Name' ) );

appdata.bStatus.setText( DAStudio.message( 'Simulink:dialog:AddingParamsToTable' ) );

AddSelectedVarsIntoTable( appdata.lVariables, [  ], hModel );

bAdd.setEnabled( false );
appdata.bStatus.setText( DAStudio.message( 'Simulink:dialog:MsgReady' ) );








function doApply( bApply, evd, hModel )

appdata = getappdata( 0, get_param( hModel, 'Name' ) );

appdata.bStatus.setText( DAStudio.message( 'Simulink:dialog:SavingParams' ) );


invalidVars = SaveTunableVars( appdata );


if strcmp( appdata.cVarsSelection.getText, DAStudio.message( 'Simulink:dialog:MATLABWksVars' ) )
set_param( hModel, 'ParamWorkspaceSource', 'MATLABWorkspace' );
elseif strcmp( appdata.cVarsSelection.getText, DAStudio.message( 'Simulink:dialog:ReferencedWksVars' ) )
set_param( hModel, 'ParamWorkspaceSource', 'ReferencedWorkspace' );
else 
errordlg( DAStudio.message( 'Simulink:dialog:ErrorSetParamWksSrc' ) );
end 

if ~isempty( invalidVars )
errordlg( DAStudio.message( 'Simulink:dialog:ErrorSetParamTunableParams' ) );
else 
bApply.setEnabled( false );
end 
appdata.bStatus.setText( DAStudio.message( 'Simulink:dialog:MsgReady' ) );








function doCancel( bCancel, evd, hModel )

appdata = getappdata( 0, get_param( hModel, 'Name' ) );

fWPA = appdata.fWPA;
tAttributes = appdata.tAttributes;


tableData = tAttributes.getData;
tableData.removeRows( 0, tableData.getHeight );

doCloseFigure( bCancel, evd, fWPA );








function doCloseFigure( frame, evd, fWPA )

fWPA.setVisible( 0 );
awtinvoke( fWPA, 'dispose()' );








function doHelp( bHelp, evd, fWPA )

helpview( [ docroot, '/toolbox/simulink/helptargets.map' ], 'model_param_cfg_dlg' );








function doNew( bNew, evd, hModel )


appdata = getappdata( 0, get_param( hModel, 'Name' ) );
lVariables = appdata.lVariables;
tAttributes = appdata.tAttributes;


oldHeight = tAttributes.getData.getHeight;
tAttributes.getData.setHeight( 1 + oldHeight );


tAttributes = AddNewItemInTable( tAttributes, 1 );


tAttributes.select( oldHeight, 0 );

appdata.bRemove.setEnabled( true );
appdata.bApply.setEnabled( true );









function doOK( bOK, evd, hModel )

appdata = getappdata( 0, get_param( hModel, 'Name' ) );
fWPA = appdata.fWPA;
doApply( appdata.bApply, evd, hModel );

fWPA.setVisible( 0 );
awtinvoke( fWPA, 'dispose()' );

appdata.bApply.setEnabled( false );








function doRefresh( bRefresh, evd, hModel )

appdata = getappdata( 0, get_param( hModel, 'Name' ) );

cVarsSelection = appdata.cVarsSelection;
valSelected = cVarsSelection.getText;
choices = get( cVarsSelection, 'Label' );

if strcmp( valSelected, choices{ 1 } )
appdata = LoadWhosData( appdata );
elseif strcmp( valSelected, choices{ 2 } )
appdata.lVariables = LoadReferencedVars( appdata, hModel );
else 
DAStudio.error( 'Simulink:dialog:InternalDataCorrptCloseModel' );
end 

appdata.bApply.setEnabled( true );

setappdata( 0, get_param( hModel, 'Name' ), appdata );








function doRemove( bRemove, evd, hModel )


appdata = getappdata( 0, get_param( hModel, 'Name' ) );
lVariables = appdata.lVariables;
tAttributes = appdata.tAttributes;


try 
rowIndx = tAttributes.getSelectedRows;
catch 
rowIndx = [  ];
end 


removedItems = [  ];
for i = 1:length( rowIndx )
removedItems = [ removedItems, '/',  ...
tAttributes.getCellData( rowIndx( i ), 0 ), '/' ];
end 


itemsOnList = get( lVariables, 'Items' );
releasedIndx = [  ];
lStyle = com.mathworks.mwt.table.Style;
for i = 0:length( itemsOnList ) - 1
item = [ '/', itemsOnList{ i + 1 }, '/' ];
if ~isempty( findstr( removedItems, item ) )
lVariables.setRowStyle( i, lStyle );
end 
end 
lVariables.repaint;


if ~isempty( rowIndx )
tableData = tAttributes.getData;
tableData.removeRows( rowIndx( 1 ), length( rowIndx ) );
end 

if tAttributes.getData.getHeight > 0
appdata.bRemove.setEnabled( true );
else 
appdata.bRemove.setEnabled( false );
end 
appdata.bApply.setEnabled( true );


appdata.tAttributes = tAttributes;
appdata.lVariables = lVariables;
setappdata( 0, get_param( hModel, 'Name' ), appdata );








function doMouseEnterFcn( obj, evd, hModel )

if ishandle( hModel )
mdlName = get_param( hModel, 'Name' );
appdata = getappdata( 0, mdlName );

itemName = get( obj, 'Name' );

switch itemName
case 'AddToTableButton'
str = DAStudio.message( 'Simulink:dialog:AddSelectVarsToGlobalTunable' );
case 'OKButton'
str = DAStudio.message( 'Simulink:dialog:ApplyChangesToDialogAndClose' );
case 'CancelButton'
str = DAStudio.message( 'Simulink:dialog:DiscardChangesToDialogAndClose' );
case 'HelpButton'
str = DAStudio.message( 'Simulink:dialog:LaunchHelp' );
case 'ApplyButton'
str = DAStudio.message( 'Simulink:dialog:ApplyChanges' );
case 'RefreshButton'
str = DAStudio.message( 'Simulink:dialog:RefreshSourceList' );
case 'NewButton'
str = DAStudio.message( 'Simulink:dialog:AddingNewParamToGlobalTunable' );
case 'RemoveButton'
str = DAStudio.message( 'Simulink:dialog:RemoveSelectParamsFromGlobalTunable' );
case 'VarsSelectionPopup'
str = DAStudio.message( 'Simulink:dialog:DispVarsInSelSrc' );
case 'VarsListbox'
str = DAStudio.message( 'Simulink:dialog:SelVarsAddToGlobalTunable' );
otherwise 
str = DAStudio.message( 'Simulink:dialog:NoStatus' );
end 

bStatus = appdata.bStatus;
bStatus.setText( str );
end 








function doMouseExitFcn( obj, evd, hModel )

if ishandle( hModel )
mdlName = get_param( hModel, 'Name' );
appdata = getappdata( 0, mdlName );

itemName = get( obj, 'Name' );

switch itemName
case { 'AddToTableButton', 'OKButton', 'CancelButton', 'HelpButton',  ...
'ApplyButton', 'RefreshButton', 'NewButton', 'RemoveButton',  ...
'VarsSelectionPopup', 'VarsListbox' }
str = DAStudio.message( 'Simulink:dialog:MsgReady' );
otherwise 

str = '';
end 

if ~isempty( str )
bStatus = appdata.bStatus;
bStatus.setText( str );
end 
end 






function doMouseClickFcn( obj, ~, hModel )
itemName = get( obj, 'Name' );

switch itemName
case 'VarsListbox'
mdlName = get_param( hModel, 'Name' );
appdata = getappdata( 0, mdlName );
appdata.bRemove.setEnabled( false );
otherwise 

end 





function doWsSelection( cVarsSelection, evd, hModel )

appdata = getappdata( 0, get_param( hModel, 'Name' ) );

valSelected = cVarsSelection.getText;
choices = get( cVarsSelection, 'Label' );

if strcmp( valSelected, choices{ 1 } )
appdata = LoadWhosData( appdata );
elseif strcmp( valSelected, choices{ 2 } )
lVariables = LoadReferencedVars( appdata, hModel );
else 
DAStudio.error( 'Simulink:dialog:InternalDataCorrptCloseModel' );
end 
appdata.bApply.setEnabled( true );

setappdata( 0, get_param( hModel, 'Name' ), appdata );







function table = AddNewItemInTable( table, numNewItems )


builtinSCs = coder.internal.getBuiltinStorageClasses( false );
storageClassStr = builtinSCs;


typeQualifierStr = { '';'const'; };

nRows = table.getData.getHeight;
if nRows == 0
DAStudio.error( 'Simulink:dialog:MAssertTableEmptyCallingFunct', 'AddNewItemInTable' );
end 
for i = nRows - numNewItems:nRows - 1
storageClassCell = com.mathworks.mwt.table.DynamicEnumWithState( storageClassStr );
storageClassCell.setEditable( 0 );
table.setCellData( i, 1, storageClassCell );

typeQualifierCell = com.mathworks.mwt.table.DynamicEnumWithState( typeQualifierStr );
typeQualifierCell.setEditable( 1 );
table.setCellData( i, 2, typeQualifierCell );
end 









function AddSelectedVarsIntoTable( lVariables, evd, hModel )


appdata = getappdata( 0, get_param( hModel, 'Name' ) );
lVariables = appdata.lVariables;
tAttributes = appdata.tAttributes;


rowIndx = [  ];
if lVariables.getItemCount > 0
try 
rowIndx = lVariables.getSelectedRows;
catch 
rowIndx = [  ];
end 
end 

selectedItems = [  ];
if ~isempty( rowIndx )
lStyle = com.mathworks.mwt.table.Style;
lStyle.setFont(  ...
java.awt.Font( '',  ...
java.awt.Font.BOLD + java.awt.Font.ITALIC,  ...
lStyle.getFont.getSize ) );

for i = 1:length( rowIndx )
selectedItems = [ selectedItems; ...
{ lVariables.getCellData( rowIndx( i ), 0 ) } ];
lVariables.setRowStyle( rowIndx( i ), lStyle );
end 
end 
lVariables.repaint;


prevVars = GetExistingVarsInTable( tAttributes );

if ~isempty( selectedItems )

nRows = tAttributes.getData.getHeight;


for i = nRows:nRows + length( selectedItems ) - 1
if isempty( findstr(  ...
prevVars, [ '/', deblankall( selectedItems{ i - nRows + 1 } ), '/' ] ) )

tAttributes.getData.setHeight( tAttributes.getData.getHeight + 1 );
tAttributes = AddNewItemInTable( tAttributes, 1 );


tAttributes.setCellData( tAttributes.getData.getHeight - 1, 0,  ...
selectedItems{ i - nRows + 1 } );

else 

end 
end 
end 

if tAttributes.getData.getHeight > 1
tAttributes = SortRowsInTable( tAttributes, hModel );
end 


tAttributes.repaint;

appdata.lVariables = lVariables;
appdata.tAttributes = tAttributes;

setappdata( 0, get_param( hModel, 'Name' ), appdata );








function name = GetDialogName( hModel )

if nargin < 1
modelName = [  ];
else 
modelName = get_param( hModel, 'name' );
end 
name = DAStudio.message( 'Simulink:dialog:ModelParamConfigName', modelName );








function vars = GetExistingVarsInTable( table )

try 
vars = [  ];
if table.getData.getHeight > 0
for i = 0:table.getData.getHeight - 1
vars = [ vars, '/', deblankall( table.getCellData( i, 0 ) ), '/' ];
end 
end 
catch 
vars = [  ];
end 









function ListboxItemStateChangedCallback( listbox, ~, hModel )


appdata = getappdata( 0, get_param( hModel, 'Name' ) );
listbox = appdata.lVariables;


rowIndx = [  ];
if listbox.getItemCount > 0
try 
rowIndx = listbox.getSelectedRows;
catch 
rowIndx = [  ];
end 
end 

cVarsSelection = appdata.cVarsSelection;
valSelected = cVarsSelection.getText;
choices = get( cVarsSelection, 'Label' );
if length( rowIndx ) > 0
appdata.bAdd.setEnabled( true );
end 








function listbox = LoadReferencedVars( appdata, hModel )

appdata.bStatus.setText( DAStudio.message( 'Simulink:dialog:LoadingParams' ) );


varsInTable = [  ];
if isfield( appdata, 'tAttributes' )
tAttributes = appdata.tAttributes;
varsInTable = GetExistingVarsInTable( tAttributes );
end 

listbox = appdata.lVariables;
warnMsg = [  ];
referencedVars = [  ];
try 
referencedVars = get_param( hModel, 'ReferencedWSVars' );
catch 
warnMsg = DAStudio.message( 'Simulink:dialog:UnableToResolveAllParamFields' );
end 

listbox.removeAllItems;


lStyle = com.mathworks.mwt.table.Style;

if ~isempty( referencedVars )
listbox.removeAllItems;

varsList = { referencedVars.Name }';



validNames = slGetSpecifiedWSData( '', 1, 0, 0 );

varsList = intersect( varsList, validNames );
if ~isempty( varsList )
listbox.setItems( varsList );
end 
else 

end 

if ~isempty( warnMsg )
set_param( hModel, 'SimulationCommand', 'Start' );
appdata.bStatus.setText( warnMsg );
else 
appdata.bStatus.setText( DAStudio.message( 'Simulink:dialog:MsgReady' ) );
end 

SyncAndUpdateTable( tAttributes, listbox, varsInTable, appdata );

setappdata( 0, get_param( hModel, 'Name' ), appdata );









function tunableVars = LoadTunableVars( hModel )


tunableVars = PrmStr2Struct( hModel );









function appdata = LoadWhosData( appdata, listbox )

ud = appdata;

ud.bStatus.setText( DAStudio.message( 'Simulink:dialog:LoadingParams' ) );


varsInTable = [  ];
if isfield( ud, 'tAttributes' )
tAttributes = ud.tAttributes;
varsInTable = GetExistingVarsInTable( tAttributes );
end 

if nargin == 2
lVariables = listbox;
else 
lVariables = ud.lVariables;
end 

hModel = ud.hModel;
ud = getappdata( 0, get_param( hModel, 'Name' ) );


Names = slGetSpecifiedWSData( '', 1, 0, 0 );


lVariables.removeAllItems;
if ~isempty( Names )

lStyle = com.mathworks.mwt.table.Style;
Names = sortrows( Names );
lVariables.setItems( Names );
else 

end 

SyncAndUpdateTable( tAttributes, lVariables, varsInTable, appdata );

ud.bStatus.setText( DAStudio.message( 'Simulink:dialog:MsgReady' ) );

setappdata( 0, get_param( hModel, 'Name' ), ud );











function MultiStorageClassChange( cStorageClass, evd, hModel )

appdata = getappdata( 0, get_param( hModel, 'Name' ) );
tAttributes = appdata.tAttributes;

selectedText = cStorageClass.getText;

tAttributes = MultiChangeCallback( tAttributes, 2, selectedText );
appdata.bApply.setEnabled( true );








function MultiTypeQualifierChange( cTypeQualifier, evd, hModel )

appdata = getappdata( 0, get_param( hModel, 'Name' ) );
tAttributes = appdata.tAttributes;

selectedText = cTypeQualifier.getText;

tAttributes = MultiChangeCallback( tAttributes, 3, selectedText );
appdata.bApply.setEnabled( true );








function table = MultiChangeCallback( table, colNum, newText )


try 
rowIndx = table.getSelectedRows;
catch 
rowIndx = [  ];
end 

if ~isempty( rowIndx )
for i = 1:length( rowIndx )
if colNum == 1

storageClassText =  ...
lower( deblankall(  ...
table.getCellData( rowIndx( i ), colNum - 1 ).getCurrentString ) );

if strcmp( storageClassText, 'auto' )
newText = ' ';
warnState = warning( 'off', 'backtrace' );
warning( 'on', 'Simulink:dialog:ParamHasSCAutoCannotHaveStorageType' );
MSLDiagnostic( 'Simulink:dialog:ParamHasSCAutoCannotHaveStorageType',  ...
table.getCellData( rowIndx( i ), 0 ) ).reportAsWarning;
warning( warnState );
end 
end 

table.getCellData( rowIndx( i ), colNum ).setCurrentString( newText );
end 
end 


table.repaintCells( rowIndx( 1 ), colNum, length( rowIndx ), 1 );





















function varsInStruct = PrmStr2Struct( hModel )

tunableVarsName = get_param( hModel, 'TunableVars' );
tunableVarsStorageClass = get_param( hModel, 'TunableVarsStorageClass' );
tunableVarsTypeQualifier = get_param( hModel, 'TunableVarsTypeQualifier' );

varsInStruct = [  ];


sep = ',';
sepNameIndx = findstr( tunableVarsName, sep );
sepSCIndx = findstr( tunableVarsStorageClass, sep );
sepTQIndx = findstr( tunableVarsTypeQualifier, sep );


if ~isempty( tunableVarsName )
numberVars = length( sepNameIndx ) + 1;
else 
numberVars = 0;
end 

vars = [  ];
if numberVars

if length( sepSCIndx ) + 1 ~= numberVars
errordlg( [ DAStudio.message( 'Simulink:dialog:ErrorTunableParamsStorageClassSettings',  ...
get_param( hModel, 'name' ) ), ' ', DAStudio.message( 'Simulink:dialog:LoadingFailed' ) ],  ...
DAStudio.message( 'Simulink:dialog:ModelParamConfigDialogErrTitle' ), 'modal' );
return ;
elseif length( sepTQIndx ) + 1 ~= numberVars
errordlg( [ DAStudio.message( 'Simulink:dialog:ErrorTunableParamsTypeQualSettings',  ...
get_param( hModel, 'name' ) ), ' ', DAStudio.message( 'Simulink:dialog:LoadingFailed' ) ],  ...
DAStudio.message( 'Simulink:dialog:ModelParamConfigDialogErrTitle' ), 'modal' );
return ;
elseif length( sepTQIndx ) ~= length( sepSCIndx )
errordlg( [ DAStudio.message( 'Simulink:dialog:ErrorTunableParamsNumberQualSettings',  ...
get_param( hModel, 'name' ) ), ' ', DAStudio.message( 'Simulink:dialog:LoadingFailed' ) ],  ...
DAStudio.message( 'Simulink:dialog:ModelParamConfigDialogErrTitle' ), 'modal' );
set( Children.okButton, 'Enable', 'off' );
set( Children.applyButton, 'Enable', 'off' );
return ;
end 


sepNameIndx = [ 0, sepNameIndx, length( tunableVarsName ) + 1 ];
sepSCIndx = [ 0, sepSCIndx, length( tunableVarsStorageClass ) + 1 ];
sepTQIndx = [ 0, sepTQIndx, length( tunableVarsTypeQualifier ) + 1 ];

for i = 1:numberVars

vars( i ).name = deblankall( tunableVarsName( sepNameIndx( i ) + 1: ...
sepNameIndx( i + 1 ) - 1 ) );
if ~validate( vars( i ).name )
warnState = warning( 'off', 'backtrace' );
warning( 'on', 'Simulink:dialog:InvalidVarChkCommandWindow' );
MSLDiagnostic( 'Simulink:dialog:InvalidVarChkCommandWindow',  ...
vars( i ).name,  ...
[ 'get_param(''', get_param( hModel, 'Name' ), ''', ''TunableVars'')' ] ).reportAsWarning;
warning( warnState );
end 


vars( i ).storageclass = deblankall(  ...
tunableVarsStorageClass( sepSCIndx( i ) + 1:sepSCIndx( i + 1 ) - 1 ) );
if strcmp( lower( vars( i ).storageclass ), 'auto' )
vars( i ).storageclass = 'Model default';
elseif strcmp( lower( vars( i ).storageclass ), 'exportedglobal' )
vars( i ).storageclass = 'ExportedGlobal';
elseif strcmp( lower( vars( i ).storageclass ), 'importedextern' )
vars( i ).storageclass = 'ImportedExtern';
elseif strcmp( lower( vars( i ).storageclass ), 'importedexternpointer' )
vars( i ).storageclass = 'ImportedExternPointer';
end 


if isempty( tunableVarsTypeQualifier( sepTQIndx( i ) + 1:sepTQIndx( i + 1 ) - 1 ) )
vars( i ).typequalifier = '';
else 
vars( i ).typequalifier = tunableVarsTypeQualifier( sepTQIndx( i ) + 1: ...
sepTQIndx( i + 1 ) - 1 );
end 
end 

end 

varsInStruct = vars;








function listbox = RefreshListbox( listbox, data )

listbox.removeAllItems;

for i = 0:length( data ) - 1
listbox.addItem( ' ' );

listbox.setCellData( i, 0, deblankall( data( i + 1 ).name ) );

varSize = '';
varClass = '';


lStyle = com.mathworks.mwt.table.Style( com.mathworks.mwt.table.Style.FOREGROUND );

if evalin( 'base', [ 'exist(''', data( i + 1 ).name, ''')' ] )
[ m, n ] = size( data( i + 1 ).name );
varSize = [ num2str( m ), 'x', num2str( n ) ];
varClass = evalin( 'base', [ 'class(', data( i + 1 ).name, ')' ] );
else 
lStyle.setFont(  ...
java.awt.Font( '',  ...
java.awt.Font.BOLD + java.awt.Font.ITALIC,  ...
lStyle.getFont.getSize ) );
end 


listbox.setRowStyle( i, lStyle );
end 
listbox.repaint;








function table = RefreshTable( table, prevData, data )

redundent = 0;
prevTableHeight = table.getData.getHeight;
if isempty( prevData )

table.getData.setHeight( length( data ) );
table = AddNewItemInTable( table, length( data ) );
for i = 0:length( data ) - 1
table.setCellData( i, 0, deblankall( data( i + 1 ).name ) );
table.getCellData( i, 1 ).setCurrentString( data( i + 1 ).storageclass );
table.getCellData( i, 2 ).setCurrentString( data( i + 1 ).typequalifier );
end 
else 
for i = 0:length( data ) - 1

if isempty( findstr( prevData, [ '/', deblankall( data( i + 1 ).name ), '/' ] ) )
table.getData.setHeight( prevTableHeight + i + 1 - redundent );
table = AddNewItemInTable( table, 1 );
table.setCellData( i + prevTableHeight - redundent, 0,  ...
deblankall( data( i + 1 ).name ) );
table.getCellData( i + prevTableHeight - redundent, 1 ).setCurrentString(  ...
data( i + 1 ).storageclass );
table.getCellData( i + prevTableHeight - redundent, 2 ).setCurrentString(  ...
data( i + 1 ).typequalifier );
else 
redundent = redundent + 1;
end 
end 
end 
table.repaint;










function invalidVars = SaveTunableVars( appdata )

invalidVars = [  ];

hModel = appdata.hModel;
tAttributes = appdata.tAttributes;

tunableVarsName = [  ];
tunableVarsStorageClass = [  ];
tunableVarsTypeQualifier = [  ];


for i = 0:tAttributes.getData.getHeight - 1
if i == 0
sep = '';
else 
sep = ',';
end 
tunableVarsName = [ tunableVarsName, sep,  ...
deblankall( tAttributes.getCellData( i, 0 ) ) ];

scTmp = deblankall( tAttributes.getCellData( i,  ...
1 ).getCurrentString );
if contains( lower( scTmp ), 'auto' ) || strcmp( scTmp, 'model default' )
scTmp = 'Auto';
end 
tunableVarsStorageClass = [ tunableVarsStorageClass, sep, scTmp ];

if ~strcmp( lower( scTmp ), 'auto' )
tqTmp = char( tAttributes.getCellData( i, 2 ).getCurrentString );
else 
tqTmp = '';
end 
tunableVarsTypeQualifier = [ tunableVarsTypeQualifier, sep, tqTmp ];

end 

if tAttributes.getData.getHeight > 0
set_param( hModel,  ...
'TunableVars', tunableVarsName,  ...
'TunableVarsStorageClass', tunableVarsStorageClass,  ...
'TunableVarsTypeQualifier', tunableVarsTypeQualifier ...
 );
else 

set_param( hModel,  ...
'TunableVars', '',  ...
'TunableVarsStorageClass', '',  ...
'TunableVarsTypeQualifier', '' ...
 );
end 









function sortedTable = SortRowsInTable( table, hModel )

appdata = getappdata( 0, get_param( hModel, 'Name' ) );
tAttributes = appdata.tAttributes;


for i = 0:tAttributes.getData.getHeight - 1
for j = 0:2
switch j
case 0
tableDataAsMatrix{ i + 1, j + 1 } = tAttributes.getCellData( i, j );
case { 1, 2 }
tableDataAsMatrix{ i + 1, j + 1 } =  ...
char( tAttributes.getCellData( i, j ).getCurrentString );
otherwise 

end 
end 
end 
newTableDataAsMatrix = sortrows( tableDataAsMatrix, 1 );


for i = 0:tAttributes.getData.getHeight - 1
for j = 0:2
switch j
case 0
tAttributes.setCellData( i, j, newTableDataAsMatrix{ i + 1, j + 1 } );
case { 1, 2 }
tAttributes.getCellData( i, j ).setCurrentString(  ...
newTableDataAsMatrix{ i + 1, j + 1 } );
otherwise 

end 
end 
end 
sortedTable = tAttributes;








function SyncAndUpdateTable( tAttributes, lVariables, varsInTable, appdata )




tAttributes = appdata.tAttributes;

tunableVars = LoadTunableVars( appdata.hModel );
if ~isempty( tunableVars )
tAttributes = RefreshTable( tAttributes, varsInTable,  ...
tunableVars );
end 


lStyle = com.mathworks.mwt.table.Style;
lStyle.setFont(  ...
java.awt.Font( '',  ...
java.awt.Font.BOLD + java.awt.Font.ITALIC,  ...
lStyle.getFont.getSize ) );

varsNames = [  ];
for i = 0:tAttributes.getData.getHeight - 1
varsNames = [ varsNames,  ...
'/', deblankall( tAttributes.getCellData( i, 0 ) ), '/' ];
end 
repaintFlag = [  ];
if lVariables.getItemCount > 0 && ~isempty( varsNames )
for i = 0:lVariables.getItemCount - 1
if ~isempty( findstr( varsNames,  ...
[ '/', lVariables.getCellData( i, 0 ), '/' ] ) )
lVariables.setRowStyle( i, lStyle );
repaintFlag = 1;
end 
end 
end 

if ~isempty( repaintFlag )
lVariables.repaint;
end 










function TableItemStateChangedCallback( tAttributes, evd, hModel )

appdata = getappdata( 0, get_param( hModel, 'Name' ) );
tAttributes = appdata.tAttributes;


rowIndx = [  ];
if tAttributes.getData.getHeight > 0
try 
rowIndx = tAttributes.getSelectedRows;
catch 
rowIndx = [  ];
end 
end 

if length( rowIndx ) > 0
appdata.bRemove.setEnabled( true );
appdata.bApply.setEnabled( true );
end 

if isempty( rowIndx )
appdata.bRemove.setEnabled( false );
end 









function TableValueChangedCallback( tAttributes, evd, hModel )

appdata = getappdata( 0, get_param( hModel, 'Name' ) );
tAttributes = appdata.tAttributes;
lVariables = appdata.lVariables;
bStatus = appdata.bStatus;

cbData = get( tAttributes, 'ValueChangedCallbackData' );
rowNum = cbData.getRow;
prevStr = cbData.getPreviousValue;
varName = tAttributes.getCellData( rowNum, cbData.getColumn );

if cbData.getColumn == 0
if ~validate( varName )
warnStr = DAStudio.message( 'Simulink:dialog:InvalidVarMustBeMatVar', varName );
bStatus.setText( warnStr );
tAttributes.setCellData( rowNum, cbData.getColumn, prevStr );
end 

elseif cbData.getColumn == 1 &&  ...
~isempty( deblankall( tAttributes.getCellData( rowNum,  ...
2 ).getCurrentString ) )

tAttributes.getCellData( rowNum, 2 ).setCurrentString( '' );

elseif cbData.getColumn == 2 &&  ...
~isempty( deblankall( tAttributes.getCellData( rowNum, 2 ).getCurrentString ) )

storageClassText =  ...
lower( deblankall(  ...
tAttributes.getCellData( rowNum, 1 ).getCurrentString ) );
if ~isempty( findstr( storageClassText, 'auto' ) )
newText = '';
warnStr = DAStudio.message( 'Simulink:dialog:AttribHasSCCannotHaveStorageType',  ...
tAttributes.getCellData( rowNum, 0 ),  ...
'SimulinkGlobal (Auto)' );
bStatus.setText( warnStr );
tAttributes.getCellData( rowNum, 2 ).setCurrentString( newText );
end 
end 



varsInTable = GetExistingVarsInTable( tAttributes );

appdata.bApply.setEnabled( true );
tAttributes.deselectAll;








function vCommonGeom = commonGeomFcn





vCommonGeom.insets = java.awt.Insets( 5, 5, 5, 5 );


vCommonGeom.hGap = 3;
vCommonGeom.vGap = 5;








function valid = validate( var )
eval( [ var, '=[];valid=1;' ], 'valid=0;' )




function local_AddCallback( obj, name, command )


hCallbacks = handle( obj, 'CallbackProperties' );
set( hCallbacks, name, command );





% Decoded using De-pcode utility v1.2 from file /tmp/tmpeCR_nF.p.
% Please follow local copyright laws when handling this file.

