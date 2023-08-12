function loadIPPlatform( obj, boardName )




[ ~, hP ] = obj.hIP.isInIPPlatformList( boardName );

setToolForBoard( obj, boardName );

setFPGAParts( obj, hP.FPGAFamily, hP.FPGADevice, hP.FPGAPackage, hP.FPGASpeed, boardName );

obj.hTurnkey = hdlturnkey.TurnkeyDriver( obj );

obj.hTurnkey.initBoardPlugin( hP );

obj.hIP.initIPPlatform;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJC_5Ga.p.
% Please follow local copyright laws when handling this file.

