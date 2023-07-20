function[modelInfos,blockInfos]=getDiffInfos(source,target,options)








































    simbio.comparisons.internal.mustBeSbprojFileOrModelObject(source);
    simbio.comparisons.internal.mustBeSbprojFileOrModelObject(target);


    sbRoot=sbioroot();
    numModelsOnRoot=numel(sbRoot.Models);
    cleanupRoot=SimBiology.internal.Cleanup(@()delete(sbRoot.Models(numModelsOnRoot+1:end)));


    tmpDirectory=tempname(sbiogate('sbiotempdir'));
    cleanupObj=onCleanup(@()cleanupTempDir(tmpDirectory));


    [projectFileNames,models,diagramFiles,projectContents]=simbio.comparisons.internal.getModelInfo({source,target},options,tmpDirectory);


    blockInfos=simbio.comparisons.internal.loadBlockInfos(models,diagramFiles,options.IgnoreDiagram);


    modelInfos=cell(1,2);
    for i=1:2
        if projectFileNames(i)~=""
            assert(~isempty(projectContents{i}));


            allModels=projectContents{i}.ModelNames;
            FileInfo=dir(projectFileNames(i));
            lastModified=string(FileInfo.date);
        else
            assert(isempty(projectContents{i}));



            allModels=models(i).Name;
            lastModified="";
        end
        modelInfos{i}=struct("Project",string(projectFileNames(i)),...
        "ModelName",string(models(i).Name),...
        "Model",models(i),...
        "LastModified",lastModified,...
        "AllModelNames",{cellstr(allModels)},...
        "GitInfos",struct("name",{},"value",{}));
    end

    cleanupRoot.Task=[];
end


function cleanupTempDir(tmpDirectory)

    if exist(tmpDirectory,'dir')
        rmdir(tmpDirectory,'s');
    end
end
