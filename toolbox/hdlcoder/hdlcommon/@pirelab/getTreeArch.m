function treeComp = getTreeArch( hN, hInSignals, hOutSignals, opName,  ...
rndMode, satMode, compName, minmaxIdxBase, pipeline, useDetailedElab, minmaxISDSP, minmaxOutMode, dspMode, nfpOptions, prodWordLenMode )
































if ( nargin < 15 )
prodWordLenMode = 'expand';
end 

if ( nargin < 14 )
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
end 

if ( nargin < 13 )
dspMode = int8( 0 );
end 

if ( nargin < 12 )
minmaxOutMode = 'Value';
end 

if ( nargin < 11 )
minmaxISDSP = false;
end 

if ( nargin < 10 )
useDetailedElab = false;
end 

default_pipe_val = false;
if ( nargin < 9 )
pipeline = default_pipe_val;
end 
if ~islogical( pipeline )
pipeline = default_pipe_val;
end 

if ( nargin < 8 )
minmaxIdxBase = 'Zero';
end 

if ( nargin < 7 )
compName = sprintf( 'tree%s', lower( opName ) );
end 

if ( nargin < 6 )
satMode = 'Wrap';
end 

if ( nargin < 5 )
rndMode = 'Floor';
end 

treeComp = hdlarch.tree.getTreeArch( hN, hInSignals, hOutSignals, opName,  ...
rndMode, satMode, compName, minmaxIdxBase, pipeline, useDetailedElab, minmaxISDSP, minmaxOutMode, dspMode, nfpOptions, prodWordLenMode );




% Decoded using De-pcode utility v1.2 from file /tmp/tmpcbqlAf.p.
% Please follow local copyright laws when handling this file.

