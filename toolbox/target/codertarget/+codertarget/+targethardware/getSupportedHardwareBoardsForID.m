function out = getSupportedHardwareBoardsForID( baseProductID )






validateattributes( baseProductID, { 'codertarget.targethardware.BaseProductID' }, { 'nonempty' } );

allHwBoards = codertarget.targethardware.getRegisteredTargetHardware;
out = codertarget.targethardware.findHwBoardsForID( allHwBoards, baseProductID );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpk7oTom.p.
% Please follow local copyright laws when handling this file.

