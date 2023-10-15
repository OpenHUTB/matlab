function unexposeParameter( this, unexposeOptions )

arguments
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

