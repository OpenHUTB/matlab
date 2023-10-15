classdef Position

    properties
        X( 1, 1 )double
        Y( 1, 1 )double
        Z( 1, 1 )double
    end

    methods
        function obj = Position( namedArgs )

            arguments
                namedArgs.X( 1, 1 )double = 0
                namedArgs.Y( 1, 1 )double = 0
                namedArgs.Z( 1, 1 )double = 0
            end
            obj.X = namedArgs.X;
            obj.Y = namedArgs.Y;
            obj.Z = namedArgs.Z;
        end
    end
end

