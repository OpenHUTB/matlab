function out = validRoot( cvdata )





out = false;
id = cvdata.id;

if id == 0
if isfield( cvdata.localData, 'rootId' )
rootId = cvdata.localData.rootId;
else 
return ;
end 
else 
rootId = cv( 'get', id, '.linkNode.parent' );
end 

if isequal( rootId, 0 ) || cv( 'ishandle', rootId ) == 0 ||  ...
~isequal( cv( 'get', rootId, '.isa' ), cv( 'get', 'default', 'root.isa' ) ) ||  ...
isequal( cv( 'get', rootId, '.treeNode.parent' ), 0 )
return ;
end 

out = true;




% Decoded using De-pcode utility v1.2 from file /tmp/tmpgqcoFr.p.
% Please follow local copyright laws when handling this file.

