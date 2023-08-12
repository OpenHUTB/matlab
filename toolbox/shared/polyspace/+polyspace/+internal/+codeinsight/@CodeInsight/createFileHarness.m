function success = createFileHarness( self, options )




R36
self( 1, 1 )polyspace.internal.codeinsight.CodeInsight
options.ResultsDir( 1, 1 )string = "harnessDir"
options.AggregatedHeaderFileName( 1, 1 )string = "aggregatedHeader.h"
options.CopySourceFile logical = false
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

success = true;

if isempty( self.SourceFiles )
m = message( 'cxxfe:codeinsight:NoSrcFile' );
warning( m );
success = false;
return ;
end 


tmpDir = tempname( fullfile( tempdir, 'CodeInsightFileHarness' ) );
if ~isfolder( tmpDir )
mkdir( tmpDir );
if options.Debug
fprintf( 1, '### Debug: use temporary folder: %s\n', tmpDir );
else 
clrObj = onCleanup( @(  )rmdir( tmpDir, 's' ) );
end 
end 


[ aggregateHeaderFileNameDir, aggregateHeaderFileName, aggregateHeaderFileNameExt ] = fileparts( options.AggregatedHeaderFileName );
if ~( isempty( aggregateHeaderFileNameDir ) || aggregateHeaderFileNameDir == "" )

d = aggregateHeaderFileNameDir;
m = message( 'cxxfe:codeinsight:DirPathIgnored', d );
warning( m );
end 
aggregateHeaderFileNameToUse = aggregateHeaderFileName + aggregateHeaderFileNameExt;


if numel( self.SourceFiles ) > 1



self.printStartStatus( "Compute file dependencies", options.Verbose );
failure = self.parse( 'FileDependenciesOnly', true );
if ~failure
success = false;
return 
end 
self.printEndStatus( "Compute file dependencies", options.Verbose );

self.printStartStatus( "Create results directory", options.Verbose );
cUnit = self.CodeInfo.AST.Project.Compilations.at( 1 );
fList = cUnit.Files.toArray;

[ resultSrcFileList, resultIncludeDir, ~ ] = polyspace.internal.codeinsight.CodeInsight.createResultDir( fList,  ...
'AggregateHeaderFiles', true,  ...
'ResultsDir', options.ResultsDir,  ...
'CopySourceFiles', options.CopySourceFile,  ...
'AggregatedHeaderFilename', aggregateHeaderFileNameToUse,  ...
'OriginalSourceFiles', self.SourceFiles,  ...
'IgnoreSystemIncludes', options.IgnoreSystemIncludes );
self.printEndStatus( "Create results directory", options.Verbose );





fList = fList( [ fList.IsTopLevelFile ] );

hasIncludeFile = false;
for aFile = fList
if aFile.IncludedFiles.Size > 0

incFiles = aFile.IncludedFiles.toArray;


incFiles = incFiles( [ incFiles.IsInclude ] );
if ~isempty( incFiles )
hasIncludeFile = true;
break ;
end 
end 
end 






if ~hasIncludeFile

emptyHeaderFile = fullfile( resultIncludeDir, aggregateHeaderFileNameToUse );
fid = fopen( emptyHeaderFile, 'w' );
fprintf( fid, "/* SOURCE FILES DO NOT INCLUDE ANY HEADER FILES */\n" );
fclose( fid );
self.HarnessInfo = polyspace.internal.codeinsight.CodeInsight(  ...
'SourceFiles', resultSrcFileList,  ...
'HeaderFiles', emptyHeaderFile,  ...
'IncludeDirs', resultIncludeDir,  ...
'Defines', self.Defines,  ...
'Debug', self.Debug );

self.printStartStatus( "Checking aggregated header file", options.Verbose );
parseDataFinalSuccess = self.HarnessInfo.parse(  );
if ~parseDataFinalSuccess
self.Errors = self.HarnessInfo.Errors;
end 
self.printEndStatus( "Checking aggregated header file", options.Verbose );
success = parseDataFinalSuccess;
return 
end 



aggregatedSourceFileName = fullfile( tmpDir, "aggregatedSourceFile.c" );
fid = fopen( aggregatedSourceFileName, 'w' );
allSrcDirs = string.empty;
for f = self.SourceFiles

fDirInfo = dir( f );
allSrcDirs = [ allSrcDirs, fDirInfo.folder ];%#ok<AGROW>
fcontent = fileread( f );

fprintf( fid, "%s\n", fcontent );
end 
fclose( fid );


o = polyspace.internal.codeinsight.CodeInsight(  ...
'SourceFiles', aggregatedSourceFileName,  ...
'IncludeDirs', [ self.IncludeDirs, unique( allSrcDirs ) ],  ...
'Defines', self.Defines,  ...
'Debug', self.Debug );

self.printStatus( "Creating harness for aggregated source file", options.Verbose );
optionsCell = namedargs2cell( options );
success = o.createFileHarness( optionsCell{ : } );
if ~success
self.Errors = o.Errors;
error( "Source files are not compatible for generation of aggregated header file" );
end 

self.HarnessInfo = polyspace.internal.codeinsight.CodeInsight(  ...
'SourceFiles', resultSrcFileList,  ...
'HeaderFiles', o.HarnessInfo.HeaderFiles,  ...
'IncludeDirs', resultIncludeDir,  ...
'Defines', self.Defines,  ...
'Debug', self.Debug );


self.printStartStatus( "Checking aggregated header file", options.Verbose );
parseDataFinalSuccess = self.HarnessInfo.parse(  );
if ~parseDataFinalSuccess
self.Errors = self.HarnessInfo.Errors;
end 
self.printEndStatus( "Checking aggregated header file", options.Verbose );
return ;
end 


currentPass = 1;
currentAggregatedHeaderFileName = sprintf( "%s.pass%d.h", aggregateHeaderFileName, currentPass );
currentAggregatedHeaderFilePath = fullfile( tmpDir, currentAggregatedHeaderFileName );


self.printStartStatus( "Parsing Source File", options.Verbose );
parseDataSuccess = self.parse(  ...
'RemoveUnneededEntities', true,  ...
'DoGenAggregatedHeader', true,  ...
'DoAggregateSystemInclude', ~options.IgnoreSystemIncludes,  ...
'GenAggregatedHeaderOutput', currentAggregatedHeaderFilePath,  ...
'RemoveVariableDefinitionInHeader', options.RemoveVariableDefinitionInHeader ...
 );
if ~parseDataSuccess
error( self.Errors );
end 
self.printEndStatus( "Parsing Source File", options.Verbose );


self.printStartStatus( "Create results directory", options.Verbose );
cUnit = self.CodeInfo.AST.Project.Compilations.at( 1 );
fList = cUnit.Files.toArray;

[ resultSrcFileList, resultIncludeDir, copiedFiles ] = polyspace.internal.codeinsight.CodeInsight.createResultDir( fList,  ...
'AggregateHeaderFiles', true,  ...
'ResultsDir', options.ResultsDir,  ...
'CopySourceFiles', options.CopySourceFile,  ...
'AggregatedHeaderFilename', aggregateHeaderFileNameToUse,  ...
'OriginalSourceFiles', self.SourceFiles,  ...
'IgnoreSystemIncludes', options.IgnoreSystemIncludes );
self.printEndStatus( "Create results directory", options.Verbose );





fList = fList( [ fList.IsTopLevelFile ] );

hasIncludeFile = false;
for aFile = fList
if aFile.IncludedFiles.Size > 0

incFiles = aFile.IncludedFiles.toArray;


incFiles = incFiles( [ incFiles.IsInclude ] );
if ~isempty( incFiles )
hasIncludeFile = true;
break ;
end 
end 
end 






if ~hasIncludeFile

emptyHeaderFile = fullfile( resultIncludeDir, aggregateHeaderFileNameToUse );
fid = fopen( emptyHeaderFile, 'w' );
fprintf( fid, "/* SOURCE FILES DO NOT INCLUDE ANY HEADER FILES */\n" );
fclose( fid );
self.HarnessInfo = polyspace.internal.codeinsight.CodeInsight(  ...
'SourceFiles', resultSrcFileList,  ...
'HeaderFiles', emptyHeaderFile,  ...
'IncludeDirs', resultIncludeDir,  ...
'Defines', self.Defines,  ...
'Debug', self.Debug );

self.printStartStatus( "Checking aggregated header file", options.Verbose );
parseDataFinalSuccess = self.HarnessInfo.parse(  );
if ~parseDataFinalSuccess
self.Errors = self.HarnessInfo.Errors;
end 
self.printEndStatus( "Checking aggregated header file", options.Verbose );
success = parseDataFinalSuccess;
return 
end 



for f = copiedFiles
self.CodeInfo.undefASM( f, true );
end 


doCleanFile = options.RemoveEmptyLines || options.RemoveLinePragmas || options.RemoveAllPragmas || ~isempty( options.RemovePatterns );

commentHeader =  ...
"/*************************************************************************/" + newline +  ...
"/* Automatically generated " + string( datestr( now ) ) + "                          */" + newline +  ...
"/* No modification to the content of this file should be done.           */" + newline +  ...
"/*************************************************************************/" + newline + newline;
includeGuardMacro = upper( aggregateHeaderFileName ) + "_H_";
includeGuardStart = sprintf( "#ifndef %s", includeGuardMacro ) +  ...
newline + sprintf( "#define %s", includeGuardMacro ) + newline;
includeGuardEnd = ( "#endif" );


function finalizeAndWriteHeaderFile( currentFilePath )

currentContent = fileread( currentFilePath );
finalContent = commentHeader + includeGuardStart + currentContent + newline + includeGuardEnd;
finalfid = fopen( fullfile( resultIncludeDir, aggregateHeaderFileNameToUse ), 'w' );
fprintf( finalfid, "%s", finalContent );
fclose( finalfid );
end 

function newcontent = cleanAndWriteFile(  )
newcontent = polyspace.internal.codeinsight.CodeInsight.processFileContent( currentAggregatedHeaderFilePath,  ...
'RemoveAllPragmas', options.RemoveAllPragmas,  ...
'RemoveEmptyLines', options.RemoveEmptyLines,  ...
'RemoveLinePragmas', options.RemoveLinePragmas,  ...
'RemovePatterns', options.RemovePatterns ...
 );
currentPass = currentPass + 1;
currentAggregatedHeaderFileName = sprintf( "%s.pass%d.h", aggregateHeaderFileName, currentPass );
currentAggregatedHeaderFilePath = fullfile( tmpDir, currentAggregatedHeaderFileName );
fidclean = fopen( currentAggregatedHeaderFilePath, "w" );
fprintf( fidclean, "%s", newcontent );
fclose( fidclean );

finalizeAndWriteHeaderFile( currentAggregatedHeaderFilePath );
end 

self.HarnessInfo = polyspace.internal.codeinsight.CodeInsight(  ...
'SourceFiles', resultSrcFileList,  ...
'HeaderFiles', fullfile( resultIncludeDir, aggregateHeaderFileNameToUse ),  ...
'IncludeDirs', resultIncludeDir,  ...
'Defines', self.Defines,  ...
'Debug', self.Debug );


if doCleanFile
cleanStart = self.printStartStatus( "Cleaning aggregated header file", options.Verbose );
currentContent = cleanAndWriteFile(  );
for cleaningPass = 1:options.CleaningPassNumber
startT = self.printStartStatus( " -- Cleaning aggregated header file (pass" + cleaningPass + ")", options.Verbose );
currentPass = currentPass + 1;

currentAggregatedHeaderFileName = sprintf( "%s.pass%d.h", aggregateHeaderFileName, currentPass );
currentAggregatedHeaderFilePath = fullfile( tmpDir, currentAggregatedHeaderFileName );
parseDataCleanSuccess = self.HarnessInfo.parse(  ...
'RemoveUnneededEntities', true,  ...
'IsCleanHeaderPass', true,  ...
'DoGenAggregatedHeader', true,  ...
'DoAggregateSystemInclude', ~options.IgnoreSystemIncludes,  ...
'GenAggregatedHeaderOutput', currentAggregatedHeaderFilePath ...
 );
if ~parseDataCleanSuccess
error( self.HarnessInfo.Errors );
end 
newContent = cleanAndWriteFile(  );
self.printEndStatus( " -- Cleaning aggregated header file (pass" + cleaningPass + ")", options.Verbose, startT );
if ( newContent == currentContent )
break 
end 
currentContent = newContent;
end 
self.printEndStatus( "Cleaning aggregated header file", options.Verbose, cleanStart );
else 

finalizeAndWriteHeaderFile( currentAggregatedHeaderFilePath );
end 

resFileInfo = dir( fullfile( resultIncludeDir, aggregateHeaderFileNameToUse ) );
fullPathToAggregatedHeader = fullfile( resFileInfo.folder, resFileInfo.name );

if options.IndentResult
c_beautifier( fullPathToAggregatedHeader );
end 


self.printStartStatus( "Checking aggregated header file", options.Verbose );
parseDataFinalSuccess = self.HarnessInfo.parse(  );
if ~parseDataFinalSuccess
error( self.HarnessInfo.Errors );
end 
self.printEndStatus( "Checking aggregated header file", options.Verbose );



hasChanged = self.HarnessInfo.CodeInfo.undefASM( fullPathToAggregatedHeader );
if hasChanged
self.printStartStatus( "Checking aggregated header file - after removing ASM blocks", options.Verbose );
parseDataFinalSuccess = self.HarnessInfo.parse(  );
if ~parseDataFinalSuccess
error( string( self.HarnessInfo.Errors ) );
end 
self.printEndStatus( "Checking aggregated header file - after removing ASM blocks", options.Verbose );
end 

if options.RemoveVariableDefinitionInHeader








cacheContent = fileread( fullPathToAggregatedHeader );
hasChanged = self.HarnessInfo.CodeInfo.undefVariableDefinition( fullPathToAggregatedHeader );
if hasChanged
self.printStartStatus( "Checking aggregated header file - after removing variable definition in header", options.Verbose );
parseDataFinalSuccess = self.HarnessInfo.parse(  );
if ~parseDataFinalSuccess
warningState = warning( 'off', 'backtrace' );
m = message( 'cxxfe:codeinsight:UnableToUndefVariables' );
warning( m );
warning( warningState );
fid = fopen( fullPathToAggregatedHeader, 'w' );
fprintf( fid, cacheContent );
fclose( fid );
parseDataFinalSuccess = self.HarnessInfo.parse(  );
if ~parseDataFinalSuccess
error( string( self.HarnessInfo.Errors ) );
end 
end 
self.printEndStatus( "Checking aggregated header file - after removing ASM blocks", options.Verbose );
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLrRamn.p.
% Please follow local copyright laws when handling this file.

