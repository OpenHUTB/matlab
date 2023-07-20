






function setupSlicer(obj,varUsage,includeIndirect)

    import slslicer.internal.ParameterDependenceInfo.*;
    if~exist('includeIndirect','var')
        includeIndirect=true;
    end
    progressBar=Sldv.Utils.ScopedProgressIndicator('Sldv:DebugUsingSlicer:PISetupSlicerParameterDebug');
    cleanupObj=onCleanup(@()delete(progressBar));
    parameterTag=getParamMapKey(varUsage);
    obj.currParamName=parameterTag;


    if~get_param(obj.model,'ModelSlicerActive')
        obj.backUpModelParameters;
    end


    obj.stopCurrentSim();

    progressBar.updateTitle('Sldv:DebugUsingSlicer:PIFindingStartingPoints');

    paramUsers=obj.getStartingPointsForParam(varUsage,includeIndirect);
    blockSIDs=Simulink.ID.getSID(paramUsers);

    progressBar.updateTitle('Sldv:DebugUsingSlicer:PIConfigureSlicer');
    try

        dlgSrc=obj.setupSlicerDialog;
    catch Mex
        rethrow(Mex);
    end

    if isempty(dlgSrc)
        return;
    end

    slicerConfig=dlgSrc.Model;



    obj.setupSlicerCriteria();

    progressBar.updateTitle('Sldv:DebugUsingSlicer:PIAddingStartingPoints');

    sigList=dlgSrc.sigListPanel;
    for idx=1:length(blockSIDs)
        startingPointH=getSimulinkBlockHandle(getfullname(blockSIDs{idx}));
        sigList.Model.addStart(startingPointH);
    end

    sigList.Model.direction='Forward';


    sigList.Model.refresh();


    notify(obj,'eventSetupComplete');


    obj.switchToSimulationTab();


    obj.setIsDebugSessionActive(true);
end
