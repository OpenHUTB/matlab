function applyOutputSettings(obj,simWatcher)



    if(obj.testSettings.output.outputCtrlEnabled&&isfield(obj.testSettings.output,'set_params'))
        for k=1:length(obj.testSettings.output.set_params)
            paramName=obj.testSettings.output.set_params{k}{1};
            value=obj.testSettings.output.set_params{k}{2};
            try
                currValue=get_param(obj.modelToRun,paramName);
                set_param(obj.modelToRun,paramName,value);
                if strcmp(paramName,'InstrumentedSignals')

                    instrumentedSignals=containers.Map;
                    instrumentedSignals(obj.modelToRun)=currValue;
                    simWatcher.cleanupTestCase.(paramName)=instrumentedSignals;
                else
                    simWatcher.cleanupTestCase.(paramName)=currValue;
                end
            catch
            end
        end
    end
end
