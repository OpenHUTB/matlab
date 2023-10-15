function exposeParameter( this, exposeOptions )

arguments
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

