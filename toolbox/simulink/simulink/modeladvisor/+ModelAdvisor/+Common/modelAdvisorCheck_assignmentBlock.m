










function[bResultStatus,ResultDescription]=...
    modelAdvisorCheck_assignmentBlock(system,PREFIX,enabled)
    checkObject=ModelAdvisor.Common.CodingStandards.AssignmentBlocks(...
    system,[PREFIX,'Hisl0029_'],enabled);
    checkObject.algorithm();
    checkObject.report();
    bResultStatus=checkObject.getLocalResultStatus();
    ResultDescription=checkObject.getReportObjects();
end

