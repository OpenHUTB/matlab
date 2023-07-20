function results=FixSubModels(aObj)





    results=[];
    refMdls=aObj.getRefMdls();
    for i=1:numel(refMdls)
        mdl=refMdls{i};
        configuration=aObj.createConfigurationForSubModel(mdl);
        result=configuration.fixIncompatibilities();
        results=[results,result];%#ok
    end
end

