function applyOutputSettings(this)




    if this.SimIn.OutputCtrlEnabled
        model=this.RunTestCfg.modelToRun;
        params=["SaveOutput","SaveState","SaveFinalState","SignalLogging","DSMLogging"];
        set_params=arrayfun(@(param)applyParam(this.SimIn,param.char,model),...
        params,'UniformOutput',false);
        set_params=[set_params{:}];



        if~this.SimIn.SignalLogging&&~this.SimWatcher.fastRestart&&...
            this.SimIn.LoggedSignalSetId==0&&...
            isempty(this.SimIn.testIteration.TestParameter.LoggedSignalSetId)
            set_params=[set_params,'InstrumentedSignals',{[]}];
        end

        if(~isempty(set_params))

            this.RunTestCfg.SimulationInput=...
            this.RunTestCfg.SimulationInput.setModelParameter(set_params{:});
        end
    end
end

function set_params=applyParam(simIn,param,model)
    if simIn.(param)
        newValue='on';
    else
        newValue='off';
    end

    if strcmp(get_param(model,param),newValue)

        set_params={};
    else
        set_params={param,newValue};
    end
end
