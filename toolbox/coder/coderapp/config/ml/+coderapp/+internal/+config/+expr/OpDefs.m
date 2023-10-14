classdef ( Sealed )OpDefs




emumeration 
Equals( { 'eq', 'equals' }, 'EQ', @( a, b )isequal( a, b ), 'boolean' )
NotEquals( { 'ne', 'notEquals' }, 'NOT_EQ', @( a, b )~isequal( a, b ), 'boolean' )
Not( 'not', 'NOT', @( a )~a, 'boolean' )
GreaterThan( 'gt', 'GT', @( a, b )a > b, 'boolean' )
GreaterThanEquals( 'ge', 'GT_EQ', @( a, b )a >= b, 'boolean' )
LessThan( 'lt', 'LT', @( a, b )a < b, 'boolean' )
LessThanEquals( 'le', 'LT_EQ', @( a, b )a <= b, 'boolean' )
Or( { 'any', 'or' }, 'OR', @( a, b, varargin )any( [ a, b, varargin{ : } ] ), 'boolean' )
And( { 'all', 'and' }, 'AND', @( a, b, varargin )all( [ a, b, varargin{ : } ] ), 'boolean' )
Xor( { 'one', 'xor' }, 'XOR', @( a, b, varargin )xor( [ a, b, varargin{ : } ] ), 'boolean' )
Plus( { 'sum', 'plus' }, 'PLUS', @( a, b, varargin )sum( [ a, b, varargin{ : } ] ), 'number' )
Minus( { 'diff', 'minus' }, 'MINUS', @( a, b, varargin )diff( [ a, b, varargin{ : } ] ), 'number' )
Member( { 'member', 'in' }, 'MEMBER', @( a, b, varargin )typeAwareIsMember( false, a, b, varargin ), 'boolean' )
NotMember( { 'notMember', 'notIn' }, 'NOT_MEMBER', @( a, b, varargin )typeAwareIsMember( true, a, b, varargin ), 'boolean' )
Has( { 'has', 'notEmpty' }, 'HAS', @( a )~isempty( a ), 'boolean' )
NotHas( { 'notHas', 'empty' }, 'NOT_HAS', @( a )isempty( a ), 'boolean' )
Count( { 'count', 'numel' }, 'COUNT', @( a )numel( a ), 'number' )
Message( 'message', 'MESSAGE', @( a, varargin )getString( message( a, varargin{ : } ) ), 'string' )
IsA( 'isa', 'ISA', @( a, b )isa( a, b ), 'boolean' )
If( 'if', 'IF_THEN', function_handle.empty(  ), '',  - 1 )
end 

properties 
Keywords{ mustBeText( Keywords ) } = {  }
MfzOperator coderapp.internal.config.expr.Operator
Arity double
Evaluator function_handle
StaticType coderapp.internal.config.expr.ValueType
end 

methods 
function this = OpDefs( keywords, mfzOpName, evalFun, staticType, arity )
arguments
keywords
mfzOpName
evalFun = function_handle.empty(  )
staticType = ''
arity = [  ]
end 
this.Keywords = cellstr( keywords );
this.MfzOperator = coderapp.internal.config.expr.Operator( mfzOpName );
this.Evaluator = evalFun;
if isempty( arity )
arity = nargin( evalFun );
end 
this.Arity = arity;
if ~isempty( staticType )
this.StaticType = coderapp.internal.config.expr.ValueType( staticType );
end 
end 
end 

methods ( Static )
function ops = fromKeywords( keywords )
arguments
keywords{ mustBeText( keywords ) }
end 

keywords = cellstr( keywords );
byKeyword = coderapp.internal.config.expr.OpDefs.getKeywordStruct(  );
resolved = isfield( byKeyword, keywords );
if ~all( resolved )
error( 'Not valid keywords: %s', strjoin( keywords( ~resolved ), ', ' ) );
end 
ops = repmat( coderapp.internal.config.expr.OpDefs.Equals, size( keywords ) );
for i = 1:numel( keywords )
ops( i ) = byKeyword.( keywords{ i } );
end 
end 

function opDefs = fromMfzOperator( mfzOps )
if ischar( mfzOps ) || iscell( mfzOps )
mfzOps = coderapp.internal.config.expr.Operator( mfzOps );
end 
alignment = coderapp.internal.config.expr.OpDefs.getMfzAlignment(  );
opDefs = alignment( mfzOps );
end 

function byKeywordValue = getKeywordStruct(  )
persistent byKeyword;
if isempty( byKeyword )
values = enumeration( 'coderapp.internal.config.expr.OpDefs' );
keywords = { values.Keywords };
byKeyword = struct(  );
for i = 1:numel( values )
for j = 1:numel( keywords{ i } )
byKeyword.( keywords{ i }{ j } ) = values( i );
end 
end 
end 
byKeywordValue = byKeyword;
end 

function byMfzOpValue = getMfzAlignment(  )
persistent byMfzOp;
if isempty( byMfzOp )
values = enumeration( 'coderapp.internal.config.expr.OpDefs' );
mfzOps = double( [ values.MfzOperator ] );
[ ~, idx ] = sort( mfzOps );
byMfzOp = values( idx );
end 
byMfzOpValue = byMfzOp;
end 
end 
end 


function result = typeAwareIsMember( negate, a, b, rest )
if ischar( b )
set = { b, rest{ : } };%#ok<CCAT>
else 
set = [ b, rest{ : } ];
end 
if ischar( b ) || isstring( b )
result = any( strcmp( a, set ) ) ~= negate;
else 
result = any( a == set ) ~= negate;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpKgHPc8.p.
% Please follow local copyright laws when handling this file.

