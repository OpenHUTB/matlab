

function[ownerType,ownerFullPath]=initHarnessCovSettingsHelper(modelName,harnessName)
    ownerType=[];
    ownerFullPath=[];
    if~isempty(harnessName)
        if~bdIsLoaded(modelName)
            load_system(modelName);
            oc1=onCleanup(@()close_system(modelName,0));
        end
        harnessList=sltest.harness.find(modelName,'Name',harnessName);
        assert(length(harnessList)==1);
        ownerType=harnessList.ownerType;
        ownerFullPath=harnessList.ownerFullPath;

        if strcmpi(ownerType,'Simulink.BlockDiagram')&&...
            (~isempty(which('bdIsSubsystem'))&&bdIsSubsystem(modelName))

            ownerType='Simulink.SubSystem';
        end
    end
end