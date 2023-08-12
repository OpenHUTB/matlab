function setBoardName( obj, boardName )




hOption = obj.getOption( 'Board' );
oldBoardName = hOption.Value;
try 
obj.initBoard( boardName );
catch ME





obj.initBoard( oldBoardName );
throw( ME );
end 
obj.disp;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpkKnWgB.p.
% Please follow local copyright laws when handling this file.

