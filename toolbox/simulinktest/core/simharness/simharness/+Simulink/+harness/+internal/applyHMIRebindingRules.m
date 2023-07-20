function applyHMIRebindingRules(modelHandle)

    webhmi=Simulink.HMI.WebHMI.getWebHMI(modelHandle);
    if~isempty(webhmi)
        modelName=get_param(modelHandle,'Name');



        if~strcmp(webhmi.Model,modelName)


            insts=get_param(modelHandle,'InstrumentedSignals');
            if~isempty(insts)
                new_insts=Simulink.HMI.InstrumentedSignals(modelName);
                for index=1:insts.Count
                    sigspec=insts.get(index);
                    sigspec.BlockPath.updateTopModelName(webhmi.Model,modelName);
                    new_insts.add(sigspec);
                end
                set_param(modelHandle,'InstrumentedSignals',new_insts);
            end
        else
            webhmi.applyRebindingRules();
        end
    end

end

