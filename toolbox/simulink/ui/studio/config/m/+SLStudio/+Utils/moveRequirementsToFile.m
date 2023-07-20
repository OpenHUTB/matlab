



function moveRequirementsToFile(blockPath)
    blockHandle=get_param(blockPath,'Handle');
    modelH=bdroot(blockHandle);
    destinationPath=rmimap.StorageMapper.getInstance.promptForReqFile(modelH,false);
    if~isempty(destinationPath)
        rmidata.export(modelH);
    end
end