function out=runSimulationInputParameterSpace(modelHandle,designStudy)
    simInName=designStudy.ParameterSpace.VarName;
    simIn=evalin('base',simInName);

    runOptions=simulink.multisim.internal.runner.getRunOptions(designStudy);
    if designStudy.RunOptions.UseParallel
        out=parsim(simIn,runOptions{:});
    else
        out=sim(simIn,runOptions{:});
    end
end