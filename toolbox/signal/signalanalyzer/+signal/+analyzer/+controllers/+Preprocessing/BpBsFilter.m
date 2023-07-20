

classdef BpBsFilter<signal.analyzer.controllers.Preprocessing.PreprocessorActionBase


    properties(Hidden)
        PassbandFrequencyNormalized1;
        PassbandFrequencyNormalized2;
        PassbandFrequency1;
        PassbandFrequency2;
        SteepnessMode;
        Steepness1;
        Steepness2;
        StopbandAttenuation;
        TimeMode;
        ActionName;
    end

    methods(Hidden)

        function this=BpBsFilter(settings)


            this.PassbandFrequencyNormalized1=settings.passbandFrequencyNormalized1;
            this.PassbandFrequencyNormalized2=settings.passbandFrequencyNormalized2;
            this.PassbandFrequency1=settings.passbandFrequency1;
            this.PassbandFrequency2=settings.passbandFrequency2;
            this.SteepnessMode=settings.steepnessMode;
            this.Steepness1=settings.steepness1;
            this.Steepness2=settings.steepness2;
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
                exceptionKeyword='NonUniformSignalError';
                successFlag=false;


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
                inputs{end+1}=[this.PassbandFrequency1,this.PassbandFrequency2];
                inputs{end+1}=Fs;
            else
                inputs{end+1}=[this.PassbandFrequencyNormalized1,this.PassbandFrequencyNormalized2];
            end

            pvPairs{end+1}='Steepness';
            if strcmp(this.SteepnessMode,'single')
                pvPairs{end+1}=this.Steepness1;
            else
                pvPairs{end+1}=[this.Steepness1,this.Steepness2];
            end

            pvPairs{end+1}='StopbandAttenuation';
            pvPairs{end+1}=this.StopbandAttenuation;

            lastwarn('');
            switch(this.ActionName)
            case 'bandpassfilter'
                data.Data=bandpass(inputs{:},pvPairs{:});
            case 'bandstopfilter'
                data.Data=bandstop(inputs{:},pvPairs{:});
            otherwise
                error(message('signal:internal:filteringfcns:InvalidAct4BpBsFilterClass'))
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

