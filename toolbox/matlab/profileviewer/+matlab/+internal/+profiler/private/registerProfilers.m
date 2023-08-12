function registerProfilers( profilerService )




R36
profilerService( 1, 1 )
end 

registerMatlabProfiler( profilerService );
registerPoolProfiler( profilerService );
end 

function registerMatlabProfiler( profilerService )
profilerService.registerProfiler(  ...
matlab.internal.profiler.ProfilerType.Matlab,  ...
matlab.internal.profiler.MatlabProfiler(  ) );
end 

function registerPoolProfiler( profilerService )
if ~matlab.internal.feature( "EnablePoolProfiler" )
return ;
end 

if matlab.internal.parallel.isPCTInstalled
profilerService.registerProfiler(  ...
matlab.internal.profiler.ProfilerType.Pool,  ...
parallel.internal.profiler.PoolProfiler( profilerService ) );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpbm3wzY.p.
% Please follow local copyright laws when handling this file.

