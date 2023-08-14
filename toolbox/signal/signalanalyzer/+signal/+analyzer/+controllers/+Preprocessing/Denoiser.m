

classdef Denoiser<signal.analyzer.controllers.Preprocessing.PreprocessorActionBase

    properties(Hidden)
WaveletName
WaveletNumber
DenoisingMethod
ThresholdRule
NoiseEstimate
Levels
QValue
    end

    methods(Hidden)

        function this=Denoiser(settings)

            this.Engine=Simulink.sdi.Instance.engine;

            this.WaveletName=settings.waveletName;
            this.WaveletNumber=settings.waveletNumber;
            this.DenoisingMethod=settings.denoisingMethod;
            this.Levels=settings.levels;
            this.ThresholdRule=settings.thresholdRule;
            this.QValue=settings.QValue;
            this.NoiseEstimate=settings.noiseEstimate;
        end


        function[successFlag,data,message,currentParameters]=processData(this,sigID,~,currentParameters)





            this.NeedCleanUp=true;
            message='';
            data=this.Engine.getSignalDataValues(sigID);
            wname=string(this.WaveletName)+this.WaveletNumber;
            denoisingMethod=this.DenoisingMethod;

            if denoisingMethod=="FDR"
                denoisingMethod={denoisingMethod,this.QValue};
            end

            try
                data.Data=wdenoise(data.Data,this.Levels,...
                'Wavelet',wname,...
                'DenoisingMethod',denoisingMethod,...
                'ThresholdRule',this.ThresholdRule,...
                'NoiseEstimate',this.NoiseEstimate);

                successFlag=true;


                this.NeedCleanUp=false;

            catch ME
                if(any(strcmp(ME.identifier,["MATLAB:WDENOISE:notLessEqual","Wavelet:FunctionInput:InvalidBlockLevel"])))


                    message=this.getMaxLevels(this.DenoisingMethod,wname,numel(data.Data))+1;
                end
                successFlag=false;
            end
        end
    end

    methods(Access=private)

        function maxLevels=getMaxLevels(~,denoisingMethod,wname,sigLength)
            if denoisingMethod=="BlockJS"
                numCoeffsByLevel=wavelet.internal.numcfsbylev(sigLength,wname);
                maxLevels=find(numCoeffsByLevel>=floor(log(sigLength)),1,'last');
            else
                maxLevels=floor(log2(sigLength));
            end
        end
    end
end