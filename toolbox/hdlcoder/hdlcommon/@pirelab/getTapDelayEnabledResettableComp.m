function cgirComp = getTapDelayEnabledResettableComp( hN, hSignalsIn, hSignalsOut, hEnbSignals, hRstSignal, delayNumber, compName, initval, delayOrder, includeCurrent, resettype, isDefaultHwSemantics, desc, slHandle )













if ( nargin < 14 )
slHandle =  - 1;
end 

if ( nargin < 13 )
desc = '';
end 

if ( nargin < 12 )
isDefaultHwSemantics = true;
end 

if ( nargin < 11 )
resettype = false;
end 

if ( nargin < 10 )
includeCurrent = false;
end 

if ( nargin < 9 )
delayOrder = true;
end 

if ( nargin < 8 )
initval = 0;
end 

if ( nargin < 7 )
compName = 'tapdelay';
end 

if isDefaultHwSemantics
hN.setHasSLHWFriendlySemantics( true );
end 

cgirComp = pircore.getTapDelayEnabledResettableComp( hN, hSignalsIn, hSignalsOut, delayNumber, compName, initval, delayOrder, includeCurrent, resettype, hEnbSignals, hRstSignal, desc, slHandle );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpEnrFbN.p.
% Please follow local copyright laws when handling this file.

