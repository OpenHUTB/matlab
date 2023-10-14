classdef ( Sealed )NodeType

    % emumeration
    enumeration
        Param( true )
        Category( true )
        Production( true )
        Service( true )
        Tag
        Perspective
    end

    properties
        IsPrimary( 1, 1 )logical
    end

    methods
        function this = NodeType( primary )
            arguments
                primary = false
            end
            this.IsPrimary = primary;
        end
    end
end


