

classdef UserDefinedPreprocessor<signal.analyzer.controllers.Preprocessing.PreprocessorActionBase


    properties(Hidden)
        Method;
        Arguments;
        TimeMode;
    end

    methods(Hidden)

        function this=UserDefinedPreprocessor(settings)


            this.Method=settings.method;
            this.Arguments=settings.arguments;
            this.TimeMode=settings.timeMode;
        end



        function[successFlag,data,exceptionKeyword,currentParameters]=processData(this,sigID,cleanUpHandle,currentParameters)




            this.NeedCleanUp=true;
            finishup=onCleanup(@()cleanUpHandle());

            w=warning('off');
            restoreWarn=onCleanup(@()warning(w));


            dataTs=this.getSignalValues(sigID);
            data.Data=dataTs.Data;
            data.Time=dataTs.Time;
            isTimeSignal=any(strcmp(this.TimeMode,{'uniform','nonuniform','timemixed'}));
            tIn=[];
            if isTimeSignal
                tIn=data.Time;
            end
            try
                lastwarn('');
                f=str2func(this.Method);
                if isempty(this.Arguments)
                    [dataOut,tOut]=f(data.Data,tIn);
                else
                    params=signal.sigappsshared.Utilities.parseCommaSeperateString(this.Arguments);
                    [dataOut,tOut]=f(data.Data,tIn,params{:});
                end
                [successFlag,exceptionKeyword,data]=this.checkAndSetupValidData(dataOut,tOut,isTimeSignal,data.Data);
            catch e

                successFlag=false;
                exceptionKeyword=e.message;
                if strcmp(e.identifier,'MATLAB:UndefinedFunction')

                    exceptionKeyword=[getString(message('SDI:sigAnalyzer:PreprocessUndefinedFunction')),' ',this.Method];
                end
            end


            this.NeedCleanUp=false;
        end

        function[successFlag,exceptionKeyword,data]=checkAndSetupValidData(~,dataOut,tOut,isTimeSignal,inputData)
            data.Data=[];
            data.Time=[];

            if isreal(inputData)~=isreal(dataOut)
                successFlag=false;
                exceptionKeyword='ComplexityChanged';
                return;
            end
            if allfinite(inputData)&&~allfinite(dataOut)
                successFlag=false;
                exceptionKeyword='FiniteChangedToNonFinite';
                return;
            end
            if~isTimeSignal

                if(~signal.sigappsshared.Utilities.isValidDataType(dataOut)||...
                    isempty(dataOut))
                    successFlag=false;
                    exceptionKeyword='InValidData';
                    return;
                end


                if~isempty(tOut)
                    successFlag=false;
                    exceptionKeyword='NonEmptyTimeForSample';
                    return;
                else


                    data.Time=(0:numel(dataOut)-1)';
                end
            else

                if(~signal.sigappsshared.Utilities.isValidDataType(dataOut)||...
                    isempty(dataOut))
                    successFlag=false;
                    exceptionKeyword='InValidData';
                    return;
                end


                if(~signal.sigappsshared.Utilities.isValidDataType(tOut)||...
                    ~isreal(tOut)||isempty(tOut))
                    successFlag=false;
                    exceptionKeyword='InValidTime';
                    return;
                end


                if(length(dataOut)~=length(tOut))
                    successFlag=false;
                    exceptionKeyword='MissMatchDataAndTime';
                    return;
                end

                if length(tOut)~=length(unique(tOut))||~issorted(tOut)
                    successFlag=false;
                    exceptionKeyword='TimeIsNotMonotonous';
                    return;
                end


                if(~signal.sigappsshared.Utilities.validateNonUniformTimeValues(tOut))
                    successFlag=false;
                    exceptionKeyword='TimeIsIrregular';
                    return;
                end



                data.Time=double(tOut(:));
            end



            data.Data=double(dataOut(:));
            successFlag=true;
            exceptionKeyword='';
        end




        function flag=isPreprocessorCanModifyTime(~)
            flag=true;
        end
    end
end

