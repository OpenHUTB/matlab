function loadTurnkeyBoard( obj, boardName )





[ ~, hP ] = obj.hAvailableBoardList.isInBoardList( boardName );
if obj.queryFlowOnly == downstream.queryflowmodesenum.NONE && obj.isXPCWorkflow
if obj.cmdDisplay && ~hdlturnkey.isxpcinstalled
warning( message( 'hdlcommon:workflow:xPCNotInstalled' ) );
end 
end 

setToolForBoard( obj, boardName );

setFPGAParts( obj, hP.FPGAFamily, hP.FPGADevice, hP.FPGAPackage, hP.FPGASpeed, boardName );

obj.hTurnkey = hdlturnkey.TurnkeyDriver( obj );

obj.hTurnkey.initTurnkeyBoardPlugin( hP );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLGnvIk.p.
% Please follow local copyright laws when handling this file.

