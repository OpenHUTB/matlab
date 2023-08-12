classdef ( Sealed )StringArrayParamType < coderapp.internal.config.type.AbstractStringParamType



methods 
function this = StringArrayParamType(  )
this@coderapp.internal.config.type.AbstractStringParamType(  ...
'string[]', 'coderapp.internal.config.data.StringArrayParamData' );
end 
end 

methods 
function adjusted = validate( this, value, dataObj )
adjusted = this.validateStringArray( value, dataObj );
end 
end 

methods ( Access = protected )
function imported = importValue( this, value )
imported = this.validateStringArray( value );
end 

function value = exportValue( ~, value )
end 

function imported = valueFromSchema( this, value )
imported = this.validateStringArray( value );
end 
end 

methods ( Access = private )
function value = validateStringArray( this, value, dataObj )
R36
this
value
dataObj = [  ]
end 
if isempty( value )
value = {  };
else 
mustBeText( value );
end 
value = cellstr( value );
if ~isempty( dataObj )
this.validateArraySize( value, dataObj );
for i = 1:numel( value )
this.validateString( value{ i }, dataObj );
end 
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpl_u2XU.p.
% Please follow local copyright laws when handling this file.

