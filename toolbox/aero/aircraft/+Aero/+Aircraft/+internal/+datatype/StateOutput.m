classdef StateOutput
    % emumeration
    enumeration
        CD
        CX
        CY
        CL
        CZ
        Cl
        Cm
        Cn
    end


    methods ( Hidden, Static )
        function vec = getStateOutputVector( frame )
            arguments
                frame( 1, 1 )Aero.Aircraft.internal.datatype.ReferenceFrame
            end

            if ( frame == "Body" )

                vec = [ "CX";"CY";"CZ";"Cl";"Cm";"Cn" ];
            elseif ( frame == "Wind" ) || ( frame == "Stability" )

                vec = [ "CD";"CY";"CL";"Cl";"Cm";"Cn" ];
            end
        end
    end
end



