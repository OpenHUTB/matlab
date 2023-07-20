function mlfb=isMLFB(blkPath)



    mlfb=isa(getChart(blkPath),'Stateflow.EMChart');
end

function chart=getChart(blkPath)
    chartId=sfprivate('block2chart',blkPath);
    chart=idToHandle(sfroot,chartId);
end

