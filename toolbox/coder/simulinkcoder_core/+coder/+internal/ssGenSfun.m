function varargout = ssGenSfun( varargin )








persistent USERDATA
persistent REGMDLS
persistent cleanAtticOnCloseModel

if isempty( REGMDLS )
REGMDLS = {  };
end 


mlock

if nargin == 0
return ;
end 

action = varargin{ 1 };

switch action
case { 'Create', 'CreateNoMdlRefCheck' }

if slfeature( 'SfcnTargetDeprecationWarning' )
MSLDiagnostic( 'Simulink:protectedModel:SFcnTargetDeprecationWarning' ).reportAsWarning
end 



cleanAtticOnCloseModel = 1;
block = varargin{ 2 };
if ( nnz( ishandle( block ) ) == 0 )

try 
block_hdl = get_param( block, 'Handle' );
catch exc
LocalErrorExit(  - 1,  - 1, 'InvalidBlock', exc );
return ;
end 
else 
block_hdl = block;
end 

try 
if ( strcmpi( get_param( block_hdl, 'BlockType' ), 'SubSystem' ) == 0 )
LocalErrorExit( bdroot( block_hdl ),  - 1, 'NotSubsystem', [  ] );
return ;
end 
catch exc
LocalErrorExit( bdroot( block_hdl ),  - 1, 'NotSubsystem', exc );
return ;
end 

if strcmp( get_param( bdroot( block_hdl ), 'isObserverBD' ), 'on' )
LocalErrorExit( bdroot( block_hdl ),  - 1, 'ObserverNotSupported', [  ] );
end 

if matlab.internal.feature( "RemoveGenSFcnSubsystemUI" )









[ tmp_model, struc_ports, err ] = LocalCreate( block_hdl );
if ~err
block_mdl = coder.internal.Utilities.localBdroot( block_hdl );

onCleanupOrigAutoSaveOpt = RestoreAutoSaveOptions;%#ok

try 
all_Data = LocalFindAllParams( block_mdl, struc_ports );
catch exc
clear onCleanupOrigAutoSaveOpt;
rethrow( exc );
end 
clear onCleanupOrigAutoSaveOpt;
end 
USERDATA = apiLocalUpdateUserData( block_hdl, block_mdl,  ...
all_Data, struc_ports, tmp_model );
return 
end 

if ~usejava( 'awt' )
LocalErrorExit( bdroot( block_hdl ),  - 1, 'NeedsJava', [  ] );
return ;
end 


if ~LocalUIAlreadyExists( USERDATA, block_hdl )
[ tmp_model, struc_ports, err ] = LocalCreate( block_hdl );
if ~err
[ blk_mdl, mdlClose, REGMDLS ] = LocalRegisterCloseFcn( block_hdl, REGMDLS );



old_autosave_state = get_param( 0, 'AutoSaveOptions' );
new_autosave_state = old_autosave_state;
new_autosave_state.SaveOnModelUpdate = 0;
set_param( 0, 'AutoSaveOptions', new_autosave_state );
try 
data = LocalFindAllParams( blk_mdl, struc_ports );
catch exc
set_param( 0, 'AutoSaveOptions', old_autosave_state );
rethrow( exc );
end 
set_param( 0, 'AutoSaveOptions', old_autosave_state );
gui = LocalCreateUI( data, block_hdl, blk_mdl );
end 
USERDATA = LocalUpdateUserData( USERDATA, block_hdl, blk_mdl, mdlClose,  ...
tmp_model, data, gui, struc_ports );
end 
case 'Cancel'



userdata = LocalRetrieveThisUserData( USERDATA, gcbo, 'CANCEL_BUTTON' );
try 
LocalCancel( userdata, 0 );

rtwprivate( 'rtwattic', 'clean' );
catch exc %#ok<NASGU>
end 
USERDATA = LocalBlankUserData( USERDATA, userdata );
case { 'Build', 'BuildERT' }
if matlab.internal.feature( "RemoveGenSFcnSubsystemUI" )






assert( ~isempty( USERDATA ), '"Create" must be called before "Build"' );

tmpData = USERDATA( end  );
try 
blkMdl = tmpData.BLK_MDL;
blkHdl = tmpData.BLK_HDL;


processor_callback = coder.connectivity.XilSimModelNameCorrector ...
( '', blkMdl );


model_name_processor_REQUIRED = Simulink.output.registerProcessor( processor_callback, 'Event', 'ALL' );%#ok

useSILBlock = false;

if LocalHasModelRefBlks( blkHdl )
useSILBlock = true;
end 
onCleanupOrigSc = apiLocalPreBuild(  ...
useSILBlock, tmpData.ALL_DATA,  ...
tmpData.TMP_MODEL, blkHdl, blkMdl,  ...
strcmp( action, 'BuildERT' ) );
apiLocalBuild( tmpData.TMP_MODEL, blkHdl, tmpData.STRUC_PORTS,  ...
onCleanupOrigSc );

clear processor_callback;
clear model_name_processor_REQUIRED;
catch exc %#ok<NASGU>
tmpData.TMP_MODEL = [  ];
end 
delete( onCleanupOrigSc );
close_system( tmpData.TMP_MODEL, 0 );
USERDATA = [  ];
return ;
end 

cleanAtticOnCloseModel = 0;
userdata = LocalRetrieveThisUserData( USERDATA, gcbo, 'BUILD_BUTTON' );
try 
cancel = userdata.GUI.CANCEL_BUTTON;
cancel.setEnabled( 0 );
build = userdata.GUI.BUILD_BUTTON;
build.setEnabled( 0 );
help = userdata.GUI.HELP_BUTTON;
help.setEnabled( 0 );
useert = userdata.GUI.ERT_CHKBOX;
useert.setEnabled( 0 );
paramlist = userdata.GUI.PARAM_LIST;
colstyle = paramlist.getColumnStyle( 2 );
colstyle.setEditable( 0 );
paramlist.setColumnStyle( 2, colstyle );
hparamlist = handle( paramlist, 'callbackproperties' );
set( hparamlist, 'ItemStateChangedCallback', '' );

frame = handle( userdata.GUI.FRAME, 'callbackproperties' );
hframe = handle( frame, 'callbackproperties' );
set( hframe, 'WindowClosingCallback', '' );
fStatus = userdata.GUI.STATUS_BAR;
fStatus.setText( 'Building ....' );


processor_callback = coder.connectivity.XilSimModelNameCorrector ...
( '', userdata.BLK_MDL );


model_name_processor_REQUIRED = Simulink.output.registerProcessor( processor_callback, 'Event', 'ALL' );%#ok

LocalBuild( userdata.GUI, userdata.TMP_MODEL,  ...
userdata.BLK_HDL, userdata.STRUC_PORTS, strcmp( action, 'BuildERT' ) );

clear processor_callback;
clear model_name_processor_REQUIRED;
catch exc %#ok<NASGU>
userdata.TMP_MODEL = [  ];
end 
try 
LocalCancel( userdata, 0 );
catch exc %#ok<NASGU>
end 
USERDATA = LocalBlankUserData( USERDATA, userdata );
case 'CloseWindow'

userdata = LocalRetrieveThisUserData( USERDATA, gcbo, 'FRAME' );
try 
LocalCancel( userdata, 0 );


rtwprivate( 'rtwattic', 'clean' );
catch exc %#ok<NASGU>
end 
USERDATA = LocalBlankUserData( USERDATA, userdata );
case 'ModelCloseRequest'
USERDATA = LocalCloseAllMdlDlgs( USERDATA, varargin{ 2 } );
REGMDLS = REGMDLS( ~ismember( REGMDLS, varargin{ 2 } ) );





if cleanAtticOnCloseModel
rtwprivate( 'rtwattic', 'clean' );
end 
case 'ChoiceChanged'

userdata = LocalRetrieveThisUserData( USERDATA, gcbo, 'PARAM_LIST' );
LocalChangeChoice( userdata.GUI, userdata.DATA );
case 'GetErrorMsgTxtForID'

varargout{ 1 } = LocalRetrieveErrorText( varargin{ 2 }, [  ] );
case 'GetDialogData'
varargout{ 1 } = USERDATA;
varargout{ 2 } = REGMDLS;
otherwise 
DAStudio.error( 'RTW:utility:UnknownAction', 'ssGenSfun' );
end 

return ;






function [ mdl_hdl, struc_ports, error_occ ] = LocalCreate( block_hdl )



error_occ = 0;%#ok
block_mdl = get_param( bdroot( block_hdl ), 'Name' );



if DeploymentDiagram.isConcurrentTasks( block_mdl )
LocalErrorExit(  - 1, block_mdl, 'GenerateSFcnConcurrentExecution', [  ] );
error_occ = 1;
return ;
end 



hasSimulinkFunction = ~isempty( find_system( block_hdl, 'SystemType', 'SimulinkFunction' ) );
if hasSimulinkFunction
LocalErrorExit(  - 1, block_mdl, 'GenerateSFcnHasSimulinkFunction', [  ] )
end 



hasReinitPort = strcmp( get_param( block_hdl, 'ShowSubsystemReinitializePorts' ), 'on' );
if hasReinitPort
LocalErrorExit(  - 1, block_mdl, 'GenerateSFcnHasReinitializePorts', [  ] )
end 


hasMdlRefBlks = LocalHasModelRefBlks( block_hdl );
if hasMdlRefBlks
if ~( ecoderinstalled(  ) && coder.internal.buildUtils( 'IsUsingERT', block_mdl ) )
LocalErrorExit(  - 1, block_mdl, 'ModelRefNeedsERT', [  ] );
error_occ = 1;
return ;
end 
end 


rtwprivate( 'rtwattic', 'createSIDMap' );
[ mdl_hdl, struc_ports, error_occ, mExc ] = coder.internal.ss2mdl( block_hdl, 'GenerateSFunction', true );
struc_ports.GenerateSFunction = true;

if error_occ
LocalErrorExit( block_mdl, mdl_hdl, 'BuildFailed', mExc );
end 



if ( hasMdlRefBlks && ~LocalCanUseERT( block_hdl ) )
LocalErrorExit(  - 1, block_mdl, 'ModelRefNeedsERTButItCantBeUsed', [  ] );
error_occ = 1;
return ;
end 




try 
if strcmp( get_param( mdl_hdl, 'SaveFormat' ), 'Array' ) == 1
set_param( mdl_hdl, 'SaveFormat', 'Structure' );
end 
set_param( mdl_hdl, 'DefaultParameterBehavior', 'Inlined' );
catch exc
LocalErrorExit( block_mdl, mdl_hdl, 'CannotSetRTWParams', exc );
error_occ = 1;
return ;
end 


function LocalBuild( gui, model, origBlk, struc_ports, buildERT )






param_list = gui.PARAM_LIST;
ertChkBox = gui.ERT_CHKBOX;
list_data = param_list.getData;
num_data = list_data.getHeight;
var_name_str = '';
var_stor_class = '';
var_qual = '';
num_added = 0;
objval = {  };

try 
for row = 0:( num_data - 1 )
object = list_data.getData( row, 0 );
var_name = get( object, 'Label' );
cellData = list_data.getData( row, 2 );
if ~isempty( cellData )

if ~ischar( cellData )
if cellData
cellData = 'Tunable';
else 
cellData = 'Inlined';
end 
end 

var = evalinGlobalScope( model, var_name );
switch cellData
case 'Tunable'

if isa( var, 'Simulink.Parameter' )
value = var.StorageClass;
objval{ end  + 1 } = { var_name, value };%#ok
var.StorageClass = Simulink.data.getNameForModelDefaultSC;
else 
if num_added == 0
var_name_str = var_name;
var_stor_class = 'Auto';
var_qual = '';
else 
var_name_str = strcat( var_name_str, ',', var_name );
var_stor_class = strcat( var_stor_class, ',', 'Auto' );
var_qual = strcat( var_qual, ',' );
end 
num_added = num_added + 1;
end 
case 'Inlined'
if isa( var, 'Simulink.Parameter' )
value = var.StorageClass;
objval{ end  + 1 } = { var_name, value };%#ok
var.StorageClass = 'Auto';
end 
case 'Macro'


assert( isa( var, 'Simulink.Parameter' ) );
otherwise 
assert( false, 'Unexpected value in tunability column' );
end 
end 
end 
catch exc
RestoreSimulinkParameters( model, objval );
sldiagviewer.reportInfo( exc.message );
LocalErrorExit(  - 1, model, 'BuildFailed', exc );
return ;
end 

try 
coder.internal.buildUtils( 'SetupModelForSFunctionGeneration', model,  ...
ertChkBox.getState || buildERT );
catch exc
LocalErrorExit(  - 1, model, 'CannotSetRTWParams', exc );
return ;
end 

set_param( model,  ...
'TunableVars', var_name_str,  ...
'TunableVarsStorageClass', var_stor_class,  ...
'TunableVarsTypeQualifier', var_qual );
set_param( 0, 'CurrentSystem', model );






old_autosave_state = get_param( 0, 'AutoSaveOptions' );
new_autosave_state = old_autosave_state;
new_autosave_state.SaveOnModelUpdate = 0;
set_param( 0, 'AutoSaveOptions', new_autosave_state );



subsystemBuildCleanup = coder.internal.SubsystemBuild.create( origBlk, model );

try 



sl( 'slbuild_private', model, 'StandaloneCoderTarget',  ...
'ForceTopModelBuild', true,  ...
'OkayToPushNags', true );
catch exc
if ( isequal( exc.identifier, 'Simulink:slbuild:topChildMdlParamMismatch' ) )
origModelName = get_param( bdroot( origBlk ), 'Name' );
newModelName = get_param( model, 'Name' );
newIdentifier = 'Simulink:slbuild:generateSFuncModelRefParamMismatch';
newMessage = DAStudio.message( newIdentifier, origModelName,  ...
origModelName, origModelName, newModelName );
newException = MException( newIdentifier, '%s', newMessage );

exc = newException.addCause( exc );
end 

set_param( 0, 'AutoSaveOptions', old_autosave_state );
RestoreSimulinkParameters( model, objval );

LocalMapErrorToOrigModel( origBlk, model, exc );
LocalErrorExit(  - 1, model, 'BuildFailed', exc );
return ;
end 


delete( subsystemBuildCleanup )

set_param( 0, 'AutoSaveOptions', old_autosave_state );

RestoreSimulinkParameters( model, objval );


rootSFunName = get_param( model, 'name' );
try 
coder.internal.ssGenSfunPost( rootSFunName, origBlk, struc_ports );
catch exc %#ok

return ;
end 


function RestoreSimulinkParameters( model, objval )
if ~isempty( objval )
for i = 1:length( objval )
var = evalinGlobalScope( model, objval{ i }{ 1 } );
var.CoderInfo.StorageClass = objval{ i }{ 2 };
end 
end 


function onCleanupOrigAutoSaveOpt = RestoreAutoSaveOptions


old_autosave_state = get_param( 0, 'AutoSaveOptions' );
new_autosave_state = old_autosave_state;
new_autosave_state.SaveOnModelUpdate = 0;
set_param( 0, 'AutoSaveOptions', new_autosave_state );
onCleanupOrigAutoSaveOpt = onCleanup(  ...
@(  )set_param( 0, 'AutoSaveOptions', old_autosave_state ) );


function onCleanupOrigSc = apiLocalPreBuild( useSILBlock,  ...
paramsModel, model, origBlkHdl, topMdl, buildERT )



R36
useSILBlock( 1, 1 )logical
paramsModel struct
model( 1, 1 )double
origBlkHdl( 1, 1 )double
topMdl( 1, : )char
buildERT( 1, 1 )logical
end 


if isempty( paramsModel )
paramsModel = {  };
else 
paramsModel = { paramsModel( : ).Name };
end 

tunableVars = get_param( topMdl, 'TunableVars' );
hasMdlRefBlks = LocalHasModelRefBlks( origBlkHdl );

numParams = numel( paramsModel );
paramVarNameStr = cell( numParams, 1 );
paramStorageClass = cell( numParams, 1 );
paramTypeQualifier = cell( numParams, 1 );
isValidIdx = false( numParams, 1 );
paramOrigSc = cell( numParams, 1 );
paramOrigScIdx = false( numParams, 1 );

for i = 1:numParams
paramName = paramsModel{ i };

var = evalinGlobalScope( model, paramName );
if isa( var, 'Simulink.Parameter' )
sc = var.CoderInfo.StorageClass;
if ~strcmp( sc, 'Auto' )
if strcmp( sc, 'Custom' )

cscDefn =  ...
processcsc( 'GetCSCDefn', var.CSCPackageName, var.CoderInfo.CustomStorageClass );
if isMacro( cscDefn, var )



continue 
end 
end 

paramOrigSc{ i } = { paramName, sc };
paramOrigScIdx( i ) = true;
var.CoderInfo.StorageClass = Simulink.data.getNameForModelDefaultSC;
end 
else 
if contains( tunableVars, paramName ) && ~hasMdlRefBlks



paramVarNameStr{ i } = paramName;
paramStorageClass{ i } = 'Auto';
paramTypeQualifier{ i } = '';
isValidIdx( i ) = true;
end 
end 
end 

paramVarNameStr = paramVarNameStr( isValidIdx );
paramStorageClass = paramStorageClass( isValidIdx );
paramTypeQualifier = paramTypeQualifier( isValidIdx );
paramVarNameStr = char( join( cellstr( paramVarNameStr ), ", " ) );
paramStorageClass = char( join( cellstr( paramStorageClass ), ", " ) );
paramTypeQualifier = char( join( cellstr( paramTypeQualifier ), ", " ) );
paramOrigSc = paramOrigSc( paramOrigScIdx );

onCleanupOrigSc = onCleanup(  ...
@(  )RestoreSimulinkParameters( model, paramOrigSc ) );

try 


coder.internal.buildUtils( 'SetupModelForSFunctionGeneration', model,  ...
useSILBlock || buildERT );
catch exc

delete( onCleanupOrigSc );

LocalErrorExit(  - 1, model, 'CannotSetRTWParams', exc );
return ;
end 

set_param( model,  ...
'TunableVars', paramVarNameStr,  ...
'TunableVarsStorageClass', paramStorageClass,  ...
'TunableVarsTypeQualifier', paramTypeQualifier );
set_param( 0, 'CurrentSystem', model );


function apiLocalBuild( model, origBlk, struc_ports, onCleanupOrigSc )





onCleanupOrigAutoSaveOpt = RestoreAutoSaveOptions;%#ok





subsystemBuildCleanup = coder.internal.SubsystemBuild.create( origBlk, model );

try 



sl( 'slbuild_private', model, 'StandaloneCoderTarget',  ...
'ForceTopModelBuild', true,  ...
'OkayToPushNags', true );
catch exc
if ( isequal( exc.identifier, 'Simulink:slbuild:topChildMdlParamMismatch' ) )
origModelName = get_param( bdroot( origBlk ), 'Name' );
newModelName = get_param( model, 'Name' );
newIdentifier = 'Simulink:slbuild:generateSFuncModelRefParamMismatch';
newMessage = DAStudio.message( newIdentifier, origModelName,  ...
origModelName, origModelName, newModelName );
newException = MException( newIdentifier, '%s', newMessage );

exc = newException.addCause( exc );
end 

clear onCleanupOrigAutoSaveOpt;

delete( onCleanupOrigSc );


LocalMapErrorToOrigModel( origBlk, model, exc );
LocalErrorExit(  - 1, model, 'BuildFailed', exc );
return ;
end 


delete( subsystemBuildCleanup )

clear onCleanupOrigAutoSaveOpt;


rootSFunName = get_param( model, 'name' );
try 
coder.internal.ssGenSfunPost( rootSFunName, origBlk, struc_ports );
catch exc %#ok

return ;
end 


function errtext = LocalMapErrorToOrigModel( origBlk, model, exc )





excList = { exc };
while ~isempty( excList )
curExc = excList{ 1 };
try 
hdls = curExc.handles{ 1 };
catch 
hdls = [  ];
end 
msg = curExc.message;
for i = 1:length( hdls )
if isequal( get_param( hdls( i ), 'type' ), 'block' )
if isequal( bdroot( hdls( i ) ), bdroot( model ) )
oldName = getfullname( hdls( i ) );
[ ~, newName ] = strtok( oldName, '/' );
newName = strcat( get_param( origBlk, 'Parent' ), newName );
userData = get_param( hdls( i ), 'UserData' );
if ( ~isempty( userData ) &&  ...
isfield( userData, 'OriginalBlock' ) &&  ...
~isempty( userData.OriginalBlock ) )

newName = getfullname( userData.OriginalBlock );
end 
root = get_param( 0, 'Object' );
if root.isValidSlObject( newName )
oldName = strrep( oldName, newline, ' ' );
newName = strrep( newName, newline, ' ' );
msg =  ...
strrep( curExc.message, oldName, newName );
end 
end 
end 
end 
nag = slprivate( 'create_nag', 'Simulink', 'Error', 'Build',  ...
msg, curExc.identifier, bdroot( origBlk ) );
aObjects = { nag.sourceFullName };
for i = 1:length( nag )
sldiagviewer.reportError( nag( i ).msg.details, 'MessageId', nag( i ).msg.identifier, 'Component', 'Simulink', 'Category', 'Build', 'Objects', aObjects );
end 


excList = [ excList( 2:end  );excList{ 1 }.cause ];
end 

errtext = exc.message;


function LocalCancel( userdata, bPerformCloseReq )




gui = userdata.GUI;
model = userdata.TMP_MODEL;
blkHdl = userdata.BLK_HDL;

try 

build = gui.BUILD_BUTTON;
hbuild = handle( build, 'callbackproperties' );
set( hbuild, 'ActionPerformedCallback', '' );
cancel = gui.CANCEL_BUTTON;
hcancel = handle( cancel, 'callbackproperties' );
set( hcancel, 'ActionPerformedCallback', '' );
helpb = gui.HELP_BUTTON;
hhelpb = handle( helpb, 'callbackproperties' );
set( hhelpb, 'ActionPerformedCallback', '' );
paramlist = gui.PARAM_LIST;
hparamlist = handle( paramlist, 'callbackproperties' );
set( hparamlist, 'ItemStateChangedCallback', '' );

frame = gui.FRAME;
hframe = handle( frame, 'callbackproperties' );
set( hframe, 'WindowClosingCallback', '' );

frame = gui.FRAME;
frame.dispose;


rtwprivate( 'rtwattic', 'deleteSIDMap' );

close_system( model, 0 );
catch exc %#ok<NASGU>
end 



function udata = LocalCloseAllMdlDlgs( userdata, modelName )




udata = userdata;

for i = 1:length( userdata )
if strcmp( userdata( i ).BLK_MDL, modelName ) == 1
try 
LocalCancel( userdata( i ), 1 );
catch exc %#ok<NASGU>
end 
udata = LocalBlankUserData( udata, userdata( i ) );
end 
end 


function LocalErrorExit( origModel, newModel, errorCode, exc )



if ishandle( origModel )
mdlName = get_param( origModel, 'Name' );
if isequal( get_param( mdlName, 'SimulationStatus' ), 'paused' )
feval( mdlName, [  ], [  ], [  ], 'term' );
end 
end 


rtwprivate( 'rtwattic', 'deleteSIDMap' );

if ishandle( newModel )
close_system( newModel, 0 );
end 


if isempty( exc )
[ errText, errID ] = LocalRetrieveErrorText( errorCode, exc );
newExc = MException( errID, errText );
throw( newExc );
else 
if isempty( exc.stack )
throw( exc );
else 
rethrow( exc );
end 
end 


function [ errorText, errID ] = LocalRetrieveErrorText( errorCode, exc )



errID = [ 'RTW:buildProcess:', errorCode ];
switch errorCode
case 'InvalidBlock'
errorText = DAStudio.message( errID, 'ssGenSfun' );
case 'NotSubsystem'
errorText = DAStudio.message( errID, 'S-function' );
case 'CannotSetRTWParams'
errorText = DAStudio.message( errID, 'S-function' );
case 'CannotFindSFunction'
errorText = DAStudio.message( errID );
case 'NoMakeCmd'
errorText = DAStudio.message( errID );
case 'ModelRefNeedsERT'
errorText = DAStudio.message( errID );
case 'ModelRefNeedsERTButItCantBeUsed'
errorText = DAStudio.message( errID );
case 'BuildFailed'
if isempty( exc )
errID = 'RTW:utility:UnknownError';
errorText = DAStudio.message( errID );
else 
errID = exc.identifier;
errorText = exc.message;
end 
case 'NeedsJava'
errorText = DAStudio.message( errID, 'S-function' );
case { 'GenerateSFcnConcurrentExecution',  ...
'GenerateSFcnHasSimulinkFunction',  ...
'GenerateSFcnHasReinitializePorts' }
errorText = DAStudio.message( errID );
case 'ObserverNotSupported'
errorText = DAStudio.message( errID, 'S-function' );
otherwise 
errID = 'RTW:utility:UnknownError';
errorText = DAStudio.message( errID );
end 







function fgui = LocalCreateUI( all_Data, block_hdl, block_mdl )




bECoder = ( ecoderinstalled(  ) && LocalCanUseERT( block_hdl ) );


if isempty( all_Data )
data = {  };
else 
data = { all_Data( : ).Name };
end 

tunableVars = get_param( block_mdl, 'TunableVars' );


import java.awt.*;
import com.mathworks.mwt.*;
import com.mathworks.mwt.table.*;


frameTitle = DAStudio.message ...
( 'RTW:buildProcess:GenerateSFcnSubsystemTitle',  ...
strrep( get_param( block_hdl, 'Name' ), sprintf( '\n' ), ' ' ) );
fFrame = MWFrame;
fFrame.setLayout( BorderLayout );
fFrame.setBounds( com.mathworks.util.ResolutionUtils.scaleSize( 200 ),  ...
com.mathworks.util.ResolutionUtils.scaleSize( 200 ),  ...
com.mathworks.util.ResolutionUtils.scaleSize( 650 ),  ...
com.mathworks.util.ResolutionUtils.scaleSize( 400 ) );
fFrame.setTitle( frameTitle );
hfFrame = handle( fFrame, 'callbackproperties' );
set( hfFrame, 'WindowClosingCallback', 'coder.internal.ssGenSfun(''CloseWindow'')' );


imageToolkit = java.awt.Toolkit.getDefaultToolkit;
slIcon = imageToolkit.createImage( toolpack.component.Icon.SIMULINK_16.Description );
fFrame.setIconImage( slIcon );

fParamPanel = MWGroupbox( DAStudio.message( 'RTW:buildProcess:PickTunablePrm' ) );
fParamPanel.setLayout( BorderLayout );
fParam = MWListbox;
fParam.setColumnCount( 3 );
fParam.setColumnHeaderData( 0, DAStudio.message( 'RTW:buildProcess:VarName' ) );
fParam.setColumnWidth( 0, com.mathworks.util.ResolutionUtils.scaleSize( 250 ) );
fParam.setColumnHeaderData( 1, DAStudio.message( 'RTW:buildProcess:Class' ) );
fParam.setColumnWidth( 1, com.mathworks.util.ResolutionUtils.scaleSize( 150 ) );
fParam.setColumnHeaderData( 2, DAStudio.message( 'RTW:buildProcess:Tunable' ) );
fParam.setMinAutoExpandColumnWidth( com.mathworks.util.ResolutionUtils.scaleSize( 30 ) );
fParam.getColumnOptions.setHeaderVisible( 1 );
fParam.getTableStyle.setHGridVisible( 1 );
fParam.getTableStyle.setVGridVisible( 1 );
fParam.getColumnOptions.setResizable( 1 );


lengthData = length( data );
if ( lengthData < 7 )
fParam.getData.setHeight( 7 );
else 
fParam.getData.setHeight( lengthData );
end 

fullpathstr1 = fullfile( matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'MatlabArray.png' );
fullpathstr2 = fullfile( matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'BlockIcon.png' );


hasMdlRefBlks = LocalHasModelRefBlks( block_hdl );
for i = 1:lengthData
var = evalinGlobalScope( block_mdl, data{ i } );
if isa( var, 'Simulink.Parameter' )
storageClass = var.CoderInfo.StorageClass;
if strcmp( storageClass, 'Auto' )
b = java.lang.Boolean( 0 );
elseif strcmp( storageClass, 'Custom' )

cscDefn = processcsc( 'GetCSCDefn', var.CSCPackageName, var.CoderInfo.CustomStorageClass );
if isMacro( cscDefn, var )
b = 'Macro';
else 
b = java.lang.Boolean( 1 );
end 
else 
b = java.lang.Boolean( 1 );
end 
d = LabeledImageResource( fullpathstr2, data{ i } );
else 
if hasMdlRefBlks

b = 'Inlined';
else 
if isempty( findstr( tunableVars, data{ i } ) )
b = java.lang.Boolean( 0 );
else 
b = java.lang.Boolean( 1 );
end 
end 
d = LabeledImageResource( fullpathstr1, data{ i } );
end 

fParam.setCellData( i - 1, 0, d );
fParam.setCellData( i - 1, 1, class( var ) );
fParam.setCellData( i - 1, 2, b );
end 


styleLoc = 'com.mathworks.mwt.table.Style';
col1Style = Style( java_field( styleLoc, 'H_ALIGNMENT' ) );
col1Style.setHAlignment( java_field( styleLoc, 'H_ALIGN_CENTER' ) );
fParam.setColumnStyle( 1, col1Style );

col2Style = Style( java_field( styleLoc, 'EDITABLE' ) +  ...
java_field( styleLoc, 'H_ALIGNMENT' ) );
col2Style.setEditable( 1 );
col2Style.setHAlignment( java_field( styleLoc, 'H_ALIGN_CENTER' ) );
fParam.setColumnStyle( 2, col2Style );


fParamPanel.add( fParam, java_field( 'java.awt.BorderLayout', 'CENTER' ) );
hfParam = handle( fParam, 'callbackproperties' );
set( hfParam, 'ItemStateChangedCallback', 'coder.internal.ssGenSfun(''ChoiceChanged'')' );
fParamPanel.setInsets( Insets( 5, 5, 5, 5 ) );


fBlockPanel = MWGroupbox( DAStudio.message( 'RTW:buildProcess:BlockVarUse' ) );
fBlockPanel.setLayout( BorderLayout );
fBlock = MWListbox;
fBlock.setColumnCount( 2 );
fBlock.setColumnHeaderData( 0, DAStudio.message( 'RTW:buildProcess:Block' ) );
fBlock.setColumnWidth( 0, com.mathworks.util.ResolutionUtils.scaleSize( 180 ) );
fBlock.setColumnHeaderData( 1, DAStudio.message( 'RTW:buildProcess:Parent' ) );
fBlock.setColumnWidth( 1, 180 );
fBlock.setColumnWidth( 0, com.mathworks.util.ResolutionUtils.scaleSize( 180 ) );
fBlock.getColumnOptions.setHeaderVisible( 1 );
fBlock.getTableStyle.setHGridVisible( 1 );
fBlock.getTableStyle.setVGridVisible( 1 );
fBlock.getColumnOptions.setResizable( 1 );
fBlock.getData.setHeight( 3 );
fBlockPanel.add( fBlock, java_field( 'java.awt.BorderLayout', 'CENTER' ) );
fBlockPanel.setInsets( Insets( 5, 5, 5, 5 ) );


fPanel = MWSplitter;
fPanel.add( fParamPanel );
fPanel.add( fBlockPanel );
fPanel.setDividerLocation( 0.65 );
fPanel.setDividerDark( 1 );


fButtonPanel = MWPanel;
fButtonPanel.setLayout( FlowLayout( java_field( 'java.awt.FlowLayout', 'RIGHT' ) ) );
fBuild = MWButton( DAStudio.message( 'RTW:buildProcess:Build' ) );
fCancel = MWButton( DAStudio.message( 'RTW:buildProcess:Cancel' ) );
fHelp = MWButton( DAStudio.message( 'RTW:buildProcess:Help' ) );
hfBuild = handle( fBuild, 'callbackproperties' );
subsys_mdl_name = get_param( bdroot( block_hdl ), 'Name' );
set( hfBuild, 'ActionPerformedCallback', [ 'slInternal MV_ui_subsys_build_cmd_wrapper ' ...
, subsys_mdl_name, ' coder.internal.ssGenSfun Build' ] );
hfCancel = handle( fCancel, 'callbackproperties' );
set( hfCancel, 'ActionPerformedCallback', 'coder.internal.ssGenSfun(''Cancel'')' );
hfHelp = handle( fHelp, 'callbackproperties' );
set( hfHelp, 'ActionPerformedCallback',  ...
'helpview([docroot ''/toolbox/rtw/helptargets.map''], ''rtw_auto_sfun_gen'')' );
fButtonPanel.add( fBuild );
fButtonPanel.add( fCancel );
fButtonPanel.add( fHelp );


fEnablePanel = MWPanel;
fEnablePanel.setLayout( FlowLayout( java_field( 'java.awt.FlowLayout', 'LEFT' ) ) );
fERTChkBox = MWCheckbox(  ...
DAStudio.message( 'RTW:buildProcess:RightClickCreateSILBlock' ) );
fERTChkBox.setEnabled( bECoder );


if hasMdlRefBlks
fERTChkBox.setState( true );
fERTChkBox.setEnabled( false );
end 
fEnablePanel.add( fERTChkBox );


fStatusPanel = MWGroupbox( DAStudio.message( 'RTW:buildProcess:StatusPanelGroup' ) );
fStatusPanel.setLayout( BorderLayout );
fStatus = MWLabel( DAStudio.message( 'RTW:buildProcess:SelectAndBuild' ) );
fStatusPanel.add( fStatus, java_field( 'java.awt.BorderLayout', 'CENTER' ) );
fStatusPanel.setInsets( Insets( 5, 5, 5, 5 ) );


fBottomPanel = MWPanel;
fBottomPanel.setLayout( BorderLayout );
fBottomPanel.add( fButtonPanel, java_field( 'java.awt.BorderLayout', 'EAST' ) );
fBottomPanel.add( fEnablePanel, java_field( 'java.awt.BorderLayout', 'WEST' ) );
fBottomPanel.add( fStatusPanel, java_field( 'java.awt.BorderLayout', 'SOUTH' ) );
fBottomPanel.setInsets( Insets( 3, 3, 3, 3 ) );


scaledFont = com.mathworks.util.ResolutionUtils.scaleSize( 100 );
uiFontScale = scaledFont / 100;
font = fParam.getFont;
fParam.setFont( font.deriveFont( font.getSize * uiFontScale ) );
font = fPanel.getFont;
fPanel.setFont( font.deriveFont( font.getSize * uiFontScale ) );
font = fBlockPanel.getFont;
fBlockPanel.setFont( font.deriveFont( font.getSize * uiFontScale ) );
font = fBlock.getFont;
fBlock.setFont( font.deriveFont( font.getSize * uiFontScale ) );
font = fBuild.getFont;
fBuild.setFont( font.deriveFont( font.getSize * uiFontScale ) );
font = fCancel.getFont;
fCancel.setFont( font.deriveFont( font.getSize * uiFontScale ) );
font = fHelp.getFont;
fHelp.setFont( font.deriveFont( font.getSize * uiFontScale ) );
font = fStatus.getFont;
fStatus.setFont( font.deriveFont( font.getSize * uiFontScale ) );
font = fStatusPanel.getFont;
fStatusPanel.setFont( font.deriveFont( font.getSize * uiFontScale ) );
font = fParamPanel.getFont;
fParamPanel.setFont( font.deriveFont( font.getSize * uiFontScale ) );
font = fEnablePanel.getFont;
fEnablePanel.setFont( font.deriveFont( font.getSize * uiFontScale ) );
font = fERTChkBox.getFont;
fERTChkBox.setFont( font.deriveFont( font.getSize * uiFontScale ) );



fFrame.add( fPanel, java_field( 'java.awt.BorderLayout', 'CENTER' ) );
fFrame.add( fBottomPanel, java_field( 'java.awt.BorderLayout', 'SOUTH' ) );
fFrame.show;


fgui.FRAME = fFrame;
fgui.PARAM_LIST = fParam;
fgui.SPLITTER_PANEL = fPanel;
fgui.BLOCK_PANEL = fBlockPanel;
fgui.BLOCK_LIST = fBlock;
fgui.BUILD_BUTTON = fBuild;
fgui.CANCEL_BUTTON = fCancel;
fgui.HELP_BUTTON = fHelp;
fgui.STATUS_BAR = fStatus;
fgui.ERT_CHKBOX = fERTChkBox;


function out = java_field( className, fieldName )

obj = javaObject( className );
s = struct( obj );
out = s.( fieldName );



function params = LocalFindAllParams( blk_mdl, struc_ports )



if isempty( struc_ports )
params = [  ];
else 
params = struc_ports.referencedWSVars;
if ~isempty( params )
paramNames = { params.Name }';

validWSVars = {  };
dataAccessor = Simulink.data.DataAccessor.createForExternalData( blk_mdl );
classes = { 'single', 'double', 'Simulink.IntEnumType', 'Simulink.Parameter' };
for i = 1:length( classes )
varIds = dataAccessor.identifyVisibleVariablesDerivedFromClass( classes{ i } );
if ~isempty( varIds )
validWSVars = [ validWSVars, varIds.Name ];
end 
end 
validWSVars = validWSVars';


[ ~, idx ] = intersect( paramNames, validWSVars );
params = params( idx );
end 
end 


function LocalChangeChoice( gui, data )



import com.mathworks.mwt.table.LabeledImageResource;

if isempty( data );return ;end 

param_list = gui.PARAM_LIST;
row = param_list.getFirstSelectedRow;
list_data = param_list.getData;
object = list_data.getData( row, 0 );
name = get( object, 'Label' );
block_panel = gui.BLOCK_PANEL;
block_panel.setLabel( DAStudio.message( 'RTW:buildProcess:BlockPanelLabel', name ) );

block_list = gui.BLOCK_LIST;
block_list.removeAllItems;

block_info = LocalGetBlockInfo( data, row + 1 );
block_list.getData.setHeight( length( block_info ) );
blockgif = '/com/mathworks/toolbox/simulink/finder/resources/block.gif';
for i = 1:length( block_info )
this_info = block_info{ i };
blk_im = LabeledImageResource( blockgif,  ...
strrep( this_info{ 1 }, sprintf( '\n' ), ' ' ) );
block_list.setCellData( i - 1, 0, blk_im );
block_list.setCellData( i - 1, 1, strrep( this_info{ 2 }, sprintf( '\n' ), ' ' ) );
end 


function params = LocalGetBlockInfo( data, idx )



params = {  };
if idx > length( data ), return ;end 
this_info = data( idx );
nElements = length( this_info.ReferencedBy );
this_param{ 2 } = '';
params{ nElements } = {  };
for i = 1:nElements
this_param{ 1 } = get_param( this_info.ReferencedBy( i ), 'Name' );
this_param{ 2 } = get_param( this_info.ReferencedBy( i ), 'Parent' );
params{ i } = this_param;%#ok<AGROW>
end 


function userdata = LocalUpdateUserData( userdata, block_hdl, blk_model,  ...
mdlClose, tmp_model, data, gui,  ...
struc_ports )





newdata.BLK_HDL = block_hdl;
newdata.BLK_MDL = blk_model;
newdata.MDL_CLOSE = mdlClose;
newdata.TMP_MODEL = tmp_model;
newdata.DATA = data;
newdata.GUI = gui;
newdata.STRUC_PORTS = struc_ports;

if isempty( userdata )
userdata = newdata;
else 
userdata( end  + 1 ) = newdata;
end 


function userdata = apiLocalUpdateUserData( block_hdl, block_mdl,  ...
all_data, struc_ports, tmp_model )



newdata.BLK_HDL = block_hdl;
newdata.BLK_MDL = block_mdl;
newdata.ALL_DATA = all_data;
newdata.STRUC_PORTS = struc_ports;
newdata.TMP_MODEL = tmp_model;
userdata = newdata;


function udata = LocalRetrieveThisUserData( userdata, java_hdl, fieldname )



if isempty( java_hdl )
ind = 1;
else 
for i = 1:length( userdata )
gui = userdata( i ).GUI;
uifield = gui.( fieldname );
if ishandle( uifield )
h = handle( uifield, 'callbackProperties' );
else 
h = [  ];
end 
if ( h == java_hdl )
ind = i;
break ;
end 
end 
end 
udata = userdata( ind );


function exists = LocalUIAlreadyExists( userdata, block_hdl )

if isempty( userdata )
exists = 0;
return ;
end 

exists = 0;
for i = 1:length( userdata )
udata = userdata( i );

udata.GUI.FRAME.show;
if ( udata.BLK_HDL == block_hdl )
exists = 1;
return ;
end 
end 


function udata = LocalBlankUserData( userdata, udata1 )
ind = 0;
for i = 1:length( userdata )
thisdata = userdata( i );
if ( thisdata.BLK_HDL == udata1.BLK_HDL )
ind = i;
break ;
end 
end 

udata = [ userdata( 1:( ind - 1 ) ), userdata( ( ind + 1 ):end  ) ];



function [ blkMdl, mdlClose, regMdls ] = LocalRegisterCloseFcn( blkHdl, regMdls )

blkMdl = coder.internal.Utilities.localBdroot( blkHdl );

mdlCloseCallback =  ...
sprintf( 'coder.internal.ssGenSfun(''ModelCloseRequest'', ''%s'')', blkMdl );




oldMdlCloseCallback =  ...
sprintf( 'rtwprivate ssgensfun ModelCloseRequest %s', blkMdl );
mdlCloseFcn = get_param( blkMdl, 'CloseFcn' );
mdlCloseFcn = strrep( mdlCloseFcn, oldMdlCloseCallback, '' );
dirtyFlag = get_param( blkMdl, 'Dirty' );
set_param( blkMdl, 'CloseFcn', mdlCloseFcn );
set_param( blkMdl, 'Dirty', dirtyFlag );




if ~any( ismember( regMdls, blkMdl ) )
mdlObj = get_param( blkMdl, 'Object' );
mdlClose = Simulink.listener( mdlObj, 'CloseEvent', @( src, evnt )coder.internal.ssGenSfun( 'ModelCloseRequest', blkMdl ) );
else 
mdlClose = [  ];
end 


function hasMdlRefBlks = LocalHasModelRefBlks( blkHdl )




mdlRefBlks = find_system( blkHdl,  ...
'LookUnderMasks', 'on',  ...
'FollowLinks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'BlockType', 'ModelReference' );
hasMdlRefBlks = ~isempty( mdlRefBlks );




function canUseERT = LocalCanUseERT( blkHdl )





sampleTimes = get_param( blkHdl, 'CompiledSampleTime' );
if iscell( sampleTimes )
sampleTimes = sampleTimes{ 1 };
end 
canUseERT = ( sampleTimes( 1 ) ~= 0 );









% Decoded using De-pcode utility v1.2 from file /tmp/tmp3Qpt9D.p.
% Please follow local copyright laws when handling this file.

