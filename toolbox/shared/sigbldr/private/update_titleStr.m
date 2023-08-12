function update_titleStr( UD )




oldTitleStr = get( UD.dialog, 'Name' );
blockPath = getfullname( UD.simulink.subsysH );

if strcmp( oldTitleStr( ( end  - 1 ):end  ), ' *' ) | UD.common.dirtyFlag == 1
titleStr = [ 'Signal Builder (', blockPath, ') *' ];
else 
titleStr = [ 'Signal Builder (', blockPath, ')' ];
end 
set( UD.dialog, 'Name', titleStr );
% Decoded using De-pcode utility v1.2 from file /tmp/tmpajNE7d.p.
% Please follow local copyright laws when handling this file.

