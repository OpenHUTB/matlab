function loadSLRTBoard( obj, boardName )





[ ~, hP ] = obj.hAvailableBoardList.isInBoardList( boardName );

if obj.cmdDisplay && ~hdlturnkey.isxpcinstalled
warning( message( 'hdlcommon:workflow:xPCNotInstalled' ) );
end 


setToolForBoard( obj, boardName );

setFPGAParts( obj, hP.FPGAFamily, hP.FPGADevice, hP.FPGAPackage, hP.FPGASpeed, boardName );

obj.hTurnkey = hdlturnkey.TurnkeyDriver( obj );

obj.hTurnkey.initTurnkeyBoardPlugin( hP );


if obj.isIPCoreGen
obj.hIP.initIPPlatform;

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2OQqku.p.
% Please follow local copyright laws when handling this file.

