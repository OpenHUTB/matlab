


function highlightSignalInModel(hMdl,blockPath,portNum)
    model=get_param(hMdl,'name');
    blockHandle=get_param([model,'/',blockPath],'handle');
    utils.highlightSignalInModel(model,blockHandle,portNum);
end
