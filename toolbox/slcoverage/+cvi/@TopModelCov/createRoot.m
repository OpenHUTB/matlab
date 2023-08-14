




function newRootId=createRoot(modelcovId,rootSlHandle)

    covPath=cvi.TopModelCov.makeCovPath(rootSlHandle);
    newRootId=cv('new','root',...
    '.topSlHandle',rootSlHandle,...
    '.modelDepth',cvi.TopModelCov.getBlockDepth(rootSlHandle),...
    '.modelcov',modelcovId);
    cv('SetRootPath',newRootId,covPath);
    cv('set',modelcovId,'.activeRoot',newRootId);
