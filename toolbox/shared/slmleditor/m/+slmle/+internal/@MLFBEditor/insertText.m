function insertText( obj, text, line, column )


R36
obj
text string
line int32 = 0
column int32 = 0
end 

data = [  ];
data.text = text;
data.line = line;
data.column = column;

obj.publish( 'insertText', data );


% Decoded using De-pcode utility v1.2 from file /tmp/tmpg5Sky6.p.
% Please follow local copyright laws when handling this file.

