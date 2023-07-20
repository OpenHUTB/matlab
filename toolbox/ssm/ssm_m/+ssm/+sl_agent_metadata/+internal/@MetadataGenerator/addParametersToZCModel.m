function addParametersToZCModel(zcModel,params)







    rootArch=zcModel.Architecture;
    zcParamNames=rootArch.getParameterNames();


    for idx=1:length(params)
        param=params{idx};
        if~any(strcmp(zcParamNames,param.Name))
            rootArch.addParameter(param.Name,'Dimensions',mat2str(size(param.Value)));
        end
        rootArch.setParameterValue(param.Name,mat2str(param.Value));
    end

end


