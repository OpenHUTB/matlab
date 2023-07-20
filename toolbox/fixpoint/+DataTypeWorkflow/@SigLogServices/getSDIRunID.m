function runID=getSDIRunID(model,runName,simOut)







    oldValue=warning('query','SDI:sdi:notValidBaseWorkspaceVar');
    warning('off','SDI:sdi:notValidBaseWorkspaceVar');
    runID=Simulink.sdi.createRunOrAddToStreamedRun(model,runName,{'simOut'},{simOut});
    warning(oldValue.state,'SDI:sdi:notValidBaseWorkspaceVar');

end