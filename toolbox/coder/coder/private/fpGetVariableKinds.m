function types=fpGetVariableKinds(entryPointFile)



    info=coder.internal.tools.MLFcnInfo(entryPointFile);
    keys=info.keys;

    for i=1:numel(keys)
        types(i).function=keys{i};%#ok<*AGROW>
        types(i).inputVars=info(keys{i}).inputVars;
        types(i).outputVars=info(keys{i}).outputVars;
        types(i).persistentVars=info(keys{i}).persistentVars;
        types(i).indexVars=info(keys{i}).loopIdxVars;
        types(i).tempVars=info(keys{i}).tempVars;
        types(i).globalVars=info(keys{i}).globalVars;
    end
end