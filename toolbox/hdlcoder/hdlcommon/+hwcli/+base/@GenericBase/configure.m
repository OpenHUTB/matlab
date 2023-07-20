function configure(obj,hDI)





    configure@hwcli.base.WorkflowBase(obj,hDI);

    if(obj.RunTaskRunImplementation||obj.RunTaskPerformPlaceAndRoute)
        hDI.SkipPlaceAndRoute=false;
        hDI.IgnorePlaceAndRouteErrors=obj.IgnorePlaceAndRouteErrors;
    else
        hDI.SkipPlaceAndRoute=true;
    end

    if(obj.RunTaskPerformMapping||obj.RunTaskRunSynthesis)
        hDI.SkipPreRouteTimingAnalysis=obj.SkipPreRouteTimingAnalysis;
        hDI.IgnorePlaceAndRouteErrors=obj.IgnorePlaceAndRouteErrors;
    end
