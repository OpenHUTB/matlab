function fullFileLocation = locateFileInPath( fileNames, possiblePaths, fileSeparator, fileQuotes )
















fullFileLocation = {  };

if isempty( fileNames ) || ( ~iscell( fileNames ) && ~ischar( fileNames ) )
return ;
end 

if nargin < 4
fileQuotes = '';
end 

numFiles = 0;
numPaths = 0;

if ischar( fileNames )
numFiles = 1;
fileNames = { fileNames };
else 
numFiles = length( fileNames );
end 

[ fullFileLocation{ 1:numFiles } ] = deal( fileNames{ 1:numFiles } );

if ischar( possiblePaths )
numPaths = 1;
possiblePaths = { possiblePaths };
elseif iscell( possiblePaths )
numPaths = length( possiblePaths );
else 
return ;
end 

for fileNameIdx = 1:numFiles
for pathIdx = 1:numPaths
fullFileName = [ possiblePaths{ pathIdx }, fileSeparator, fileNames{ fileNameIdx } ];
if ( exist( fullFileName ) >= 2 )
fullFileLocation{ fileNameIdx } = [ fileQuotes, fullFileName, fileQuotes ];
break ;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpvAI3dj.p.
% Please follow local copyright laws when handling this file.

