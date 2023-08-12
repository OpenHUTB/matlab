function out = getProcessingUnitInfo( hObj )




out = [  ];
hardware = codertarget.targethardware.getTargetHardware( hObj );
if codertarget.targethardware.isProcessingUnitSelectionAvailable( hObj )
procUnits =  ...
codertarget.targethardware.getProcessingUnitsForTargetHardware(  ...
hardware );
supportedProgUnitNames = { procUnits.Name };
progUnitName = codertarget.data.getParameterValue( hObj, 'ESB.ProcessingUnit' );
idx = strcmp( supportedProgUnitNames, progUnitName );
out = procUnits( idx );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp3jUf8u.p.
% Please follow local copyright laws when handling this file.

