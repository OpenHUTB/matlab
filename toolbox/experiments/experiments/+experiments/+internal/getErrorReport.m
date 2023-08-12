function report = getErrorReport( ME, options )








R36
ME( 1, 1 )MException
options.ProjectPath( 1, : )char = ''
options.SnapshotPath( 1, : )char = ''
options.RunID( 1, : )char = ''
end 

report = ME.getReport( 'extended', 'hyperlinks', 'on' );


projectPath = '';
if ~isempty( options.ProjectPath )
projectPath = [ strrep( options.ProjectPath, '''', '''''' ), filesep ];
end 
matlabPath = [ strrep( matlabroot, '''', '''''' ), filesep ];

function str = fixPathFn( str )
filePath = str( 2:end  - 1 );


if startsWith( filePath, matlabPath )
root = 'matlab';
filePath = extractAfter( filePath, strlength( matlabPath ) );

elseif ~isempty( projectPath ) && startsWith( filePath, projectPath )
root = 'project';
filePath = extractAfter( filePath, strlength( projectPath ) );

elseif ~isempty( options.SnapshotPath ) && startsWith( filePath, options.SnapshotPath )
root = 'project';
filePath = extractAfter( filePath, strlength( options.SnapshotPath ) );
filePath = fullfile( 'Results', options.RunID, 'Snapshot', filePath );








else 
return 
end 

if ispc

filePath = strrep( filePath, '\', '/' );
end 

str = sprintf( 'experiments.internal.fixupPath(''%s'', ''%s'')', root, filePath );
end 


fixPath = @fixPathFn;%#ok<NASGU>

report = regexprep( report, '(?<=<a href="matlab:\s*(?:matlab.internal.language.introspective.errorDocCallback\(''[^'']+'',|opentoline\()\s*)''(?:''''|[^''])+''', '${fixPath($0)}' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpK2lJkf.p.
% Please follow local copyright laws when handling this file.

