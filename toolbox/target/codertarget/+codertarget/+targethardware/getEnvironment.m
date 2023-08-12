function thisEnv = getEnvironment( model )




thisEnv = [  ];
hCS = getActiveConfigSet( model );
if codertarget.data.isParameterInitialized( hCS, 'TargetHardware' )

board = codertarget.data.getParameterValue( hCS, 'TargetHardware' );
else 

board = get_param( hCS, 'HardwareBoard' );
end 

if ~isequal( board, 'None' )
hwObj = codertarget.targethardware.getTargetHardware( hCS );
thisEnv = struct(  ...
'NumCores', 1,  ...
'MaxNumTasks', 99,  ...
'MaxNumTimers', 99,  ...
'TaskPriorities', int16( 1:99 ),  ...
'TaskPriorityDescending', 1,  ...
'KernelLatency', 0,  ...
'TaskContextSaveTime', 0,  ...
'TaskContextRestoreTime', 0,  ...
'ModeChangeTime', 0 ...
 );

thisEnv.NumCores = codertarget.targethardware.getNumberOfCores( hCS );


osObj = codertarget.rtos.getTargetHardwareRTOS( hCS );
if ~isempty( osObj )
thisEnv.MaxNumTasks = osObj.MaxNumTasks;
thisEnv.MaxNumTimers = osObj.MaxNumTimers;
thisEnv.TaskPriorityDescending = osObj.TaskPriorityDescending;
thisEnv.TaskPriorities = osObj.TaskPriorities;
thisEnv.KernelLatency = osObj.KernelLatency;
if codertarget.data.isParameterInitialized( hCS, 'OS.KernelLatency' )
thisEnv.KernelLatency = codertarget.data.getParameterValue(  ...
hCS, 'OS.KernelLatency' );
end 
if codertarget.data.isParameterInitialized( hCS, 'OS.TaskContextSaveTime' )
thisEnv.TaskContextSaveTime = codertarget.data.getParameterValue(  ...
hCS, 'OS.TaskContextSaveTime' );
end 
if codertarget.data.isParameterInitialized( hCS, 'OS.TaskContextRestoreTime' )
thisEnv.TaskContextRestoreTime = codertarget.data.getParameterValue(  ...
hCS, 'OS.TaskContextRestoreTime' );
end 
if codertarget.data.isParameterInitialized( hCS, 'OS.ModeChangeTime' )
thisEnv.ModeChangeTime = codertarget.data.getParameterValue(  ...
hCS, 'OS.ModeChangeTime' );
end 
else 
hwObj = codertarget.parameter.getParameterDialogInfo( hCS, false );
for idx = 1:numel( hwObj.ParameterGroups )
if isequal( hwObj.ParameterGroups{ idx }, 'Processor' )
params = hwObj.Parameters{ idx };
for idxPrm = 1:numel( params )
thisParam = params{ 1, idxPrm };
if ~isequal( thisParam.Storage, 'Processor.NumberOfCores' )
if codertarget.data.isParameterInitialized( hCS, thisParam.Storage )
thisParamValue =  ...
str2double( codertarget.data.getParameterValue(  ...
hCS, thisParam.Storage ) );
else 
thisParamValue = 0;
end 
end 
switch ( thisParam.Storage )
case 'Processor.NumberOfCores'
thisEnv.NumCores = thisEnv.NumCores;
case 'Processor.InterruptSwitchTime'
thisEnv.KernelLatency = thisParamValue;
case 'Processor.InterruptContextSaveTime'
thisEnv.TaskContextSaveTime = thisParamValue;
case 'Processor.InterruptContextRestoreTime'
thisEnv.TaskContextRestoreTime = thisParamValue;
end 
end 
break ;
end 
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpxaWPWQ.p.
% Please follow local copyright laws when handling this file.

