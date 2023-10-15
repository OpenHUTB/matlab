function selectTextLineColumn( obj, startLine, startCol, endLine, endCol )

arguments
    obj
    startLine( 1, 1 )int32
    startCol( 1, 1 )int32
    endLine( 1, 1 )int32
    endCol( 1, 1 )int32
end

data = [  ];
data.range = [ startLine, startCol, endLine, endCol ];
obj.publish( 'selectText', data );

