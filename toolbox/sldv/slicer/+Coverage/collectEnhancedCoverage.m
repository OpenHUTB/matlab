function cvd=collectEnhancedCoverage(arg,tstop,varargin)




    if isempty(varargin)||isempty(varargin{1})
        simulationInput=[];
    elseif isa(varargin{1},'Simulink.SimulationInput')
        simulationInput=varargin{1};
    end

    createdSimHandler=false;
    if isa(arg,'Coverage.SimulationHandler')
        simHandler=arg;
    else
        mdl=get_param(arg,'Name');
        simHandler=ModelSlicer.getSimHandlerForSlicer(mdl);
        createdSimHandler=true;
    end
    [origAnimMap,sfMachines]=turnOffSfAnimation(simHandler.modelH);

    try
        cvd=simHandler.collectEnhancedCoverage(tstop,simulationInput);
    catch mex
        restoreState();
        rethrow(mex);
    end
    restoreState();

    function restoreState()
        restoreSfAnimation(origAnimMap,sfMachines);
        if createdSimHandler
            delete(simHandler);
        end
    end
end

function[origAnimMap,sfMachines]=turnOffSfAnimation(modelH)
    persistent has_sf_license;
    if isempty(has_sf_license)
        has_sf_license=license('test','Stateflow');
    end
    origAnimMap=containers.Map('KeyType','double','ValueType','double');
    allH=Transform.AtomicGroup.searchModelBlocks(modelH);
    sfMachines=cell(1,length(allH));
    if~has_sf_license
        return;
    end
    rt=sfroot;
    for k=1:length(allH)
        sm=rt.find('-isa','Stateflow.Machine',...
        'Name',get_param(allH(k),'Name'));
        sfMachines{k}=sm;
        if~isempty(sm)
            origAnimMap(sm.Id)=sm.Debug.Animation.Enabled;
            sm.Debug.Animation.Enabled=false;
        end
    end
end

function restoreSfAnimation(origAnimMap,sfMachines)
    for k=1:length(sfMachines)
        sm=sfMachines{k};
        if~isempty(sm)
            val=origAnimMap(sm.Id);
            sm.Debug.Animation.Enabled=val;
        end
    end
end
