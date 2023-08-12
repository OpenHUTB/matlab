function addFileNameToRecentFilesList( designSession, fileName )
R36
designSession
fileName( 1, 1 )string
end 

fileName = convertStringsToChars( fileName );
maxNumFilesInList = 5;

fileList = designSession.RecentFiles.toArray(  );
fileIdx = find( strcmp( fileName, fileList ) );

if ~isempty( fileIdx )
designSession.RecentFiles.removeAt( fileIdx );
end 

designSession.RecentFiles.add( fileName );

if designSession.RecentFiles.Size > maxNumFilesInList
designSession.RecentFiles.removeAt( 1 );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp8iMHDw.p.
% Please follow local copyright laws when handling this file.

