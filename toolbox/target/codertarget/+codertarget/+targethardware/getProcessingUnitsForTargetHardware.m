function out = getProcessingUnitsForTargetHardware( tgtHwInfo )





out = [  ];
validateattributes( tgtHwInfo, { 'codertarget.targethardware.TargetHardwareInfo' }, { 'nonempty' } );
if tgtHwInfo.hasProcessingUnit
out = tgtHwInfo.ProcessingUnitInfo;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpX8Pl1D.p.
% Please follow local copyright laws when handling this file.

