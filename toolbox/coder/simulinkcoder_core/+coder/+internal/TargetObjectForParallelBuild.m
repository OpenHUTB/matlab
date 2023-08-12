


classdef TargetObjectForParallelBuild < handle
properties 
cgModelObject
slcgFileRepository
cgtObject
simulinkTokenRepository
buildDir;
end 

properties ( Hidden = true )
isModelObjectAvailable;
end 

methods 
function obj = TargetObjectForParallelBuild( buildDir, fileRepository, cgtObject )


obj.buildDir = buildDir;
obj.cgtObject = coder.SimulinkCoderTemplate( cgtObject );
obj.slcgFileRepository = fileRepository;
obj.cgModelObject = '';
obj.isModelObjectAvailable = false;
obj.simulinkTokenRepository = coder.SimulinkTokenRepository( obj.cgModelObject );
end 

function emitFiles( obj )
fileList = obj.slcgFileRepository.FileList;
emittedEndGuards = false;
for k = 1:length( fileList )
file = fileList( k );
fileName = file.Name( 1:end  - 2 );

if ( file.Filtered == 1 || file.WrittenToDisk == 1 || file.IsEmpty == 1 )
continue ;
end 



fid = fopen( fullfile( obj.buildDir, file.Name ), 'w+', 'n', 'Latin1' );
c = onCleanup( @(  )fclose( fid ) );
obj.simulinkTokenRepository.setCurrentFileName( file.Name );
sections = obj.cgtObject.orderedSectionHeaders;

if ( ~any( strcmp( sections, 'FileBanner' ) ) )
guardString = sprintf( '#ifndef RTW_HEADER_%s_h_\n#define RTW_HEADER_%s_h_', fileName, fileName );
fprintf( fid, '%s\n', slsvInternal( 'slsvEscapeServices', 'unicode2native', guardString ) );
end 

for i = 1:length( sections )



sectionName = sections{ i };

if strcmp( sectionName, 'FileBanner' ) || strcmp( sectionName, 'FileTrailer' )
if strcmp( sectionName, 'FileTrailer' )
guardString = sprintf( '#endif                     /* RTW_HEADER_%s_h_ */', fileName );
fprintf( fid, '%s\n', slsvInternal( 'slsvEscapeServices', 'unicode2native', guardString ) );
emittedEndGuards = true;
end 

sectionString = obj.cgtObject.createAndEmitSection( sectionName, obj.simulinkTokenRepository );
if ~isempty( sectionString )
fprintf( fid, '%s\n', slsvInternal( 'slsvEscapeServices', 'unicode2native', sectionString ) );
end 

if strcmp( sectionName, 'FileBanner' )
guardString = sprintf( '#ifndef RTW_HEADER_%s_h_\n#define RTW_HEADER_%s_h_', fileName, fileName );
fprintf( fid, '%s\n', slsvInternal( 'slsvEscapeServices', 'unicode2native', guardString ) );
end 
elseif strcmp( sectionName, 'Includes' ) &&  ...
file.hasSection( 'INCLUDES_SECTION' )

includes = file.getIncludesSection.getContent;
if ~isempty( includes )

sectionString = obj.cgtObject.createAndEmitSection( sectionName, obj.simulinkTokenRepository );
if ~isempty( sectionString )
fprintf( fid, '%s\n', slsvInternal( 'slsvEscapeServices', 'unicode2native', sectionString ) );
end 
fprintf( fid, '%s\n', slsvInternal( 'slsvEscapeServices', 'unicode2native', includes ) );
end 
elseif strcmp( sectionName, 'Types' ) &&  ...
file.hasSection( 'TYPEDEFS_SECTION' )

typedefs = file.getFileSection( 'TYPEDEFS_SECTION' ).getContent;
if ~isempty( typedefs )

sectionString = obj.cgtObject.createAndEmitSection( sectionName, obj.simulinkTokenRepository );
if ~isempty( sectionString )
fprintf( fid, '%s\n', slsvInternal( 'slsvEscapeServices', 'unicode2native', sectionString ) );
end 
fprintf( fid, '%s\n', slsvInternal( 'slsvEscapeServices', 'unicode2native', typedefs ) );
end 
elseif contains( sectionName, 'CustomSection_' )
sectionString = obj.cgtObject.createAndEmitSection( sectionName, obj.simulinkTokenRepository );
if ~isempty( sectionString )
fprintf( fid, '%s\n', slsvInternal( 'slsvEscapeServices', 'unicode2native', sectionString ) );
end 
end 
end 
if ( ~emittedEndGuards )
guardString = sprintf( '#endif                     /* RTW_HEADER_%s_h_ */', fileName );
fprintf( fid, '%s\n', slsvInternal( 'slsvEscapeServices', 'unicode2native', guardString ) );
end 
end 
end 
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmprTbisq.p.
% Please follow local copyright laws when handling this file.

