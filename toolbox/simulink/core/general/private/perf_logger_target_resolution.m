function targetName = perf_logger_target_resolution( mdlRefTargetType, mdlName, clearPerfLogs, setCompileType )

switch ( mdlRefTargetType )
case 'SIM'
targetName = 'mdlref-AccelSim';
if ( clearPerfLogs )
SLPerfLogData( 'clearMdlRefInfo' );
end 
if ( setCompileType )
PerfTools.Tracer.setStatisticsTypeForModel( mdlName, 'mdlref-AccelSim' );
end 

case 'RTW'
targetName = 'mdlref-RTW';
if ( clearPerfLogs )
SLPerfLogData( 'clearMdlRefInfo' );
end 

if ( setCompileType )
PerfTools.Tracer.setStatisticsTypeForModel( mdlName, 'mdlref-RTW' );
end 
case 'NONE'


sysTgtFile = get_param( mdlName, 'SystemTargetFile' );
switch ( sysTgtFile )
case 'accel.tlc'
targetName = 'AccelSim';
if ( setCompileType )
PerfTools.Tracer.setStatisticsTypeForModel( mdlName, 'Update' );
end 
case 'raccel.tlc'
targetName = 'RapidAccelSim';
if ( setCompileType )
PerfTools.Tracer.setStatisticsTypeForModel( mdlName, 'Update' );
end 
otherwise 
targetName = 'RTW';
if ( setCompileType )
PerfTools.Tracer.setStatisticsTypeForModel( mdlName, 'RTW' );
end 
end 
end 

end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpNBjiXr.p.
% Please follow local copyright laws when handling this file.

