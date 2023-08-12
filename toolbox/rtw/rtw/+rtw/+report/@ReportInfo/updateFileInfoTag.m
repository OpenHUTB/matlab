function updateFileInfoTag( obj, name, tag )
loc = strcmp( { obj.FileInfo.FileName }, name );
if any( loc )
obj.FileInfo( loc ).Tag = tag;

obj.CachedSortedFileInfo = {  };
obj.TimeStamp = now;
obj.Dirty = true;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpNdcKYL.p.
% Please follow local copyright laws when handling this file.

