function cgirComp = getTapDelayEnabledComp( hN, hSignalsIn, hSignalsOut, hEnbSignals, delayNumber, compName, initval, delayOrder, includeCurrent, resettype, isDefaultHwSemantics, desc, slHandle )







if ( nargin < 13 )
slHandle =  - 1;
end 

if ( nargin < 12 )
desc = '';
end 

if ( nargin < 11 )
isDefaultHwSemantics = true;
end 

if ( nargin < 10 )
resettype = false;
end 

if ( nargin < 9 )
includeCurrent = false;
end 

if ( nargin < 8 )
delayOrder = true;
end 

dimlen = pirelab.getVectorTypeInfo( hSignalsOut( 1 ), true );

if ( nargin < 7 )
ic = zeros( dimlen );
elseif ( length( initval ) == 1 )
ic = repmat( initval, 1, delayNumber );
else 
ic = initval;
end 
ic = reshape( pirelab.getTypeInfoAsFi( hSignalsOut.Type, 'Floor', 'Wrap', ic, false ), 1, delayNumber );

if ( nargin < 6 )
compName = 'tapdelay';
end 

if isDefaultHwSemantics
hN.setHasSLHWFriendlySemantics( true );
end 

cgirComp = pircore.getTapDelayEnabledResettableComp( hN, hSignalsIn, hSignalsOut, delayNumber, compName, ic, delayOrder, includeCurrent, resettype, hEnbSignals, '', desc, slHandle );



% Decoded using De-pcode utility v1.2 from file /tmp/tmpAcfQZ_.p.
% Please follow local copyright laws when handling this file.

