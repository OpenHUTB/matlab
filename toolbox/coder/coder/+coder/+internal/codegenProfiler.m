function [ enabledp, optout, logdir, cgirDebug ] = codegenProfiler( d, options )




















R36
d = ""
options.PerformanceTracer( 1, 1 )logical = true;
options.CGIRNamePrinter( 1, 1 )logical = true;
options.MATLABProfiler( 1, 1 )logical = true;
options.CGIRTransformProfiler( 1, 1 )logical = false;
options.CGIRPoolHighWaterMark( 1, 1 )logical = true;
options.InferenceProfiler( 1, 1 )string{ mustBeMember( options.InferenceProfiler, [ "full", "default", "off" ] ) } = "default";


end 
persistent outputDir;
persistent opts;
persistent cgirDebugPersistent;
if isempty( outputDir )
outputDir = "";
opts = struct(  );
[ ~, cgirDebugPersistent ] = evalc( 'internal.cgir.Debug' );
end 
if nargin == 1
if islogical( d ) || isnumeric( d )
if d && ~isEnabled(  )
outputDir = pwd;
opts = options;
elseif ~d
outputDir = "";
opts = struct(  );
end 
elseif ischar( d ) || isstring( d )
outputDir = d;
opts = options;
end 
end 
enabledp = isEnabled(  );
optout = opts;
logdir = outputDir;
cgirDebug = cgirDebugPersistent;

function p = isEnabled
p = outputDir ~= "";
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp4f8Cte.p.
% Please follow local copyright laws when handling this file.

