classdef(Abstract)FeatureProperty<handle



    properties
        upright=false;
        featureNumber=0.5;
        featureQuality=0.5;
    end

    properties(Dependent)
matchThreshold
maxRatio
    end

    methods
        [fixedPoints,movingPoints]=detectFeatures(self,fixed,moving)
    end

    methods

        function val=get.matchThreshold(self)
            val=(1-self.featureQuality)*100;

            if val==0
                val=eps;
            end
        end

        function val=get.maxRatio(self)
            val=1-self.featureQuality;

            if val==0
                val=eps;
            end
        end

    end

end