

classdef TimeFeatureExtractor<signal.labeler.controllers.FeatureExtraction.FeatureExtractorActionBase

    methods(Access=protected)
        function y=getFeatureExtractorConstructor(~)
            y=signalTimeFeatureExtractor;
        end
    end

    methods
        function name=getFeatureExtractorNameForDefinitionDescription(~)
            name='Time Feature';
        end
    end
end

