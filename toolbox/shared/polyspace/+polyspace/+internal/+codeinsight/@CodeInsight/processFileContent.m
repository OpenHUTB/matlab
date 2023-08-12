function newcontent = processFileContent( sourceFile, options )




R36
sourceFile( 1, 1 )string
options.RemoveEmptyLines logical = true
options.RemoveLinePragmas logical = true
options.RemoveAllPragmas logical = false
options.RemovePatterns( 1, : )string = [  ]
end 

content = fileread( sourceFile );
newcontent = string( content );
if ~isempty( options.RemovePatterns )
for pattern = options.RemovePatterns
replaceWith = options.RemovePatterns;
replaceWith( : ) = "";
newcontent = regexprep( newcontent, options.RemovePatterns, replaceWith );
end 
end 

if options.RemoveLinePragmas
newcontent = regexprep( newcontent, '# [0-9]+.*', '', 'lineanchors', 'dotexceptnewline' );
end 

if options.RemoveEmptyLines
newcontent = regexprep( newcontent, { '\r', '\n\n+' }, { '', '\n' } );
end 

contentLines = split( newcontent, newline );
lineNb = numel( contentLines );
linesToKeep = ones( 1, lineNb, 'logical' );
for idx = 1:lineNb
currentLine = contentLines( idx );
currentLine = strip( currentLine );
if options.RemoveEmptyLines && ( isempty( currentLine ) || currentLine == "" )
linesToKeep( idx ) = false;
continue ;
end 
if options.RemoveLinePragmas && startsWith( currentLine, "#line" )
linesToKeep( idx ) = false;
continue ;
end 
if options.RemoveAllPragmas && ( startsWith( currentLine, "#pragma" ) || startsWith( currentLine, "__pragma" ) )
linesToKeep( idx ) = false;
end 
end 
newcontentLines = contentLines( linesToKeep );
if isempty( newcontentLines )
newcontent = "";
else 
newcontent = join( newcontentLines, newline );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp7d4hN_.p.
% Please follow local copyright laws when handling this file.

