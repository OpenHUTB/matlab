function success = parse( self, options )




R36
self( 1, 1 )polyspace.internal.codeinsight.CodeInsight

options.RemoveUnneededEntities( 1, 1 )logical = false
options.ConvertMacros( 1, 1 )logical = false
options.DoGenOutput( 1, 1 )logical = false
options.GenOutput( 1, 1 )string = ""
options.DoGenAggregatedHeader( 1, 1 )logical = false
options.GenAggregatedHeaderOutput( 1, 1 )string = "aggregatedHeader.h"
options.DoAggregateSystemInclude( 1, 1 )logical = true
options.RemoveVariableDefinitionInHeader logical = false
options.IsCleanHeaderPass( 1, 1 )logical = false
options.DoSimulinkImportCompliance( 1, 1 )logical = false
options.FileDependenciesOnly( 1, 1 )logical = false
options.Debug( 1, 1 ) = false
options.Lang( 1, 1 )string

options.DoGenCleanPreProcessedFile( 1, 1 )logical = false
options.GenCleanPreProcessedFileOutput( 1, 1 )string = ""



options.KeepAllIncludes( 1, 1 )logical = false



options.KeepAllIncludesInPrimarySource( 1, 1 )logical = true
options.ExtractCodeInsight( 1, 1 )logical = true
options.ExtractInternalKeys( 1, 1 )logical = false
options.ExtractMacroInvocations( 1, 1 )logical = false
options.ConvertPositions( 1, 1 )logical = true
end 
success = true;

self.checkProperties(  );

self.CodeInfo = polyspace.internal.codeinsight.CodeInfo.empty;

if isempty( self.SourceFiles )
m = message( 'cxxfe:codeinsight:InvalidSrc' );
warning( m );
success = false;
return 
end 

if isempty( self.ParsingOptions )
if isfield( options, 'Lang' )
lang = char( options.Lang );
else 
if polyspace.internal.codeinsight.utils.hasCxxSources( self.SourceFiles )
lang = 'cxx';
else 
lang = 'c';
end 
end 
self.ParsingOptions = internal.cxxfe.util.getMexFrontEndOptions( 'lang', lang, 'addMWInc', true );
end 


[ hFiles, cFiles ] = polyspace.internal.codeinsight.utils.getSourcesAndHeaders( self.SourceFiles );
if ( numel( cFiles ) > 0 )
argFile = cFiles( 1 );
extraFiles = [ cFiles( 2:end  ), hFiles ];
else 
argFile = self.SourceFiles( 1 );
extraFiles = self.SourceFiles( 2:end  );
end 
includeDirs = cellstr( convertStringsToChars( self.IncludeDirs ) );
defines = cellstr( convertStringsToChars( self.Defines ) );
self.ParsingOptions.Preprocessor.IncludeDirs = [ self.ParsingOptions.Preprocessor.IncludeDirs( : );includeDirs( : ) ];
self.ParsingOptions.Preprocessor.Defines = [ self.ParsingOptions.Preprocessor.Defines( : );defines( : ) ];
self.ParsingOptions.Verbose = ( options.Debug || self.Debug );
self.ParsingOptions.RemoveUnneededEntities = options.RemoveUnneededEntities;
self.ParsingOptions.ExtraSources = extraFiles;



if ~isempty( extraFiles ) && ~startsWith( lower( self.ParsingOptions.Language.LanguageMode ), 'cxx' )
self.ParsingOptions.ExtraOptions( end  + 1 ) = { '--allow_ints_same_representation' };
end 

if options.DoGenAggregatedHeader
self.ParsingOptions.GenOutput = char( options.GenAggregatedHeaderOutput );
self.ParsingOptions.DoGenOutput = true;
self.ParsingOptions.Preprocessor.KeepLineDirectives = false;
self.ParsingOptions.ExtraOptions{ end  + 1 } = '--codeinsight_emit_header_only';
self.ParsingOptions.ExtraOptions{ end  + 1 } = '--codeinsight_emit_long_long';





self.ParsingOptions.ExtraOptions{ end  + 1 } = '--honor_plain_chars';
if ~options.DoAggregateSystemInclude
self.ParsingOptions.ExtraOptions{ end  + 1 } = '--codeinsight_keep_system_include_directive';
end 
else 
if options.DoGenOutput
if ~isempty( char( options.GenOutput ) )
self.ParsingOptions.GenOutput = char( options.GenOutput );
end 
self.ParsingOptions.DoGenOutput = true;
self.ParsingOptions.ExtraOptions{ end  + 1 } = '--codeinsight_emit_long_long';





self.ParsingOptions.ExtraOptions{ end  + 1 } = '--honor_plain_chars';
end 
end 

if options.ConvertMacros
if options.ExtractMacroInvocations
self.ParsingOptions.ExtraOptions{ end  + 1 } = '--codeinsight_macro_invocation';
end 
end 

if options.DoGenCleanPreProcessedFile
self.ParsingOptions.Preprocessor.KeepLineDirectives = false;
self.ParsingOptions.DoPreprocessOnly = true;
self.ParsingOptions.PreprocOutput = options.GenCleanPreProcessedFileOutput;
self.ParsingOptions.ExtraOptions{ end  + 1 } = '--codeinsight_emit_long_long';
end 

if options.IsCleanHeaderPass
self.ParsingOptions.Language.LanguageExtra{ end  + 1 } = '-I-';
end 

if options.KeepAllIncludes
self.ParsingOptions.ExtraOptions{ end  + 1 } = '--codeinsight_keep_all_includes';
end 
if options.KeepAllIncludesInPrimarySource
self.ParsingOptions.ExtraOptions{ end  + 1 } = '--codeinsight_keep_all_includes_in_primary_file';
end 

cvtOpts = internal.cxxfe.il2ast.Options(  );
if options.FileDependenciesOnly
cvtOpts.Strategy = internal.cxxfe.il2ast.ConvertKind.FileDependency;
else 
cvtOpts.ExtractCodeInsightInfo = true;
cvtOpts.Strategy = internal.cxxfe.il2ast.ConvertKind.GlobalSymbols;
cvtOpts.ConvertMacros = options.ConvertMacros;
cvtOpts.ExtractSimulinkSLCCImportCompliance = options.DoSimulinkImportCompliance;
cvtOpts.RemoveVariableDefinitionsInHeader = options.RemoveVariableDefinitionInHeader;
end 

cvtOpts.ExtractCodeInsightInfo = options.ExtractCodeInsight;
cvtOpts.ExtractInternalKeys = options.ExtractInternalKeys;
cvtOpts.ConvertPositions = options.ConvertPositions;

parseEnv = internal.cxxfe.il2ast.Env( self.ParsingOptions );
parseEnv.parseFile( argFile, cvtOpts );

[ msg, failures ] = evalc( 'internal.cxxfe.util.printFEMessages(parseEnv.getMessages(), false)' );
if failures
self.Errors = msg;
success = false;
return ;
end 

self.CodeInfo = polyspace.internal.codeinsight.CodeInfo( parseEnv.Ast );
self.ParsingOptions = internal.cxxfe.FrontEndOptions.empty;

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpPCXpSQ.p.
% Please follow local copyright laws when handling this file.

