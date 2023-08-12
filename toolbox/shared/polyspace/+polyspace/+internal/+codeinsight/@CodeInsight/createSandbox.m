function success = createSandbox( self, options )



R36
self( 1, 1 )polyspace.internal.codeinsight.CodeInsight
options.ResultsDir( 1, 1 )string{ polyspace.internal.codeinsight.CodeInsight.mustBeNonEmptyString( options.ResultsDir ) } = "sandboxDir"
options.AggregateHeaderFiles( 1, 1 ) = false
options.AggregatedHeaderFileName( 1, 1 )string{ polyspace.internal.codeinsight.CodeInsight.mustBeNonEmptyString( options.AggregatedHeaderFileName ) } = "aggregatedHeader.h"
options.CopySourceFile logical = false
options.PreprocessSourceFiles logical = false
options.RemoveEmptyLines logical = true
options.RemoveLinePragmas logical = true
options.RemoveAllPragmas logical = false
options.RemovePatterns( 1, : )string = [  ]
options.RemoveVariableDefinitionInHeader logical = false
options.CleaningPassNumber int32 = 5
options.IndentResult logical = true
options.IgnoreSystemIncludes logical = true
options.Debug logical = false
options.Verbose logical = false
end 

if ~license( 'checkout', 'Simulink_Test' )
error( message( 'Simulink:Harness:LicenseNotAvailable' ) );
end 

success = true;

self.checkProperties(  );


if isempty( self.SourceFiles )
m = message( 'cxxfe:codeinsight:NoSrcFile' );
warning( m );
success = false;
return ;
end 


if options.AggregateHeaderFiles
if ( length( self.SourceFiles ) > 1 )


self.Errors = 'Aggregrated header cannot be generated for more than 1 source file.';
success = false;
return 
end 
optionsToPass = rmfield( options, { 'AggregateHeaderFiles', 'PreprocessSourceFiles' } );
optionsCell = namedargs2cell( optionsToPass );
success = self.createFileHarness( optionsCell{ : } );
if success
try 
self.HarnessInfo.CodeInfo.undefASMInSources( fullfile( options.ResultsDir, 'src' ) );
catch ME
success = false;
self.Errors = ME.getReport;
return ;
end 
success = self.HarnessInfo.parse( 'RemoveUnneededEntities', true );
self.SandboxInfo = self.HarnessInfo;
end 
return ;
end 


if options.PreprocessSourceFiles

if exist( options.ResultsDir, 'dir' ) ~= 7
createDirectory( options.ResultsDir );
end 
resultSrcDir = fullfile( options.ResultsDir, "src" );
if exist( resultSrcDir, 'dir' ) ~= 7
createDirectory( resultSrcDir );
end 
srcList = string.empty;
for f = self.SourceFiles
o = polyspace.internal.codeinsight.CodeInsight(  ...
'SourceFiles', f,  ...
'IncludeDirs', self.IncludeDirs,  ...
'Defines', self.Defines,  ...
'Debug', self.Debug );
[ ~, fname, ext ] = fileparts( f );
srcName = fullfile( resultSrcDir, fname + ext );
success = o.parse(  ...
'RemoveUnneededEntities', true,  ...
'DoGenOutput', true,  ...
'GenOutput', srcName ...
 );
if ~success
self.Errors = o.Errors;
error( self.Errors );
end 
srcList( end  + 1 ) = srcName;%#ok<AGROW>


newcontent = polyspace.internal.codeinsight.CodeInsight.processFileContent( srcName,  ...
'RemoveAllPragmas', options.RemoveAllPragmas,  ...
'RemoveEmptyLines', options.RemoveEmptyLines,  ...
'RemoveLinePragmas', options.RemoveLinePragmas,  ...
'RemovePatterns', options.RemovePatterns ...
 );
fid = fopen( srcName, 'w' );
fprintf( fid, "%s", newcontent );
fclose( fid );


oasm = polyspace.internal.codeinsight.CodeInsight(  ...
'SourceFiles', srcName,  ...
'Debug', self.Debug );
success = oasm.parse(  );
if ~success
self.Errors = oasm.Errors;
error( self.Errors );
end 

hasChanged = oasm.CodeInfo.undefASM( srcName, true );
if hasChanged
self.printStartStatus( "Checking preprocessed file - after removing ASM blocks", options.Verbose );
parseDataFinalSuccess = oasm.parse(  );
if ~parseDataFinalSuccess
error( string( oasm.Errors ) );
end 
self.printEndStatus( "Checking preprocessed file - after removing ASM blocks", options.Verbose );
end 
end 

self.SandboxInfo = polyspace.internal.codeinsight.CodeInsight(  ...
'SourceFiles', srcList,  ...
'Debug', self.Debug );
self.printStartStatus( "Checking sandbox", options.Verbose );
parseDataFinalSuccess = self.SandboxInfo.parse( 'RemoveUnneededEntities', true );
if ~parseDataFinalSuccess
error( self.SandboxInfo.Errors );
end 
self.printEndStatus( "Checking sandbox", options.Verbose );
return ;
end 


self.printStartStatus( "Compute file dependencies", options.Verbose );
self.parse( 'FileDependenciesOnly', true );
self.printEndStatus( "Compute file dependencies", options.Verbose );

self.printStartStatus( "Create results directory", options.Verbose );
fList = self.CodeInfo.AST.Project.Files.toArray;
[ resultSrcFileList, resultIncludeDir ] = polyspace.internal.codeinsight.CodeInsight.createResultDir( fList,  ...
'AggregateHeaderFiles', false,  ...
'ResultsDir', options.ResultsDir,  ...
'CopySourceFiles', true,  ...
'OriginalSourceFiles', self.SourceFiles );
self.printEndStatus( "Create results directory", options.Verbose );

self.SandboxInfo = polyspace.internal.codeinsight.CodeInsight(  ...
'SourceFiles', resultSrcFileList,  ...
'IncludeDirs', resultIncludeDir,  ...
'Defines', self.Defines,  ...
'Debug', self.Debug );

self.printStartStatus( "Checking sandbox", options.Verbose );
parseDataFinalSuccess = self.SandboxInfo.parse( 'RemoveUnneededEntities', true );
if ~parseDataFinalSuccess
error( self.SandboxInfo.Errors );
end 
self.printEndStatus( "Checking sandbox", options.Verbose );

end 

function createDirectory( d )
try 
mkdir( d );
catch Cause
M1 = MException( message( 'cxxfe:codeinsight:CannotCreateResultFile', d ) );
M2 = addCause( M1, Cause );
throw( M2 );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYWSBUt.p.
% Please follow local copyright laws when handling this file.

