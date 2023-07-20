

classdef FrequencyFeatureExtractor<signal.labeler.controllers.FeatureExtraction.FeatureExtractorActionBase

    methods(Access=protected)
        function y=getFeatureExtractorConstructor(~)
            y=signalFrequencyFeatureExtractor;
        end

        function[isTurnOnFeatures,featureNames]=getFeatureNamesAndStatusFlag(this,features,parameters)
            [isTurnOnFeatures,featureNames]=getFeatureNamesAndStatusFlag@signal.labeler.controllers.FeatureExtraction.FeatureExtractorActionBase(this,features,parameters);
            welchPSDFeatureName="WelchPSD";
            if~any(features.contains(welchPSDFeatureName))


                isTurnOnFeatures=[false;isTurnOnFeatures(:)];
                featureNames=[welchPSDFeatureName;featureNames(:)];
            end
        end

        function featureParams=getFeatureParameters(this,featureName,parameters)
            clientFeatureParams=getFeatureParameters@signal.labeler.controllers.FeatureExtraction.FeatureExtractorActionBase(this,featureName,parameters);
            if featureName=="WelchPSD"
                featureParams=struct;
                modeSampleRate=this.Model.getModeSampleRate();
                if isfield(clientFeatureParams,'Window')
                    windowType=clientFeatureParams.Window.WindowType;
                    windowLength=clientFeatureParams.Window.WindowLength;
                    if modeSampleRate>0
                        windowLength=floor(windowLength*modeSampleRate);
                    end
                    windowParameter=clientFeatureParams.Window.WindowParameter;
                    switch windowType
                    case "Hamming"
                        window=hamming(windowLength);
                    case "Hann"
                        window=hann(windowLength);
                    case "Kaiser"
                        window=kaiser(windowLength,windowParameter);
                    case "Rectangular"
                        window=rectwin(windowLength);
                    case "Chebyshev"
                        window=chebwin(windowLength,windowParameter);
                    case "Barlett"
                        window=bartlett(windowLength);
                    case "Blackman"
                        window=blackman(windowLength);
                    case "FlatTop"
                        window=flattopwin(windowLength);
                    case "Gaussian"
                        window=gausswin(windowLength);
                    case "Nuttall"
                        window=nuttallwin(windowLength);
                    case "Triangular"
                        window=triang(windowLength);
                    end
                    featureParams.Window=window;
                end

                if isfield(clientFeatureParams,'OverlapLength')
                    if modeSampleRate>0
                        featureParams.OverlapLength=floor(clientFeatureParams.OverlapLength*modeSampleRate);
                    end
                end
                if isfield(clientFeatureParams,'FFTLength')
                    featureParams.FFTLength=clientFeatureParams.FFTLength;
                end
                if isfield(clientFeatureParams,'FrequencyVector')
                    featureParams.FrequencyVector=linspace(clientFeatureParams.FrequencyVector.Min,...
                    clientFeatureParams.FrequencyVector.Max,...
                    clientFeatureParams.FrequencyVector.Length);
                end
            else
                featureParams=clientFeatureParams;
            end
        end
    end

    methods
        function name=getFeatureExtractorNameForDefinitionDescription(~)
            name='Spectral Feature';
        end
    end
end

