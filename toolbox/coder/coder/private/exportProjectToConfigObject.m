




function exportProjectToConfigObject(project,variableName)
    config=project.getConfiguration();
    artifact=char(config.getParamAsString('param.artifact'));
    shortArtifact=artifact(24:end);
    if strcmp(shortArtifact,'mex.instrumented')
        shortArtifact='mex';
    end
    switch lower(shortArtifact)
    case{'dll','lib','exe'}
        ecoder=config.getParamAsBoolean('param.UseECoderFeatures');
        c=coder.config(shortArtifact,'ecoder',ecoder);
    otherwise
        c=coder.config(shortArtifact);
    end
    copyProjectToConfigObject(project,c);
    assignin('base',variableName,c);
end
