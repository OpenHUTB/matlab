classdef CXXException < MException

    properties
        Type
    end

    methods
        function obj = CXXException( aTypeName, aMessageText )
            arguments
                aTypeName( 1, : )char
                aMessageText( 1, : )char
            end
            obj = obj@MException( 'coderApp:util:CXXException', aMessageText );
            obj.Type = aTypeName;
        end
    end

    methods ( Static )
        function raise( aTypeName, aMessageText )
            arguments
                aTypeName( 1, : )char
                aMessageText( 1, : )char
            end
            throwAsCaller( coderapp.internal.util.foundation.CXXException( aTypeName, aMessageText ) );
        end
    end
end
