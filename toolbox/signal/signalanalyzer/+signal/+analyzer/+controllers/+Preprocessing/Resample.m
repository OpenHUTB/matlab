

classdef Resample<signal.analyzer.controllers.Preprocessing.PreprocessorActionBase


    properties(Hidden)
        InterPolationMethod;
        SampleRateType;
        SampleRate;
        SampleFactor;
        CriticalFrequency;
        TimeMode;
    end

    methods(Hidden)

        function this=Resample(settings)


            this.InterPolationMethod=settings.interpolationMethod;
            this.SampleRate=settings.sampleRate;
            this.SampleFactor=settings.sampleFactor;
            this.SampleRateType=settings.sampleRateType;
            this.CriticalFrequency=settings.criticalFrequency;
            this.TimeMode=settings.timeMode;
        end


        function[successFlag,data,exceptionKeyword,currentParameters]=processData(this,sigID,cleanUpHandle,currentParameters)




            this.NeedCleanUp=true;
            finishup=onCleanup(@()cleanUpHandle());

            exceptionKeyword='';
            data=[];

            if this.Engine.getSignalTmResampledSigID(sigID)==-1&&...
                strcmp(this.SampleRate,'Auto')&&...
                strcmp(this.SampleRateType,'specifysamplerate')

                successFlag=false;
                exceptionKeyword='UnchangedUniformSignal';


                this.NeedCleanUp=false;
                return;
            end

            inputs={};


            dataTs=this.getSignalValues(sigID);
            data.Data=dataTs.Data;
            data.Time=dataTs.Time;
            inputs{end+1}=data.Data;
            inputs{end+1}=data.Time;

            signalSampleRate=signal.sigappsshared.Utilities.getEffectiveSampleRate(sigID);
            if strcmp(this.SampleRateType,'specifysamplerate')
                if strcmp(this.SampleRate,'Auto')


                    targetSampleRate=signalSampleRate;
                else
                    targetSampleRate=this.SampleRate;
                end
            else


                targetSampleRate=signalSampleRate*this.SampleFactor;
            end
            inputs{end+1}=targetSampleRate;
            currentParameters.targetSampleRate=targetSampleRate;




            if(targetSampleRate/signalSampleRate)>10e3


                successFlag=false;
                data.Data=[];
                data.Time=[];
                exceptionKeyword='SignalLengthViolation';


                this.NeedCleanUp=false;
                return;
            end
            if strcmp(this.TimeMode,'nonuniform')&&...
                ~strcmp(this.CriticalFrequency,'Auto')


                [p,q]=rat(targetSampleRate/this.CriticalFrequency,0.01);
                inputs{end+1}=p;
                inputs{end+1}=q;

                if p*q>intmax('int32')


                    successFlag=false;
                    data.Data=[];
                    data.Time=[];
                    exceptionKeyword='CriticalFrequencyViolation';


                    this.NeedCleanUp=false;
                    return;
                end
            end

            if strcmp(this.TimeMode,'nonuniform')
                inputs{end+1}=this.InterPolationMethod;
            end
            [data.Data,data.Time]=resample(inputs{:});
            if length(data.Data)<2

                successFlag=false;
                data.Data=[];
                data.Time=[];
                exceptionKeyword='InvalidResampledSignal';


                this.NeedCleanUp=false;
                return;
            end
            successFlag=true;


            this.NeedCleanUp=false;
        end




        function flag=isPreprocessorOnlySupportsSuperParents(~)
            flag=true;
        end


        function flag=isPreprocessorCanModifyTime(~)
            flag=true;
        end

    end
end

