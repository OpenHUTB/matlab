function setModelExclusionFile(mdlName,exList)





























    set_param(bdroot(mdlName),'MAModelExclusionFile','');
    exEditor=ModelAdvisor.ExclusionEditor.getInstance(bdroot(mdlName));
    if~exEditor.isSLX
        DAStudio.error('ModelAdvisor:engine:ExclusionPartMDLFile');
    end
    exEditor.writeToFile(exList);