

classdef Smoother<signal.analyzer.controllers.Preprocessing.PreprocessorActionBase


    properties(Hidden)
        Method;
        WindowSpecType;
        WindowSmoothFactor;
        WindowLengthSamples;
        WindowLengthTime;
        SGDegree;
        TimeMode;
    end

    methods(Hidden)

        function this=Smoother(settings)


            this.Method=settings.method;
            this.WindowSpecType=settings.windowSpecType;
            this.WindowSmoothFactor=settings.windowSmoothFactor;
            this.WindowLengthSamples=settings.windowLengthSamples;
            this.WindowLengthTime=settings.windowLengthTime;
            this.SGDegree=settings.sgDegree;
            this.TimeMode=settings.timeMode;
        end


        function[successFlag,data,exceptionKeyword,currentParameters]=processData(this,sigID,cleanUpHandle,currentParameters)




            this.NeedCleanUp=true;
            finishup=onCleanup(@()cleanUpHandle());

            w=warning('off','MATLAB:smoothdata:degreeAutoClash');
            restoreWarn=onCleanup(@()warning(w));
            exceptionKeyword='';
            data=this.getSignalValues(sigID);

            isTimeSignal=any(strcmp(this.TimeMode,{'uniform','nonuniform','timemixed'}));
            inputs={};
            pvPairs={};

            inputs{end+1}=data.Data;
            inputs{end+1}=this.Method;

            if strcmp(this.Method,'sgolay')&&~isempty(this.SGDegree)&&~ischar(this.SGDegree)
                pvPairs{end+1}='Degree';
                pvPairs{end+1}=this.SGDegree;
            end

            if isTimeSignal
                pvPairs{end+1}='SamplePoints';
                pvPairs{end+1}=data.Time;
                winLength=this.WindowLengthTime;
            else
                winLength=this.WindowLengthSamples;
            end

            switch this.WindowSpecType
            case 'smoothingfactor'
                pvPairs{end+1}='SmoothingFactor';
                pvPairs{end+1}=this.WindowSmoothFactor;
            case 'duration'
                if~ischar(winLength)
                    inputs{end+1}=winLength;
                end
            end

            try
                lastwarn('');
                data.Data=smoothdata(inputs{:},pvPairs{:});
                successFlag=true;
                [~,warnId]=lastwarn();
                if strcmp(warnId,'MATLAB:smoothdata:degreeAutoClash')
                    exceptionKeyword='sgDegreeWarning';
                end
            catch e %#ok<NASGU>
                successFlag=false;
                exceptionKeyword='sgDegreeError';
            end


            this.NeedCleanUp=false;
        end
    end
end

