function names=loggingVariablesInBaseForBlock(blockName)






    names={};
    variablesInBase=evalin('base','whos');


    loggingVariablesIndex=strcmp({variablesInBase.class},...
    'simscape.logging.Node');
    loggingVariables=variablesInBase(loggingVariablesIndex);

    for idx=1:numel(loggingVariables)
        loggingVariableName=loggingVariables(idx).name;
        loggingVariable=evalin('base',loggingVariableName);
        isValid=simscape.logging.findPath(loggingVariable,blockName);
        if isValid
            names{end+1}=loggingVariableName;%#ok<AGROW>
        end
    end


    simulationOutputIndex=strcmp({variablesInBase.class},...
    'Simulink.SimulationOutput');
    simOutVariables=variablesInBase(simulationOutputIndex);
    for idx=1:numel(simOutVariables)
        simout=evalin('base',simOutVariables(idx).name);
        simOutNames=who(simout);
        for jdx=1:numel(simOutNames)
            out=get(simout,simOutNames{jdx});
            if isa(out,'simscape.logging.Node')
                isValid=simscape.logging.findPath(out,blockName);
                if isValid
                    names{end+1}=[simOutVariables(idx).name,'.',...
                    simOutNames{jdx}];%#ok<AGROW>
                end
            end
        end
    end

end
