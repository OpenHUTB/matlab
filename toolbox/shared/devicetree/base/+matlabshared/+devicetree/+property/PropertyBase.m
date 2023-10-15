classdef PropertyBase < matlabshared.devicetree.util.Commentable & matlab.mixin.Heterogeneous

    properties ( SetAccess = protected )

        Name string
    end

    methods
        function obj = PropertyBase( name )
            arguments
                name
            end

            obj.Name = name;
        end
    end
end
