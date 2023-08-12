function exposeParameter( this, exposeOptions )




R36
this{ mustBeA( this, 'systemcomposer.arch.Architecture' ) }
exposeOptions.Path{ mustBeTextScalarOrObject }
exposeOptions.Parameters{ mustBeText } = "all"
exposeOptions.ShortName{ mustBeTextScalar } = ""
end 

exposeOptions.operation = 'expose';
inputArgs = namedargs2cell( exposeOptions );
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPkwGic.p.
% Please follow local copyright laws when handling this file.

