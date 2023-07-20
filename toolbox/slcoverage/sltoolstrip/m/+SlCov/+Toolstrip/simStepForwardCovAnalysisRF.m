function schema=simStepForwardCovAnalysisRF(cbinfo)




    schema=SLStudio.ToolBars('SimulationForwardToolBar',cbinfo);


    try
        covEnabled=strcmp(get_param(cbinfo.model.name,'CovEnable'),'on');
    catch Mex %#ok<NASGU> 
        covEnabled=false;
    end

    if~covEnabled
        schema.state='Disabled';
    end
end
