classdef Scalogram<handle




    properties(Hidden)
        ScalogramEngine;
        InputData;
    end

    properties(Constant)
        ControllerID='Scalogram';
    end

    methods(Static)

        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)

                ctrlObj=signal.analyzer.controllers.Scalogram();
            end

            ret=ctrlObj;
        end

        function y=setup(t1,t2,f1,f2,signalLength,fs,waveletType,...
            voicePerOctave,bandwidth)
            crtlObj=signal.analyzer.controllers.Scalogram.getController();
            y=crtlObj.setupScalogram(t1,t2,f1,f2,signalLength,fs,...
            waveletType,voicePerOctave,bandwidth);
        end
        function addInputData(data)
            crtlObj=signal.analyzer.controllers.Scalogram.getController();
            crtlObj.addSignalData(data);
        end

        function y=getComputedData()
            crtlObj=signal.analyzer.controllers.Scalogram.getController();
            y=crtlObj.getScalogramData();
        end

        function y=getMinFreq()
            crtlObj=signal.analyzer.controllers.Scalogram.getController();
            y=crtlObj.getScalogramMinFreq();
        end


        function y=haveWaveletToolBox()
            y=~isempty(ver('wavelet'))&&license('test','Wavelet_Toolbox');
        end
    end

    methods(Hidden,Access=private)

        function this=Scalogram()



            import signal.analyzer.controllers.Scalogram;
        end
    end

    methods

        function y=setupScalogram(this,~,~,f1,f2,signalLength,fs,...
            waveletType,voicePerOctave,timeBandwidth)

            this.ScalogramEngine=cwtfilterbank('SignalLength',signalLength,...
            'Wavelet',waveletType,...
            'VoicesPerOctave',voicePerOctave,...
            'TimeBandwidth',timeBandwidth,...
            'SamplingFrequency',fs,...
            'FrequencyLimits',[f1,f2]);
            y=true;
        end


        function addSignalData(this,data)

            this.InputData=data;
        end

        function y=getScalogramData(this)
            diff=this.ScalogramEngine.SignalLength-numel(this.InputData);
            if(diff~=0)
                signalData=[this.InputData(:);zeros(diff,1)];
                scalogramData=abs(this.ScalogramEngine.wt(signalData));
                y=flipud(scalogramData(:,1:numel(this.InputData)));
                y=y(:);
            else
                scalogramData=abs(this.ScalogramEngine.wt(this.InputData));
                y=flipud(scalogramData);
                y=y(:);
            end
        end

        function y=getScalogramMinFreq(this)
            y=min(centerFrequencies(this.ScalogramEngine));
        end
    end
end

