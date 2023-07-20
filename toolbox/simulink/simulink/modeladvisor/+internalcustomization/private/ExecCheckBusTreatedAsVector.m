
function[ResultDescription]=ExecCheckBusTreatedAsVector(system)









    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);


    model=bdroot(system);
    [bResultStatus,ResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_BusTreatedAsVector(system,model);


    if bResultStatus
        mdladvObj.setCheckResultStatus(true);
    end
end
