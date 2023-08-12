function RamNet = getRAMBasedShiftRegisterComp( hN, hSignalsIn, hSignalsOut,  ...
delayNumber, thresholdSize, compName, ramName, RamNet )













if ( nargin < 5 ) || isempty( thresholdSize )
thresholdSize = 32;
end 

if ( nargin < 6 ) || isempty( compName )
compName = 'shift_reg';
end 

if ( nargin < 7 ) || isempty( ramName )
ramName = 'ShiftRegisterRAM';
end 

if ( nargin < 8 )
RamNet = '';
end 


[ RamNet, RamComp ] = pircore.getRAMBasedShiftRegisterComp( hN, hSignalsIn, hSignalsOut, delayNumber, thresholdSize, compName, ramName, RamNet );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpv68klL.p.
% Please follow local copyright laws when handling this file.

