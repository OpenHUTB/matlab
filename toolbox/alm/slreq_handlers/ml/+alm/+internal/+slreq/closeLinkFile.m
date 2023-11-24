function closeLinkFile(absoluteLinkFilePath)
    [~,name,ext]=fileparts(absoluteLinkFilePath);
    slreq.utils.slproject.discardRequirementsFile([name,ext],fullfile(absoluteLinkFilePath));

end
