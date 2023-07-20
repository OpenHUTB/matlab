

function hierarchicalPathArr=getHierarchicalPathUsingBindModeSource(localBlockPath)






    bMObj=BindMode.BindMode.getInstance();
    bMSourceDataObj=bMObj.bindModeSourceDataObj;
    assert(bMSourceDataObj.isGraphical);
    hierarchicalPathArr=bMSourceDataObj.hierarchicalPathArray;

    hierarchicalPathArr{end}=localBlockPath;
    pipePath=Simulink.BlockPath(hierarchicalPathArr).toPipePath();
    hierarchicalPathArr=[{pipePath},hierarchicalPathArr];
end