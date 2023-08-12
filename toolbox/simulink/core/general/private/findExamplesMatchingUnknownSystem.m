function msg = findExamplesMatchingUnknownSystem( modelName, use_br_tags )












msg = '';
examples = matlab.internal.language.introspective.findExamples( modelName );
if isempty( examples )
return ;
end 
lines = arrayfun( @( example )createHyperlink( example.exampleTitle, example.exampleId, modelName ), examples );
if numel( lines )
if nargin > 1 && use_br_tags
delimiter = "<br>&nbsp;";
else 
delimiter = newline + "  ";
end 
exampleLinks = char( delimiter + join( lines, delimiter ) );
msg = DAStudio.message( 'MATLAB:examples:FunctionInSingleExample', modelName, exampleLinks );
else 
msg = DAStudio.message( 'MATLAB:examples:FunctionInMultipleExamples', modelName, lines{ 1 } );
end 
end 

function exampleLink = createHyperlink( exampleTitle, exampleId, modelName )
if matlab.internal.display.isHot
cmdURL = sprintf( 'matlab:matlab.internal.language.introspective.openExample(''%s'', ''%s'');', exampleId, modelName );
exampleLink = [ '<a href="', cmdURL, '">', exampleTitle, '</a>' ];
else 
exampleLink = exampleTitle;
end 
exampleLink = string( exampleLink );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp5m9hgw.p.
% Please follow local copyright laws when handling this file.

