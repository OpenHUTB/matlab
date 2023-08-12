function newcontent = reIntroduceStdHeaderFiles( filecontent )





R36
filecontent( 1, 1 )string
end 

if ~polyspace.internal.codeinsight.utils.codeInsightFeature( "PSCleanFile" )
error( "This function should only used for internal testing" )
end 







includeDirectiveToRemove = [ "polyspace_std_decls.h", "polyspace_internal_definitions.h" ];
includeDirectiveToReplace =  ...
[ "assert.h",  ...
"complex.h",  ...
"ctype.h",  ...
"errno.h",  ...
"fenv.h",  ...
"float.h",  ...
"inttypes.h",  ...
"iso646.h",  ...
"limits.h",  ...
"locale.h",  ...
"math.h",  ...
"memory.h",  ...
"setjmp.h",  ...
"signal.h",  ...
"stdalign.h",  ...
"stdarg.h",  ...
"stdatomic.h",  ...
"stdbool.h",  ...
"stddef.h",  ...
"stdint.h",  ...
"stdio.h",  ...
"stdlib.h",  ...
"stdnoreturn.h",  ...
"string.h",  ...
"tgmath.h",  ...
"threads.h",  ...
"time.h",  ...
"uchar.h",  ...
"wchar.h",  ...
"wctype.h" ];
contentLines = split( filecontent, newline );
removeLine = false;
lineNb = numel( contentLines );
linesToKeep = ones( 1, lineNb, 'logical' );
includeFileToAdd = string( [  ] );
currentInclude = "";
for lidx = 1:numel( contentLines )
line = contentLines( lidx );
if line.startsWith( "#line" ) || ~isempty( regexp( line, '# [0-9]+.*', 'once' ) )
lstr = line.lower;
[ l, u ] = regexp( lstr, '\w*.h"' );
if ~isempty( l )
currentInclude = lstr.extractBetween( l( 1 ), u( 1 ) - 1 );
if ~isempty( find( strcmp( includeDirectiveToRemove, currentInclude ), 1 ) )
removeLine = true;
else 
if ~isempty( find( strcmp( includeDirectiveToReplace, currentInclude ), 1 ) )
includeFileToAdd( end  + 1 ) = "#include <" + currentInclude + ">";%#ok<AGROW>
removeLine = true;
else 
removeLine = false;
end 
end 
end 
end 


if removeLine
lclean = regexprep( line, ' +', ' ' );

if strcmp( currentInclude, "ctype.h" )
if isempty( regexp( lclean, 'extern unsigned char \w+\[\];', 'once' ) )
linesToKeep( lidx ) = false;
end 
else 
if strcmp( currentInclude, "stdio.h" )
if isempty( regexp( lclean, 'extern FILE \w+\[\];', 'once' ) ) ...
 && isempty( regexp( lclean, 'extern unsigned int \w+\[\];', 'once' ) ) ...
 && isempty( regexp( lclean, 'typedef unsigned int \w+;', 'once' ) ) ...
 && isempty( regexp( lclean, 'int \w+\(char \*, \w+, const char \*, va_list\);', 'once' ) )
linesToKeep( lidx ) = false;
end 
else 
if strcmp( currentInclude, "stdlib.h" )
if isempty( regexp( lclean, 'extern unsigned char \w+;', 'once' ) ) ...
 && isempty( regexp( lclean, 'typedef unsigned int \w+;', 'once' ) )
linesToKeep( lidx ) = false;
end 
else 
if strcmp( currentInclude, "stdarg.h" )
if isempty( regexp( lclean, 'extern void \*\*\w+;', 'once' ) ) ...
 && isempty( regexp( lclean, 'extern int \w+; extern volatile int \w+;', 'once' ) )
linesToKeep( lidx ) = false;
end 
else 
if strcmp( currentInclude, "memory.h" )
if isempty( regexp( lclean, 'typedef unsigned int \w+;', 'once' ) )
linesToKeep( lidx ) = false;
end 
else 
linesToKeep( lidx ) = false;
end 
end 
end 
end 
end 
else 
if line.contains( "__inline__" )
contentLines( lidx ) = line.replace( "__inline__", "inline" );
end 
end 

end 
newcontentLines = contentLines( linesToKeep );
newcontent = join( newcontentLines, newline );
if ~isempty( includeFileToAdd )
newcontent = join( unique( includeFileToAdd ), newline ) + newline + newcontent;
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpaGBQ27.p.
% Please follow local copyright laws when handling this file.

