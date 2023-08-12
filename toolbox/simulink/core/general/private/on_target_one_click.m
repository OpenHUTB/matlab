function targetHookObj = on_target_one_click( modelHandle )




model = get_param( modelHandle, 'Name' );


BuildInProgressTracker = Simulink.BuildInProgress( model );


loc_check_model_settings( model );


modelStatus = coder.oneclick.ModelStatus.instance;
modelStatus.setModelName( model );


progressDone = onCleanup( @(  )set_param( model, 'ProgressPercentage', 100 ) );
modelStatus.updateProgress( 'Initializing', 5 );





targetHookObj = coder.oneclick.TargetHook.createOneClickTargetHookObject( model );
targetHookObj.configureModelIfNecessary;






preserve_dirty = Simulink.PreserveDirtyFlag( modelHandle, 'blockDiagram' );%#ok<NASGU>



targetHookObj.enableExtMode;


targetHookObj.preBuild;


modelStatus.setHardwareName( targetHookObj.getHardwareName );
modelStatus.updateProgress( 'Building', 10 );





slbuild_private( model,  ...
'StandaloneCoderTarget',  ...
'IsExtModeOneClickSim', true,  ...
'OkayToPushNags', true );


modelStatus.updateProgress( 'Downloading', 80 );
targetHookObj.downloadAndRunTargetExecutable;


modelStatus.updateProgress( 'Connecting', 90 );
targetHookObj.preExtModeConnectAction(  );
targetHookObj.extModeConnect( 'ConnectTimeout', '30' );

delete( progressDone );
delete( preserve_dirty );
delete( BuildInProgressTracker );


function loc_check_model_settings( model )

if strcmp( get_param( model, 'GenCodeOnly' ), 'on' )
DAStudio.error( 'Simulink:Extmode:OneClickGenCodeOnly', model );
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmp5CWKAe.p.
% Please follow local copyright laws when handling this file.

