function ret = isBoardSimOnly( hwName )





ret = false;
hwInfo = codertarget.targethardware.getTargetHardwareFromNameForSoC( hwName );
if ~isempty( hwInfo ) && isprop( hwInfo, 'SupportsOnlySimulation' )
ret = hwInfo.SupportsOnlySimulation;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXuOmcN.p.
% Please follow local copyright laws when handling this file.

