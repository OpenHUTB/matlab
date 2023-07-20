classdef Reference<handle




    properties
        Value;
    end

    methods

        function this=Reference(value)
            if nargin>0
                this.Value=value;
            end
        end

    end

end

