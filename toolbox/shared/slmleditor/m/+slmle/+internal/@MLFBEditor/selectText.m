function selectText( obj, sPos, ePos )

arguments
    obj
    sPos int32
    ePos int32
end

data = [  ];
data.range = [ sPos, ePos ];
obj.publish( 'selectText', data );
