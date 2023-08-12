function StrMacComp = getStreamingMACComp( hN, hInSignals, hOutSignals, rndMode, compName, InitValueSetting, initValue, numberOfSamples, opMode, Cbox_ValidOut, Cbox_EndInAndOut, Cbox_StartOut, Cbox_CountOut, PortInString, PortOutString )































inSigs = pirelab.convertRowVecsToUnorderedVecs( hN, hInSignals );
StrMacComp = pircore.getStreamingMACComp( hN, inSigs, hOutSignals,  ...
rndMode,  ...
compName, InitValueSetting, initValue, numberOfSamples, opMode, Cbox_ValidOut, Cbox_EndInAndOut, Cbox_StartOut, Cbox_CountOut, PortInString, PortOutString );

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp8rVL4O.p.
% Please follow local copyright laws when handling this file.

