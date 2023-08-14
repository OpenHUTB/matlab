classdef SetSmoothing<handle




    properties(Dependent)










Smoothing

    end

    properties(Hidden,Access=protected)
        SigmaInternal(1,1)double{mustBeNonnegative,mustBeFinite,mustBeNonsparse,mustBeReal,mustBeNonempty}=1;
    end

    methods





        function set.Smoothing(self,val)
            self.SigmaInternal=val;
        end

        function val=get.Smoothing(self)
            val=self.SigmaInternal;
        end

    end

end