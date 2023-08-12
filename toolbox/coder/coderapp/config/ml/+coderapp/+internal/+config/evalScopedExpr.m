function result = evalScopedExpr( expr, vars, values, debug )
R36
expr{ mustBeTextScalar( expr ) }
vars cell = {  }
values cell = {  }
debug( 1, 1 )logical = false
end 



assert( iscellstr( vars ) && iscell( values ) && numel( vars ) == numel( values ),  ...
'Invalid workspace arguments' );%#ok<ISCLSTR>

arg.vars = vars;
arg.values = values;
arg.expr = expr;

try 
result = I_bufferFun_6Gz8o9h_078dq4( arg );
catch me

scrubbedCause.message = me.message;
scrubbedCause.stack = repmat( me.stack, 0, 1 );
scrubbedCause.identifier = me.identifier;
try 
error( scrubbedCause );
catch scrubbedCause
end 



if debug
debugVarName = getUniqueDebugVar(  );
assignin( 'base', debugVarName, @(  )evalRepro( expr, vars, values ) );
errSuffix = sprintf( '\n<a href="matlab:%s()">Rerun</a>', debugVarName );
else 
errSuffix = '';
end 


preErr.message = sprintf( '\nError evaluating expression:\n\t<strong>%s</strong>%s', expr, errSuffix );
preErr.identifier = '';
preErr.stack = me.stack;
preErr.stack = preErr.stack( 1:end  - 1 );

try 
error( preErr );
catch generated
generated = generated.addCause( scrubbedCause );
throw( generated );
end 
end 


function result = evalRepro( expr, vars, values )
for i = 1:numel( vars )
assignin( 'base', vars{ i }, values{ i + 1 } );
end 
fprintf( '<strong>Evaluating expression: %s</strong>\n', expr );
try 
result = evalin( 'base', expr );
catch me
err.message = me.message;
err.identifier = me.identifier;
err.stack = me.stack( 1:end  - 2 );
error( err );
end 
end 

function name = getUniqueDebugVar(  )
taken = evalin( 'base', 'who' );
name = 'evalDebug';
if ~ismember( name, taken )
return 
end 
for i = 2:1000
generatedName = [ name, num2str( i ) ];
if ~ismember( generatedName, taken )
name = generatedName;
break 
end 
end 
end 
end 


function out = I_bufferFun_6Gz8o9h_078dq4( I__217c5q4__zY_bU2A_R1___9618a7__ )



out = I_doEvalScopedExpr_1t7X3_r2fxQ2_( I__217c5q4__zY_bU2A_R1___9618a7__ );
end 


function I__217c5q4__zY_bU2A_R1___9618a7__ = I_doEvalScopedExpr_1t7X3_r2fxQ2_( I__217c5q4__zY_bU2A_R1___9618a7__ )
if nargin == 0 || ~isstruct( I__217c5q4__zY_bU2A_R1___9618a7__ )
I_disallowed_24zvn1_y35Y_(  );
end 
if any( strcmp( I__217c5q4__zY_bU2A_R1___9618a7__.vars, 'I__217c5q4__zY_bU2A_R1___9618a7__' ) )
error( 'Collision with reserved variable name "I__217c5q4__zY_bU2A_R1___9618a7__"' );
end 


eval( sprintf( '[%s] = I__217c5q4__zY_bU2A_R1___9618a7__.values{:};',  ...
strjoin( I__217c5q4__zY_bU2A_R1___9618a7__.vars, ',' ) ) );

I__217c5q4__zY_bU2A_R1___9618a7__ = I__217c5q4__zY_bU2A_R1___9618a7__.expr;
I__217c5q4__zY_bU2A_R1___9618a7__ = eval( I__217c5q4__zY_bU2A_R1___9618a7__ );
end 


function I_disallowed_24zvn1_y35Y_(  )
stack = dbstack( 1 );
error( 'Function "%s" cannot be called from within a param expression', stack( 1 ).name );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLYiZNc.p.
% Please follow local copyright laws when handling this file.

