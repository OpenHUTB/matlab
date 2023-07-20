

classdef Detrender<signal.analyzer.controllers.Preprocessing.PreprocessorActionBase


    properties(Hidden)
        Method;

        Breakpoints;
        BreakpointsTimeUnits;
        TimeMode;
    end

    methods(Hidden)

        function this=Detrender(settings)

            this.Engine=Simulink.sdi.Instance.engine;

            this.Method=settings.method;

            this.Breakpoints=settings.breakpoints;
            this.BreakpointsTimeUnits=settings.breakpointsTimeUnits;
            this.TimeMode=settings.timeMode;
        end


        function[successFlag,data,exceptionKeyword,currentParameters]=processData(this,sigID,cleanUpHandle,currentParameters)




            this.NeedCleanUp=true;
            finishup=onCleanup(@()cleanUpHandle());

            exceptionKeyword='';
            data=this.getSignalValues(sigID);
            inputs={};
            inputs{end+1}=data.Data;

            if~isempty(this.Method)
                if strcmp(this.Method,'piecewiselinear')
                    inputs{end+1}='linear';


                    if~isempty(this.Breakpoints)
                        if strcmp(this.TimeMode,'samples')


                            inputs{end+1}=this.Breakpoints+1;
                        else

                            [~,formattedBreakpoints]=min(abs(data.Time-this.Breakpoints(:)'));

                            currentParameters.formattedBreakpoints=formattedBreakpoints(:);
                            inputs{end+1}=formattedBreakpoints(:);
                        end
                    end

                else
                    inputs{end+1}=this.Method;
                end
            end


            try
                lastwarn('');
                if strcmp(this.Method,'polynomial')

                else
                    data.Data=detrend(inputs{:});
                end
                successFlag=true;


                this.NeedCleanUp=false;
            catch e %#ok<NASGU>
                successFlag=false;
            end

        end
    end
end

