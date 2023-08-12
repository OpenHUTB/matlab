function [ args, h1 ] = getCustomPPFunctionParameters( functionName )
R36
functionName( 1, 1 )string
end 
args = struct.empty;
h1 = "";

w = which( functionName );
if ~isempty( w )
h1 = strtrim( string( help( w ) ) );

s = readlines( w );
startIndex = find( startsWith( strtrim( s ), "arguments" ) );
if isempty( startIndex )


al = regexp( strjoin( s, newline ), 'function\s+.*?(?<openParaen>\(){1,1}(?<args>.*?)(?<closeParen>\)){1,1}', 'names', 'once' );
if ~isempty( al ) && ~isempty( al.args )
al = strrep( strrep( strrep( strrep( al.args, '...', '' ), newline, '' ), ' ', '' ), sprintf( '\t' ), '' );
al = split( al, ',' );
for i = 1:length( al )
s = struct(  );
s.name = al( i );
s.dims = "";
s.type = "";
s.validators = "";
s.comment = "";
s.defaultValue = [  ];
if i == 1
args = s;
else 
args( i ) = s;
end 
end 
end 
return 
end 
startIndex = startIndex( 1 ) + 1;

endIndex = find( startsWith( strtrim( s ), "end" ) );
endIndex = endIndex( endIndex > startIndex );
if isempty( endIndex )
return ;
end 
endIndex = endIndex( 1 ) - 1;

parts = regexp( s( startIndex:endIndex ), "^\s*(?<name>[a-zA-Z0-9_\-\.]+){0,1}\s*(?<dims>\([0-9:]+,[0-9:]+\)){0,1}\s*(?<type>[a-zA-Z0-9_\-\.]+){0,1}\s*(?<validators>\{[a-zA-Z0-9_\-\.\(\), \t]+.*?\}){0,1}\s*(?<defaultValue>=\s*.*?){0,1}\s*(;){0,1}\s*(?<comment>%\s*.*){0,1}$", "names" );
parts = parts( cellfun( @( c )~isempty( c ) && strlength( c.name ) > 0, parts ) );
args = cellfun( @( c )c, parts );
for i = 1:length( args )
args( i ).defaultValue = strtrim( replace( args( i ).defaultValue, "=", "" ) );
args( i ).comment = strtrim( replace( args( i ).comment, "%", "" ) );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp9FQE3a.p.
% Please follow local copyright laws when handling this file.

