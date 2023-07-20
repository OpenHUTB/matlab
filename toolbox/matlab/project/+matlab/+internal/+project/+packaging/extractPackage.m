function[projectRoot,referencedProjects]=extractPackage(package,extractRoot,metadataRoot)




    projMetadataName='projectProperties.xml';
    metadataPath=char(metadataRoot.getAbsolutePath);
    extractPath=char(extractRoot.getAbsolutePath);

    import matlab.internal.project.packaging.PackageReader;

    reader=PackageReader(char(package.getAbsolutePath));
    refProjects=reader.ReferencedProjects;
    mainSub=reader.MainProjectSubfolder;

    dir=metadataPath;
    projectRoot=extractPath;
    if~isempty(mainSub)
        dir=fullfile(metadataPath,mainSub);
        projectRoot=fullfile(extractPath,mainSub);
        mkdir(dir);
    end
    reader.extract('ProjectProperties',fullfile(dir,projMetadataName));

    for i=1:length(refProjects)
        project=char(refProjects{i});
        dir=fullfile(metadataPath,project);
        mkdir(dir);
        reader.extractReferencedProjectProperties(project,fullfile(dir,projMetadataName));
    end

    reader.extract('Package',extractPath);

    referencedProjects=[{mainSub};refProjects];

end
