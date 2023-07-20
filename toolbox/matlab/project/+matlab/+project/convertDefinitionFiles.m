function convertDefinitionFiles(projectRoot,definitionType)












    import matlab.internal.project.util.FileToProjectMapper;
    import matlab.internal.project.util.processJavaCall;

    p=inputParser;
    p.addRequired('projectRoot',...
    @(x)validateattributes(x,{'char','string'},{'nonempty'},'','projectRoot'));
    p.addRequired('definitionType',...
    @(x)validateattributes(x,{'matlab.project.DefinitionFiles'},{'nonempty'},'','definitionType'));
    p.parse(projectRoot,definitionType);

    if isstring(projectRoot)
        projectRoot=char(projectRoot);
    end

    fileToProjectMapper=FileToProjectMapper([projectRoot,'/dummy']);
    if(~fileToProjectMapper.InAProject)
        error(message('MATLAB:project:api:NoProjectFound',projectRoot));
    end

    if(fileToProjectMapper.InRootOfALoadedProject)
        error(message('MATLAB:project:api:ProjectOpenError'));
    end

    factoryName=definitionType.getFactory();

    if matlab.internal.project.util.useWebFrontEnd
        matlab.internal.project.api.convertDefinitionFiles(projectRoot,factoryName);
    else
        jmetadataFactory=com.mathworks.toolbox.slproject.project.metadata.MetadataFactoryFinder.getNamedFactory(factoryName);
        jRoot=java.io.File(fileToProjectMapper.ProjectRoot);
        processJavaCall(@()com.mathworks.toolbox.slproject.project.metadata.util.MetadataConverter.convert(jRoot,jmetadataFactory));
    end
end
