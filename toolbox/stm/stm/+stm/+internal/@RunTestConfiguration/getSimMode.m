function[simMode,blockOrModelName,isModeAppliedOnCUT,simModeForCUT]=...
    getSimMode(this,simInputs,simWatcher)



    isModeAppliedOnCUT=false;
    simModeForCUT='';
    simMode=this.resolveSimulationMode(simInputs.Mode);
    blockOrModelName=this.modelToRun;

    if simMode~=""


        if~isempty(simWatcher.componentUnderTest)
            blockOrModelName=simWatcher.componentUnderTest;
            isModeAppliedOnCUT=true;
            simModeForCUT=simMode;
        elseif simWatcher.NeedSubsystemManager
            isModeAppliedOnCUT=true;
            simModeForCUT=simMode;
        end
        simWatcher.cleanupTestCase.SimulationMode=get_param(blockOrModelName,'SimulationMode');
        simWatcher.cleanupTestCase.SimulationModeAppliedOn=blockOrModelName;
    end


    simModeIdx={this.SimulationInput.ModelParameters.Name}=="SimulationMode";
    if any(simModeIdx)
        simModeUsed=this.SimulationInput.ModelParameters(simModeIdx).Value;
        simMode=simModeUsed;
    else
        simModeUsed=get_param(blockOrModelName,'SimulationMode');
    end

    this.out.SimulationModeUsed=simModeUsed;
    simWatcher.simMode=simModeUsed;


    if simMode==""&&strcmpi(this.out.SimulationModeUsed,'external')
        error(message('stm:general:ExtModeNotSupported'));
    end
end
