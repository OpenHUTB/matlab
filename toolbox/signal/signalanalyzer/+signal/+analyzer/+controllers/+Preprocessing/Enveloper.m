

classdef Enveloper<signal.analyzer.controllers.Preprocessing.PreprocessorActionBase

    properties(Hidden)
OutputType
Method
FilterOrder
WindowLength
WindowLengthTimeUnits
MaximaSeparation
MaximaSeparationTimeUnits
        TimeMode;
    end

    methods(Hidden)

        function this=Enveloper(settings)

            this.Engine=Simulink.sdi.Instance.engine;

            this.OutputType=settings.outputType;
            this.Method=settings.method;
            this.FilterOrder=settings.filterOrder;
            this.WindowLength=settings.windowLength;
            this.WindowLengthTimeUnits=settings.windowLengthTimeUnits;
            this.MaximaSeparation=settings.maximaSeparation;
            this.MaximaSeparationTimeUnits=settings.maximaSeparationTimeUnits;
            this.TimeMode=settings.timeMode;
        end


        function[successFlag,data,exceptionKeyword,currentParameters]=processData(this,sigID,cleanUpHandle,currentParameters)




            this.NeedCleanUp=true;
            finishup=onCleanup(@()cleanUpHandle());

            exceptionKeyword='';
            data=this.Engine.getSignalDataValues(sigID);
            inputs={};

            inputs{end+1}=data.Data;
            if strcmp(this.Method,'fir')
                inputs{end+1}=this.FilterOrder;
                inputs{end+1}='analytic';

            elseif strcmp(this.Method,'rms')
                if strcmp(this.WindowLengthTimeUnits,'samples')
                    inputs{end+1}=this.WindowLength;
                else
                    Fs=signal.sigappsshared.Utilities.getEffectiveSampleRate(sigID);
                    formattedWindowLength=round(this.WindowLength*Fs);
                    inputs{end+1}=formattedWindowLength;
                    currentParameters.formattedWindowLength=formattedWindowLength;
                end
                inputs{end+1}=this.Method;

            elseif strcmp(this.Method,'peak')
                if strcmp(this.MaximaSeparationTimeUnits,'samples')
                    inputs{end+1}=this.MaximaSeparation;
                else
                    Fs=signal.sigappsshared.Utilities.getEffectiveSampleRate(sigID);
                    formattedMaximaSeparation=round(this.MaximaSeparation*Fs);
                    inputs{end+1}=formattedMaximaSeparation;
                    currentParameters.formattedMaximaSeparation=formattedMaximaSeparation;
                end
                inputs{end+1}=this.Method;

            end

            try
                if strcmp(this.OutputType,'upper')
                    [data.Data,~]=envelope(inputs{:});
                elseif strcmp(this.OutputType,'lower')
                    [~,data.Data]=envelope(inputs{:});
                end
                successFlag=true;


                this.NeedCleanUp=false;

            catch e %#ok<NASGU>
                successFlag=false;
            end

        end
    end
end

