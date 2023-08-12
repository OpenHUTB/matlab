function [ out, varargout ] = getSortedFileInfoList( obj )
nargoutchk( 0, 4 );
if ~isempty( obj.CachedSortedFileInfo )
out = obj.CachedSortedFileInfo{ 1 };
if nargout > 1
varargout{ 1 } = obj.CachedSortedFileInfo{ 2 };
end 
if nargout > 2
varargout{ 2 } = obj.CachedSortedFileInfo{ 3 };
varargout{ 3 } = obj.CachedSortedFileInfo{ 4 };
end 
return 
end 

out = obj.updateFileInfo(  );


obj.CachedSortedFileInfoList = out;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzflO9Z.p.
% Please follow local copyright laws when handling this file.

