

classdef LpHpFilter<signal.analyzer.controllers.Preprocessing.PreprocessorActionBase


    properties(Hidden)
        PassbandFrequencyNormalized;
        PassbandFrequency;
        Steepness;
        StopbandAttenuation;
        TimeMode;
        ActionName;
    end

    methods(Hidden)

        function this=LpHpFilter(settings)


            this.PassbandFrequencyNormalized=settings.passbandFrequencyNormalized;
            this.PassbandFrequency=settings.passbandFrequency;
            this.Steepness=settings.steepness;
            this.StopbandAttenuation=settings.stopbandAttenuation;
            this.TimeMode=settings.timeMode;
            this.ActionName=settings.actionName;
        end


        function[successFlag,data,exceptionKeyword,currentParameters]=processData(this,sigID,cleanUpHandle,currentParameters)




            this.NeedCleanUp=true;
            finishup=onCleanup(@()cleanUpHandle());

            exceptionKeyword='';
            data=[];



            if this.Engine.getSignalTmResampledSigID(sigID)~=-1
                successFlag=false;
                exceptionKeyword='NonUniformSignalError';


                this.NeedCleanUp=false;
                return;
            end

            w=warning('off');
            restoreWarn=onCleanup(@()warning(w));

            data=this.getSignalValues(sigID);
            isTimeSignal=any(strcmp(this.TimeMode,{'uniform','nonuniform','timemixed'}));
            inputs={};
            pvPairs={};

            inputs{end+1}=data.Data;
            if isTimeSignal
                Fs=signal.sigappsshared.Utilities.getEffectiveSampleRate(sigID);
                inputs{end+1}=this.PassbandFrequency;
                inputs{end+1}=Fs;
            else
                inputs{end+1}=this.PassbandFrequencyNormalized;
            end

            pvPairs{end+1}='Steepness';
            pvPairs{end+1}=this.Steepness;
            pvPairs{end+1}='StopbandAttenuation';
            pvPairs{end+1}=this.StopbandAttenuation;

            lastwarn('');
            switch(this.ActionName)
            case 'lowpassfilter'
                data.Data=lowpass(inputs{:},pvPairs{:});
            case 'highpassfilter'
                data.Data=highpass(inputs{:},pvPairs{:});
            otherwise
                error(message('signal:internal:filteringfcns:InvalidAct4LpHpFilterClass'))
            end

            successFlag=true;
            [~,warnId]=lastwarn();
            if strcmp(warnId,'signal:internal:filteringfcns:ForcedAllpassDesign')
                exceptionKeyword='ForcedAllpassDesign';
            elseif strcmp(warnId,'signal:internal:filteringfcns:ForcedAllstopDesign')
                exceptionKeyword='ForcedAllstopDesign';
            end


            this.NeedCleanUp=false;
        end
    end
end

