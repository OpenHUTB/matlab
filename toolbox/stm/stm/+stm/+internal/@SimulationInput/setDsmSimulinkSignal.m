function setDsmSimulinkSignal(this,dsms)



    if isempty(dsms)
        return;
    end

    models=extractBefore({dsms.BlockPath},'/');
    dsms=copyFieldsNeededForVariableReader(dsms);

    readers=stm.internal.VariableReader.getReader(dsms,models);
    variables=arrayfun(@(reader)...
    Simulink.Simulation.Variable(reader.Param.Name,reader.getDsmOverrideValue,...
    'workspace',reader.getVariableWorkspace),readers);
    this.RunTestCfg.SimulationInput.Variables=[this.RunTestCfg.SimulationInput.Variables,variables];
end

function dsms=copyFieldsNeededForVariableReader(dsms)
    [dsms.SourceType]=dsms.SDIBlockPath;
    [dsms.Value]=dsms.Name;
    [dsms.IsDerived]=deal(false);
    [dsms.IsOverridingChar]=deal(false);
    [dsms.ModelReference]=deal('');
end
