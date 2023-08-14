classdef FeatureOff<handle
    properties(SetAccess=private,GetAccess=private)
Value
ID
    end

    methods
        function this=FeatureOff(id,value)
            this.ID=id;
            this.Value=slfeature(id,value);
        end

        function delete(this)
            slfeature(this.ID,this.Value);
        end
    end
end
