

function loadModelAdvisor(obj,modelName)
    system=get_param(modelName,'handle');
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(...
    system,'new','_SYSTEM_By Product_Simulink Code Inspector');

    try

        conf=slci.toolstrip.util.getConfiguration(obj.getStudio);
    catch
        conf=[];
    end

    if conf.getFollowModelLinks()


        treatAsMdlref=~strcmpi(modelName,conf.getModelName());
    else
        treatAsMdlref=~conf.getTopModel();
    end

    mdladvObj.treatAsMdlref=treatAsMdlref;
    groupObj=mdladvObj.TaskAdvisorRoot;
    groupObj.changeSelectionStatus(true)
    mdladvObj.displayExplorer;

end
