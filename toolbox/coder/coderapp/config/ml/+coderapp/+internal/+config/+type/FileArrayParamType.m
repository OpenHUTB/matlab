classdef ( Sealed )FileArrayParamType < coderapp.internal.config.type.AbstractFileParamType



methods 
function this = FileArrayParamType(  )
this@coderapp.internal.config.type.AbstractFileParamType(  ...
'file[]', 'coderapp.internal.config.data.FileArrayParamData' );
end 

function adjusted = validate( this, value, dataObj )
R36
this
value{ mustBeText( value ) }
dataObj = [  ]
end 
adjusted = cellstr( value );
this.validateArraySize( adjusted, dataObj );
for i = 1:numel( adjusted )
this.validateFile( adjusted{ i } );
end 
end 
end 

methods ( Access = protected )
function imported = importValue( this, value )
imported = this.validate( value );
end 

function value = exportValue( ~, value )
end 

function value = valueFromSchema( this, value )
value = this.validate( value );
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpbcu4jG.p.
% Please follow local copyright laws when handling this file.

