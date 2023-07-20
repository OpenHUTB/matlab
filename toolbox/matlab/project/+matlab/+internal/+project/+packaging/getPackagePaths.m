function[cellArray]=getPackagePaths(packageJavaFile,extractionRootJavaFile)





    import java.io.File;
    import matlab.internal.project.packaging.PackageReader;

    reader=PackageReader(char(packageJavaFile.getAbsolutePath));
    extractionPath=char(extractionRootJavaFile.getAbsolutePath);

    refProjects=reader.ReferencedProjects;
    mainSub=reader.MainProjectSubfolder;

    cellArray=cell(length(refProjects)+1,1);
    cellArray{1}=fullfile(extractionPath,mainSub);

    for i=1:length(refProjects)
        cellArray{i+1}=fullfile(extractionPath,char(refProjects{i}));
    end

end
