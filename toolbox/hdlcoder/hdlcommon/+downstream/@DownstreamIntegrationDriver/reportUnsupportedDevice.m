function reportUnsupportedDevice( obj, FPGAFamily, FPGADevice, FPGAPackage, FPGASpeed, boardName )



deviceNameStr = sprintf( '%s/%s/%s/%s', FPGAFamily, FPGADevice, FPGAPackage, FPGASpeed );
synToolStr = sprintf( '%s %s', obj.get( 'Tool' ), obj.getToolVersion );
if strcmpi( FPGAFamily, 'Virtex2' )
v2MsgObj = message( 'hdlcommon:workflow:Virtex2FPGAMsg' );
v2Str = v2MsgObj.getString;
else 
v2Str = '';
end 
if isempty( boardName )
deviceMsgObj = message( 'hdlcommon:workflow:UnsupportedDeviceMsg', deviceNameStr, synToolStr, v2Str );
else 
deviceMsgObj = message( 'hdlcommon:workflow:UnsupportedDeviceWithBoardMsg', deviceNameStr, boardName, synToolStr, v2Str );
end 
deviceMsg = deviceMsgObj.getString;
setupToolMsg = obj.printSetupToolMsg;
error( message( 'hdlcommon:workflow:UnsupportedDevice', deviceMsg, setupToolMsg ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1V5X52.p.
% Please follow local copyright laws when handling this file.

