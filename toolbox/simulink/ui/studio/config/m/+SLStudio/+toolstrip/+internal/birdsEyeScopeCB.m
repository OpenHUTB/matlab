



function birdsEyeScopeCB(cbinfo)
    modelName=cbinfo.model.Name;


    set_param(0,'LastVisualizer','BirdsEyeScope');


    besScope=Simulink.scopes.BirdsEyeUtil.getBirdsEyeScope(modelName,true);
    besScope.IsNewDataAvailable=false;

    Simulink.scopes.BirdsEyeUtil.openBirdsEyeScope(modelName);
end
