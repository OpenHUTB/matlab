


function slhmi(cmd,varargin)
    try
        switch cmd
        case 'pre-cache'
            local_precache();
        case 'sim_start'
            local_simulationStart(varargin{:});
        case 'block_param_change'
            blk=varargin{1};
            local_updateParams(blk);
        otherwise
            assert(false);
        end
    catch me
        warning(me.identifier,me.message);
    end
end


function local_precache()



    eng=Simulink.sdi.Instance.engine;


    createPendingParsers(eng.WksParser);
    createPendingParsers(eng.FileImporter);
    createPendingExporters(eng.WksExporter);


    ts=timeseries(0,0);
    ts=repmat(ts,1,2);%#ok<NASGU> 
    sig=Simulink.SimulationData.Signal;%#ok<NASGU> 
    ds=Simulink.SimulationData.Dataset;%#ok<NASGU> 


    mgr=Simulink.HMI.InterfaceMgr.getInterfaceMgr();
    registerListeners(mgr);
end


function local_simulationStart(mdl,varargin)
    try
        mdlDesc=get_param(mdl,'Description');
        if strcmp(mdlDesc,'Temporary wrapper for PIL simulation')
            mdl=strrep(mdl,'_wrapper','');
        end
    catch ME %#ok<NASGU>
    end

    Simulink.HMI.ModelInterface.onModelStart(mdl,varargin{:});
end


function local_updateParams(blk)
    Simulink.HMI.ModelInterface.updateParams(blk);
end
