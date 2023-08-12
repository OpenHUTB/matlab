function [ PerfTracerStats, simMode, errMsg ] = getSimulationTimingInfo( model )




















PerfTracerStats = struct;
simMode = get_param( model, 'SimulationMode' );
errMsg = '';

if ( strcmpi( simMode, 'rapid-accelerator' ) )
PerfTracerStats.UpdateDiagramTime = 0;
PerfTracerStats.UpToDateCheck = 0;
PerfTracerStats.SimSetUp = 0;
PerfTracerStats.TopGenerateAndCompileCode = 0;
PerfTracerStats.SubGenerateAndCompileCode = 0;
PerfTracerStats.Execution = 0;
PerfTracerStats.Terminate = 0;
else 
PerfTracerStats.UpdateDiagramTime = 0;
PerfTracerStats.UpToDateCheck = 0;
PerfTracerStats.SimSetUp = 0;
PerfTracerStats.TopGenerateAndCompileCode = 0;
PerfTracerStats.SubGenerateAndCompileCode = 0;
PerfTracerStats.Execution = 0;
PerfTracerStats.Terminate = 0;
end 

checkPerfTracer = PerfTools.Tracer.enable( 'Performance Advisor Stats' );

if ( checkPerfTracer )



procData = PerfTools.Tracer.getProcessedData( 'grouping', 'Performance Advisor Stats' );
if ( isempty( procData ) )
errMsg = DAStudio.message( 'SimulinkPerformanceAdvisor:advisor:SimulateModelFirst' );
return 
end 
else 
errMsg = DAStudio.message( 'SimulinkPerformanceAdvisor:advisor:PerformanceAdvisorGroupDisabled' );
return 
end 

n = length( procData );

Tcs = 0;
Ti = 0;
Tu = 0;
Tuc = 0;
Tmrb = 0;
Tg = 0;
Tb = 0;
Te = 0;
Tt = 0;

for i = 1:n
a = procData{ i }.phaseIDStr;
switch a


case 'CreateAndCompileModel'

if strcmpi( procData{ i }.modelStr, model )
assert( Tu == 0 );
Tu = Tu + procData{ i }.wcElapsedTime;
end 
case 'Initialization'
assert( Ti == 0 );
Ti = Ti + procData{ i }.wcElapsedTime;
case 'CommandLineSimulation'
assert( Tcs == 0 );
Tcs = Tcs + procData{ i }.wcElapsedTime;
case 'GenerateAndCompileCode'
assert( Tg == 0 );
Tg = Tg + procData{ i }.wcElapsedTime;
case 'update_model_reference_targets'
assert( Tuc == 0 );
Tuc = Tuc + procData{ i }.wcElapsedTime;
case 'Build Model Reference Target'
Tmrb = Tmrb + procData{ i }.wcElapsedTime;
case 'RapidAccelBuild'
assert( Tb == 0 );
Tb = Tb + procData{ i }.wcElapsedTime;
case 'Execution'
assert( Te == 0 );
Te = Te + procData{ i }.wcElapsedTime;
case 'Termination'

if strcmpi( procData{ i }.modelStr, model )




Tt = Tt + procData{ i }.wcElapsedTime;
end 
otherwise 
continue ;
end 
end 



















if ( strcmpi( simMode, 'rapid-accelerator' ) )















PerfTracerStats.UpdateDiagramTime = Tu;













PerfTracerStats.SimSetUp = ( Tcs - Ti - Te - Tt ) ...
 + ( Ti - Tb );





if ( isequal( Tb, 0 ) )
PerfTracerStats.UpToDateCheck = 0;
PerfTracerStats.TopGenerateAndCompileCode = 0;
PerfTracerStats.SubGenerateAndCompileCode = 0;
else 


PerfTracerStats.UpToDateCheck = Tuc - Tmrb;





PerfTracerStats.TopGenerateAndCompileCode = Tb - Tu - Tuc;


PerfTracerStats.SubGenerateAndCompileCode = Tmrb;
end 
PerfTracerStats.Execution = Te;
PerfTracerStats.Terminate = Tt;
else 



PerfTracerStats.UpdateDiagramTime = Tu - Tuc;


PerfTracerStats.UpToDateCheck = Tuc - Tmrb;

if ( strcmpi( simMode, 'accelerator' ) )


























PerfTracerStats.SimSetUp = ( Tcs - Ti - Te ) ...
 + ( Ti - Tu - Tg );
else 























PerfTracerStats.SimSetUp = ( Tcs - Ti - Te - Tu ) ...
 + Ti;
end 
PerfTracerStats.TopGenerateAndCompileCode = Tg;
PerfTracerStats.SubGenerateAndCompileCode = Tmrb;
PerfTracerStats.Execution = Te - Tt;
PerfTracerStats.Terminate = Tt;
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpY1Jjea.p.
% Please follow local copyright laws when handling this file.

