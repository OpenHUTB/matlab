classdef ( Sealed )BooleanParamType < coderapp.internal.config.AbstractParamType



methods 
function this = BooleanParamType(  )
this@coderapp.internal.config.AbstractParamType( 'boolean',  ...
'coderapp.internal.config.data.BooleanParamData' );
end 
end 

methods ( Access = protected )
function imported = importValue( this, value )
imported = this.toLogical( value );
end 

function value = exportValue( ~, value )
end 

function imported = valueFromSchema( this, value )
imported = this.toLogical( value );
end 
end 

methods 
function adjusted = validate( this, value, dataObj )
R36
this
value
dataObj = [  ]
end 
adjusted = this.toLogical( value );
if ~isempty( dataObj ) && ~isempty( dataObj.AllowedValues )
assert( ismember( adjusted, dataObj.AllowedValues ) );
end 
end 

function choices = getTabCompletions( ~, input, dataObj )
choices = dataObj.AllowedValues;
if isempty( choices )
choices = [ true, false ];
end 
choices = double( choices );
if ~isempty( input )
filter = [  ];
input = lower( input );
if startsWith( 'true', input )
filter = 1;
elseif startsWith( 'false', input )
filter = 0;
end 
choices = intersect( choices, filter, 'stable' );
end 
end 
end 

methods ( Static )
function code = toCode( value )
if value
code = 'true';
else 
code = 'false';
end 
end 

function str = toString( value )
str = coderapp.internal.config.type.BooleanParamType.toCode( value );
end 

function adjusted = toLogical( value, ~ )
R36
value( 1, 1 ){ mustBeNumericOrLogical( value ) }
~
end 
adjusted = logical( value );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpfCvT6U.p.
% Please follow local copyright laws when handling this file.

