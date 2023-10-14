function TF = setPlaneInteractions( str, style )

arguments
    str( :, 1 )string
    style( 1, 1 )string{ mustBeMember( style, [ "clip", "slice" ] ) }
end

TF = [ false, false, false, false ];

if ~isempty( str )

    validStrings = { 'all', 'none', 'add', 'remove', 'rotate', 'translate' };

    for idx = 1:numel( str )
        validString = validatestring( str( idx ), validStrings );

        switch validString
            case "all"
                if numel( str ) > 1
                    if style == "clip"
                        error( message( 'images:volume:clippingInteractions' ) );
                    else
                        error( message( 'images:volume:sliceInteractions' ) );
                    end
                end
                TF = [ true, true, true, true ];

            case "none"
                if numel( str ) > 1
                    if style == "clip"
                        error( message( 'images:volume:clippingInteractions' ) );
                    else
                        error( message( 'images:volume:sliceInteractions' ) );
                    end
                end
                TF = [ false, false, false, false ];

            case "add"
                TF( 1 ) = true;

            case "remove"
                TF( 2 ) = true;

            case "rotate"
                TF( 3 ) = true;

            case "translate"
                TF( 4 ) = true;

        end

    end

end

end


