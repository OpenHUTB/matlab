function modelUnderTest=resolveModelUnderTest(model)






    coveng=cvi.TopModelCov.getInstance(model);
    if~isempty(coveng)
        modelUnderTest=get_param(coveng.modelUnderTest,'name');
    else
        modelUnderTest=model;
    end
end