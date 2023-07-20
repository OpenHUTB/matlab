function schema=playSimCovAnalysisRF(cbinfo)




    schema=SLStudio.ToolBars('StartPauseContinue',cbinfo);

    simState=cbinfo.model.SimulationStatus;
    if strcmpi(simState,'running')

    elseif(strcmpi(simState,'paused')||strcmpi(simState,'paused-in-debugger'))

    else

        schema.label='Slvnv:simcoverage:toolstrip:PlaySimCovAnalysisActionText';
        schema.tooltip='Slvnv:simcoverage:toolstrip:PlaySimCovAnalysisActionDescription';
        schema.icon='simPlayCustomCoverage';
    end

    try
        covEnabled=strcmp(get_param(cbinfo.model.name,'CovEnable'),'on');
    catch Mex %#ok<NASGU> 
        covEnabled=false;
    end


    if~covEnabled
        schema.state='Disabled';
        schema.tooltip='Slvnv:simcoverage:toolstrip:PlaySimCovAnalysisActionDisabledDescription';
    end
end
