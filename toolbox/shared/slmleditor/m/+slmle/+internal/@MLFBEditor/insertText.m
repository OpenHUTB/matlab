function insertText( obj, text, line, column )

arguments
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
