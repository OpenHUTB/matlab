function selectText( obj, sPos, ePos )






R36
obj
sPos int32
ePos int32
end 

data = [  ];
data.range = [ sPos, ePos ];
obj.publish( 'selectText', data );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpol9xvg.p.
% Please follow local copyright laws when handling this file.

