classdef ( Sealed )EnumParamType < coderapp.internal.config.type.AbstractEnumParamType



methods 
function this = EnumParamType(  )
this@coderapp.internal.config.type.AbstractEnumParamType( 'enum',  ...
'coderapp.internal.config.data.EnumParamData' );
end 
end 

methods 
function adjusted = validate( this, value, dataObj )
R36
this
value{ mustBeTextScalar( value ) }
dataObj = [  ]
end 
adjusted = char( value );
this.checkEnumValue( adjusted, dataObj );
end 
end 

methods ( Access = protected )
function imported = importValue( this, value )
imported = this.toChar( value );
end 

function value = exportValue( ~, value )
end 

function value = valueFromSchema( this, value )
value = this.toChar( value );
end 
end 

methods ( Static )
function value = toChar( value )
R36
value{ mustBeTextScalar( value ) }
end 
value = char( value );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpKDuEua.p.
% Please follow local copyright laws when handling this file.

