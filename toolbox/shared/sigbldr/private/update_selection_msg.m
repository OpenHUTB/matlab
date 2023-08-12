function update_selection_msg( UD )





if UD.current.channel == 0
set( UD.hgCtrls.status.selText, 'String', '' );
return 
end 

chStruct = UD.channels( UD.current.channel );
Ipts = UD.current.editPoints;
if isempty( Ipts )
portionStr = '';
else 
if length( Ipts ) == 1, 
portionStr = [ '(Pt ', int2str( Ipts ), ') ' ];
else 
portionStr = [ '(Pts ', int2str( Ipts( 1 ) ), ',', int2str( Ipts( 2 ) ), ') ' ];
end 
end 

props = '';
if chStruct.stepX > 0
props = [ props, 'TGrid ' ];
end 
if chStruct.stepY > 0
props = [ props, 'YGrid ' ];
end 
if ~isempty( chStruct.yMin )
props = [ props, 'YMin ' ];
end 
if ~isempty( chStruct.yMax )
props = [ props, 'YMax ' ];
end 

str = sprintf( '%s (#%d) %s [ %s]', chStruct.label, chStruct.outIndex, portionStr, props );
set( UD.hgCtrls.status.selText, 'String', str );
% Decoded using De-pcode utility v1.2 from file /tmp/tmptdZfzK.p.
% Please follow local copyright laws when handling this file.

