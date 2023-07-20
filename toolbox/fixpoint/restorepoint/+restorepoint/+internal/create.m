function output=create(model,varargin)


















    parser=restorepoint.internal.create.createParser;
    parse(parser,varargin{:});
    inputs=parser.Results;
    creator=initializeCreator(inputs,model);
    output=creator.run;
end

function creator=initializeCreator(inputs,model)



    createConfiguration=restorepoint.internal.create.CreateConfigurationForRestorePoint;

    createConfiguration.CreateDataStrategy.setModelName(model);

    if~inputs.forcesave

        createConfiguration.FileDependencyStrategy=restorepoint.internal.create.FileDependencyStandard;
    end

    creator=restorepoint.internal.Creator(createConfiguration);

    creator.ContinueRunOnMissingFiles=inputs.createonmissingfiles;
end


