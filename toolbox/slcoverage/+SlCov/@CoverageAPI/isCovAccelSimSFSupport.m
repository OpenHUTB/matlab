function res=isCovAccelSimSFSupport(modelName)



    res=false;
    if~sf('Feature','Accel Coverage')
        return;
    end
    coveng=cvi.TopModelCov.getInstance(modelName);
    if~isempty(coveng)
        res=strcmpi(get_param(coveng.topModelH,'CovAccelSimSupport'),'on');
    end
end
