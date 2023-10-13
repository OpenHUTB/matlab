classdef ( Sealed )OperationSpecification

    properties
        M
        K
        N
    end

    properties ( Constant )
        Datatype( 1, 1 )string = 'single'
        ProcessingUnit( 1, 1 )string = 'CPU'
    end

    methods
        function obj = OperationSpecification( nvps )

            arguments
                nvps.M( 1, 1 ){ mustBeInteger, mustBePositive }
                nvps.K( 1, 1 ){ mustBeInteger, mustBePositive }
                nvps.N( 1, 1 ){ mustBeInteger, mustBePositive }
            end

            obj = dltargets.internal.assignNVPsToClassObject( obj, nvps );
        end
    end
end


