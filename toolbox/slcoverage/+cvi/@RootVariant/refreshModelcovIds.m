function refreshModelcovIds(slsfId,modelcovId)




    cv('slsfobjChangeModelcov',slsfId,modelcovId);
    [status,msg]=cvi.TopModelCov.updateModelHandles(modelcovId,SlCov.CoverageAPI.getModelcovName(modelcovId));
    if status==0
        warning(message('Slvnv:simcoverage:cvload:DataConsistencyProblem',modName,'',fullFileName,'',msg{1}));
    end
end
