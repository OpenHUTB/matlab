classdef ( Sealed )Size




properties 
Dimensions struct = struct( 'length', {  }, 'variableSized', {  } )
end 

properties ( Dependent, SetAccess = private )
NumDimensions
NumElements
end 

methods 
function this = Size( arg, varDims )
if nargin == 0
return 
end 
if isstruct( arg )
narginchk( 1, 1 );
this.Dimensions = arg;
elseif isa( arg, 'coderapp.internal.codertype.Dimension' )
narginchk( 1, 1 );
lengths = double( [ arg.Length ] );
lengths( [ arg.Sizedness ] == 'UNBOUNDED' ) = Inf;
varSized = [ arg.Sizedness ] ~= 'FIXED';
this.Dimensions = struct(  ...
'length', num2cell( lengths ),  ...
'variableSized', num2cell( varSized ) );
else 
if nargin < 2
varDims = [  ];
end 
this = this.append( arg, varDims );
end 
end 

function this = set.Dimensions( this, dims )
dims = validateDimensionStructs( dims );
[ dims( [ dims.length ] == Inf ).variableSized ] = deal( true );
this.Dimensions = dims;
end 

function this = append( this, len, varSized )
if nargin < 3 || isempty( varSized )
varSized = false( 1, numel( len ) );
end 
start = numel( this.Dimensions ) + 1;
len = num2cell( double( len ) );
[ this.Dimensions( start:start + numel( len ) - 1 ).length ] = len{ : };
varSized = num2cell( varSized );
[ this.Dimensions( start:end  ).variableSized ] = varSized{ : };
end 

function [ sz, variable_dims ] = toNewTypeArgs( this, toChar )
if isempty( this.Dimensions )
sz = [  ];
variable_dims = [  ];
else 
sz = [ this.Dimensions.length ];
variable_dims = [ this.Dimensions.variableSized ];
end 
if nargin > 1 && toChar
if isscalar( sz )
sz = num2str( sz );
variable_dims = num2str( variable_dims );
else 
sz = [ '[', strjoin( compose( '%d', sz ), ' ' ), ']' ];
variable_dims = [ '[', strjoin( compose( '%d', variable_dims ) ), ']' ];
end 
end 
end 

function mfzDims = toMfzDims( this )
R36
this( 1, 1 )
end 
sDims = this.Dimensions;
mfzDims = repmat( coderapp.internal.codertype.Dimension, 1, numel( sDims ) );

for i = 1:numel( sDims )
if sDims( i ).length == Inf
mfzDims( i ).Sizedness = "UNBOUNDED";
else 
mfzDims( i ).Length = sDims( i ).length;
if sDims( i ).variableSized
mfzDims( i ).Sizedness = "VARIABLE";
end 
end 
end 
end 

function num = get.NumDimensions( this )
num = numel( this.Dimensions );
end 

function num = get.NumElements( this )
num = prod( [ this.Dimensions.length ] );
end 
end 

methods ( Static )
function size = scalar(  )
size = codergui.internal.type.Size( [ 1, 1 ] );
end 
end 
end 


function structVal = validateDimensionStructs( structVal )
if isempty( structVal )
structVal = struct( 'length', {  }, 'variableSized', {  } );
return ;
end 
if ~all( isfield( structVal, { 'length', 'variableSized' } ) )
error( 'Dimension arguments must be structs with "length" and "variableSized" fields' );
end 
largeDims = ( [ structVal.length ] >= intmax );
varSize = [ structVal.variableSized ];
if any( largeDims ) && numel( largeDims ) == numel( varSize ) && ~all( varSize( largeDims ) )
tmerror( message( 'coderApp:typeMaker:staticDimensionsMustBeLessThanIntmax' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmptBdHKd.p.
% Please follow local copyright laws when handling this file.

