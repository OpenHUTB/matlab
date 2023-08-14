function results=inspect(aObj,varargin)





















































































    aObj.ValidateProperties();


    aObj.parseInputsForInspect(varargin{:});

    try

        if(~builtin('license','checkout','Simulink_Code_Inspector'))
            DAStudio.error('Slci:slci:ERROR_LICENSE');
        end


        aObj.createInspectProgressBar();


        pCallInspect=slci.internal.Profiler('SLCI','CallInspect',...
        aObj.getModelName(),'');

        inspectResults=aObj.callInspect();


        pCallInspect.stop();


        if~aObj.getDisableReport()

            pReport=slci.internal.Profiler('SLCI','CallReport',...
            aObj.getModelName(),...
            '');

            reportResults=aObj.callReport();

            pReport.stop();
        end


        aObj.deleteInspectProgressBar()

        if aObj.getReturnReportResults()
            results=reportResults;
        else
            results=inspectResults;
        end

    catch ME


        aObj.deleteInspectProgressBar()

        aObj.HandleException(ME);



        if strcmp(ME.identifier,'Slci:slci:ERRORS_DIRTYMODEL')

            results=aObj.returnResultsOnError(false);
            return;
        end

        if aObj.getReturnReportResults()

            results=aObj.returnResultsOnError(true);
        else

            results=aObj.CollateResults(true,1,{},false,false);
        end
    end


    aObj.getDataManager().discardData();

end


