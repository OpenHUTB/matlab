function minimalScript = minimizeScript( scriptLines, variables, statements, lastLine, lineNos )
R36
scriptLines( 1, : )string;
variables( 1, : )string = [  ];
statements( 1, : ){ mustBeInteger, mustBePositive } = [  ];
lastLine( 1, 1 ){ mustBeInteger, mustBeNonnegative } = numel( scriptLines );
lineNos( 1, : ){ mustBeInteger, mustBePositive } = 1:lastLine;
end 

assert( isempty( lineNos ) || lastLine >= lineNos( end  ) );
assert( issorted( lineNos ) );
assert( isequal( size( lineNos ), size( scriptLines ) ) );

if isempty( scriptLines )
fullScript = "";
else 
[ fullScript, scriptLines, lineNos ] = stripErrors( scriptLines, lineNos );
end 

usingLastLine = false;

if ~isempty( statements )
missingLines = setdiff( statements, lineNos );
if ~isempty( missingLines )
missingLine = missingLines( 1 );
if missingLine > lastLine
error( message( 'MATLAB:internal:lasso:LineTooHigh', missingLine, lastLine ) );
else 
error( message( 'MATLAB:internal:lasso:LineRemoved', missingLine ) );
end 
end 
elseif isempty( variables )
usingLastLine = true;
statements = lastLine;
end 

statements = find( ismember( lineNos, statements ) );

if usingLastLine && isempty( statements )
error( message( 'MATLAB:internal:lasso:LastLineRemoved' ) );
end 

tree = mtree( fullScript );
treeLines = lineno( tree );

ids = select( tree, ismember( treeLines, statements ) );

if ~isempty( variables )
for variable = variables
newId = tree.mtfind( 'Kind', 'ID', 'String', variable );
newId = geteq( newId );
if isempty( newId )
error( message( 'MATLAB:internal:lasso:VariableNotFound', variable ) );
end 
indices = newId.indices;
newId = select( tree, indices( end  ) );
ids = ids | newId;
end 
end 



ids = expandExpression( ids );

numIds = 0;
while numIds ~= count( ids )
numIds = count( ids );
depIds = depends( ids );
setsIds = geteq( sets( depIds ) );
depIds = setsIds | depIds;

depIds = expandExpression( depIds );

callAns = mtfind( depIds, 'Kind', 'CALL', 'Left.Fun', 'ans' );
if ~isempty( callAns )

setsAns = expandExpression( select( tree, ismember( treeLines, lineno( callAns ) - 1 ) ) );
depIds = depIds | setsAns;
end 

ids = depIds | ids;
end 

prints = tree.mtfind( 'Kind', 'PRINT' );
semiLines = lastone( prints );
scriptLines( semiLines ) = scriptLines( semiLines ) + ";";

lineNos = lineno( ids );
endPos = lastone( ids );
endPos( endPos <= lineNos ) = [  ];

minimalScript = scriptLines( unique( [ lineNos;endPos ] ) );
end 

function [ fullScript, scriptLines, lineNos ] = stripErrors( scriptLines, lineNos )
while true
fullScript = join( scriptLines, newline );

errors = checkcode( '-text', fullScript, '.m', '-struct', '-id', '-config=factory' );

errorLines = [  ];

for err = errors'
switch err.id
case "ENDPAR"

errorLines = [ errorLines, err.line:numel( scriptLines ) ];%#ok<AGROW>
case { "ENDCT", "ENDCT2", "ENDCT3", "ENDCT4", "NOPAR2" }

errorLines( end  + 1 ) = double( err.line );%#ok<AGROW>                
end 
end 

if isempty( errorLines )
break ;
end 

scriptLines( errorLines ) = [  ];
lineNos( errorLines ) = [  ];
end 
end 


function ids = expandExpression( ids )
parent = trueparent( ids );
while ~isempty( parent - ids )
ids = subtree( parent );
parent = trueparent( ids );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp9A3cZr.p.
% Please follow local copyright laws when handling this file.

