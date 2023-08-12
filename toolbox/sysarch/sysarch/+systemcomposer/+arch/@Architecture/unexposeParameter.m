function unexposeParameter( this, unexposeOptions )




R36
this{ mustBeA( this, 'systemcomposer.arch.Architecture' ) }
unexposeOptions.Path{ mustBeTextScalarOrObject }
unexposeOptions.Parameters{ mustBeText } = "all"
end 

unexposeOptions.operation = 'unexpose';
inputArgs = namedargs2cell( unexposeOptions );
this.performExposeOrUnexposeOfParameter( inputArgs{ : } );

end 

function mustBeTextScalarOrObject( value )


valid = false;
if isa( value, 'systemcomposer.arch.BaseComponent' )
valid = true;
else 
inputTxt = string( value );
if numel( inputTxt ) == 1
valid = true;
end 
end 

if ~valid
error( 'Specify the path as a Component object or a string' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpB3Ba_u.p.
% Please follow local copyright laws when handling this file.

