function delayComp = getUnitDelayResettableComp( hN, hInSignals, hOutSignals, hRstSignal,  ...
compName, ic, resettype, softreset, desc, slHandle, isSynchronousDelay )


if ( nargin < 11 )
isSynchronousDelay = false;
end 

if ( nargin < 10 )
slHandle =  - 1;
end 

if ( nargin < 9 )
desc = '';
end 

if ( nargin < 8 )
softreset = 1;
end 

if ( nargin < 7 )
resettype = '';
end 

if ( nargin < 6 )
ic = '';
end 

if ( nargin < 5 )
compName = 'reg';
end 

outType = hOutSignals( 1 ).Type;
matrixData = outType.is2DMatrix;
if matrixData
maxcol = outType.Dimensions( 2 );
hC = hInSignals( 1 ).split;
inSplit = hC.PirOutputSignals;
hS = hdlhandles( 1, maxcol );
for ii = 1:maxcol
hS( ii ) = hN.addSignal( inSplit( ii ).Type,  ...
[ hOutSignals( 1 ).Name, '_', ii - 1 ] );
icval = getICVal( ic, ii );
pircore.getUnitDelayResettableComp( hN, inSplit( ii ), hS( ii ),  ...
hRstSignal, compName, icval, resettype, softreset, desc,  ...
slHandle, isSynchronousDelay );
end 
delayComp = pirelab.getConcatenateComp( hN, hS, hOutSignals( 1 ),  ...
'Multidimensional array', '2' );
else 
delayComp = pircore.getUnitDelayResettableComp( hN, hInSignals,  ...
hOutSignals, hRstSignal, compName, ic, resettype, softreset,  ...
desc, slHandle, isSynchronousDelay );
end 
end 



function icval = getICVal( ic, ii )
if isscalar( ic )
icval = ic;
else 
if ismatrix( ic )
icval = ic( :, ii );
else 
assert( ndims( ic ) == 3 );
icval = ic( :, ii, : );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpuvWxEK.p.
% Please follow local copyright laws when handling this file.

