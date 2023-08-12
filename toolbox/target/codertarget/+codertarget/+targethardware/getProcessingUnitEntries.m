function out = getProcessingUnitEntries( cs, ~ )





out = {  };

tgtHwInfo = codertarget.targethardware.getTargetHardware( cs );
allUnits = codertarget.targethardware.getProcessingUnitsForTargetHardware( tgtHwInfo );
if ~isempty( allUnits )
out = { allUnits.Name };
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp2YL51e.p.
% Please follow local copyright laws when handling this file.

