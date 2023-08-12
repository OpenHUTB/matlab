function addFileInfo( obj, name, group, fileType, filePath, tag )



if nargin < 6

tag = '';
end 

if ~isempty( filePath ) && filePath( end  ) == filesep
filePath = fileparts( filePath );
end 
if strcmp( group, 'custom' )
if ~any( strcmp( obj.CustomFile, name ) ) &&  ...
exist( name, 'file' ) == 2
obj.CustomFile{ end  + 1 } = name;
end 
else 
if isempty( filePath )
[ filePath, name, ext ] = fileparts( name );
name = [ name, ext ];
end 
if ~any( strcmp( { obj.FileInfo.FileName }, name ) )

obj.FileInfo( end  + 1 ) = obj.tokenPath( rtw.report.ReportInfo.newFileInfo( name, group, fileType, filePath, tag ) );

obj.CachedSortedFileInfo = {  };
obj.TimeStamp = now;
obj.Dirty = true;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpflmDIc.p.
% Please follow local copyright laws when handling this file.

