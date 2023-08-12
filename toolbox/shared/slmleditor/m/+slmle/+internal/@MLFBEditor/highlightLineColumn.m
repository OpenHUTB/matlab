function highlightLineColumn( obj, startLine, startCol, endLine, endCol )




R36
obj
startLine( 1, 1 )int32
startCol( 1, 1 )int32
endLine( 1, 1 )int32
endCol( 1, 1 )int32
end 

data = [  ];
data.range = [ startLine, startCol, endLine, endCol ];


obj.publish( 'highlight', data );



% Decoded using De-pcode utility v1.2 from file /tmp/tmpVEZqD6.p.
% Please follow local copyright laws when handling this file.

