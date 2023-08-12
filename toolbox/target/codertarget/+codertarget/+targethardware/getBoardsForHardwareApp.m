function out = getBoardsForHardwareApp(  )







out = [  ];
allBoards = codertarget.targethardware.getRegisteredTargetHardware(  );
if ~isempty( allBoards )
isBoardSupportedWithSoC = cellfun( @( x )(  ...
isequal( x, codertarget.targethardware.BaseProductID.SOC ) ||  ...
isequal( x, codertarget.targethardware.BaseProductID.ROS ) ), { allBoards.BaseProductID } );
allBoardsMinusSoC = allBoards( ~isBoardSupportedWithSoC );
out = sort( { allBoardsMinusSoC.DisplayName } );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpnG_4SC.p.
% Please follow local copyright laws when handling this file.

