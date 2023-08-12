function createdModelName = doMultiInstanceNormalModeSetup( block, tempDir, numInstances, varargin )





if ( isempty( varargin ) )
numIterations = inf;
else 
numIterations = varargin{ 1 };
end 

modelName = get_param( block, 'ModelName' );
load_system( modelName );

dataConnection = Simulink.data.DataAccessor.createForExternalData( modelName );
startIndex = max( 0, numInstances - 1 );
createdModelName = Simulink.ModelReference.Conversion.NameUtils.getValidModelNameForBase(  ...
modelName, numIterations, dataConnection, startIndex );
if ( isempty( createdModelName ) )
DAStudio.error( 'Simulink:modelReference:MultiInstanceNormalModeSetupFailedBecauseOfModelName', modelName );
end 



newDir = fullfile( tempDir, modelName );
newFile = fullfile( newDir, [ createdModelName, '.slx' ] );

original_save_tn = get_param( 0, 'SaveSLXThumbnail' );
restore_save_tn = onCleanup( @(  )set_param( 0, 'SaveSLXThumbnail', original_save_tn ) );
set_param( 0, 'SaveSLXThumbnail', 'off' );
rtwprivate( 'rtw_create_directory_path', newDir );
slInternal( 'snapshot_slx', modelName, newFile );

try 

addMultiInstanceNormalModelName( createdModelName );
load_system( newFile );


setMultiInstanceModelBroker( modelName, createdModelName );

neverSaveParamsToCopy = { 'RapidAcceleratorSimStatus' };
for i = 1:length( neverSaveParamsToCopy )
param = neverSaveParamsToCopy{ i };
val = get_param( modelName, param );
set_param( createdModelName, param, val );
end 
catch ex

removeMultiInstanceNormalModelName( createdModelName );
rethrow ex
end 
end 


function addMultiInstanceNormalModelName( mdlName )
if slfeature( 'SLModelBroker' ) == 0 && slfeature( 'SLLibrarySLDD' ) == 0
return ;
end 
brokerCache = slid.broker.Cache.getInstance( '' );
brokerCache.addMultiInstanceNormalModelName( mdlName );
end 


function removeMultiInstanceNormalModelName( mdlName )
if slfeature( 'SLModelBroker' ) == 0 && slfeature( 'SLLibrarySLDD' ) == 0
return ;
end 
brokerCache = slid.broker.Cache.getInstance( '' );
brokerCache.removeMultiInstanceNormalModelName( mdlName );
end 


function setMultiInstanceModelBroker( originalModelName, instanceModelName )
if slfeature( 'SLModelBroker' ) == 0 && slfeature( 'SLLibrarySLDD' ) == 0
return ;
end 

origModelObj = get_param( originalModelName, 'slobject' );
origModelBroker = origModelObj.getBroker;

instModelObj = get_param( instanceModelName, 'slobject' );
instModelBroker = instModelObj.getBroker;

instModelBroker.useDelegatedBroker( origModelBroker );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpxc3pH3.p.
% Please follow local copyright laws when handling this file.

