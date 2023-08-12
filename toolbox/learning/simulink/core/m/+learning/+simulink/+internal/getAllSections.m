function sectionTable = getAllSections( course )























R36
course char = 'simulink'
end 

contentRoot = string( learning.simulink.preferences.slacademyprefs.contentPath );



contentUnitTable = learning.simulink.internal.getContentUnitList( contentRoot, course );

for idx = 1:height( contentUnitTable )
contentUnitObj = jsondecode( fileread( fullfile( contentUnitTable.Path( idx ), "contentUnit.json" ) ) );

v = contentUnitObj.variants;
for jdx = 1:length( v )

if strcmpi( v( jdx ).name, course )
srcFiles = v( jdx ).srcList;
end 
end 

for kdx = 1:length( srcFiles )
fullPath = contentUnitTable.Path( idx );
relativePath = strrep( fullPath, contentRoot + filesep, '' );
srcPath = relativePath + filesep + srcFiles{ kdx };
sections = contentUnitObj.sections;



if iscell( sections )
sections = learning.simulink.internal.util.mergeDissimilarStructures( sections );
end 

type = string( sections( contains( { sections.src }, srcFiles{ kdx } ) ).type );

sectionInfoTable = table( kdx, strrep( srcPath, '\', '/' ), type,  ...
'VariableNames', { 'Section', 'Path', 'Type' } );

thisRow = horzcat( contentUnitTable( idx, 1:2 ), sectionInfoTable );%#ok<*AGROW>
if ~exist( 'sectionTable', 'var' ) == 1
sectionTable = thisRow;
else 
sectionTable = vertcat( sectionTable, thisRow );
end 

end 

end 

sectionTable.Type = categorical( sectionTable.Type );


sectionTable.Index = ( 1:height( sectionTable ) )';
sectionTable = movevars( sectionTable, 'Index', 'Before', 'Chapter' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpM0nk6m.p.
% Please follow local copyright laws when handling this file.

