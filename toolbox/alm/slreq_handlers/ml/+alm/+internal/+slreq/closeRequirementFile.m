function closeRequirementFile(absoluteReqFilePath)
    [~,name,ext]=fileparts(absoluteReqFilePath);
    slreq.utils.slproject.discardRequirementsFile([name,ext],fullfile(absoluteReqFilePath));
end
