function cgirComp = getTapDelayComp( hN, hSignalsIn, hSignalsOut, delayNumber, compName, ic, delayOrder, includeCurrent, resettype, desc, slHandle )






if ( nargin < 11 )
slHandle =  - 1;
end 

if ( nargin < 10 )
desc = '';
end 

if ( nargin < 9 )
resettype = false;
end 

if ( nargin < 8 )
includeCurrent = false;
end 

if ( nargin < 7 )
delayOrder = true;
end 

if ( nargin < 6 )
ic = 0;
end 

if ( nargin < 5 )
compName = 'tapdelay';
end 

cgirComp = pircore.getTapDelayComp( hN, hSignalsIn,  ...
hSignalsOut, delayNumber,  ...
compName, ic, delayOrder, includeCurrent,  ...
resettype, desc, slHandle );


% Decoded using De-pcode utility v1.2 from file /tmp/tmpbiqmao.p.
% Please follow local copyright laws when handling this file.

