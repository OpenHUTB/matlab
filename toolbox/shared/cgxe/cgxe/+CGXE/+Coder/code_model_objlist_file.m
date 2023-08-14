function[objectFileList,sourceFileList]=code_model_objlist_file(fileNameInfo,buildInfo)



    import CGXE.Coder.*;

    fileName=fullfile(fileNameInfo.targetDirName,fileNameInfo.objListFile);

    file=fopen(fileName,'Wt');
    if file<0
        throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
    end

    sourceFileList=buildInfo.getSourceFiles(true,true);
    objectFileList=cell(1,numel(sourceFileList));

    for i=1:numel(sourceFileList)
        thisSourceFile=sourceFileList{i};
        [~,nameStr]=fileparts(thisSourceFile);
        thisObjFile=[nameStr,'.obj'];
        fprintf(file,'%s\n',thisObjFile);
        objectFileList{i}=thisObjFile;
    end

    fclose(file);
