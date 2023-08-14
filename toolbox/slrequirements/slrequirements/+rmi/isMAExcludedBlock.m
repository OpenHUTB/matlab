function out=isMAExcludedBlock(mdladvObj,blockH)




    if floor(blockH)==blockH
        if(sf('get',blockH,'.isa')==1)
            chart=blockH;
        else
            chart=sf('get',blockH,'.chart');
        end
        chartName=sf('get',chart,'.name');
        blockH=[mdladvObj.ModelName,'/',chartName];
    end
    out=isempty(mdladvObj.filterResultWithExclusion(blockH));
end
