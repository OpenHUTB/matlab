function applySystemUnderTestSettings(obj,simWatcher)



    if(isfield(obj.testSettings.sut,'set_params'))
        for k=1:length(obj.testSettings.sut.set_params)
            paramName=obj.testSettings.sut.set_params{k}{1};
            value=obj.testSettings.sut.set_params{k}{2};

            currValue=get_param(obj.modelToRun,paramName);
            set_param(obj.modelToRun,paramName,value);
            simWatcher.cleanupTestCase.(paramName)=currValue;
        end
    end
end