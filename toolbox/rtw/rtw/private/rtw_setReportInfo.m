function rtw_setReportInfo(generatedFileList,modelName,genUtilsPath)







    if isempty(generatedFileList)
        return;
    end
    h=coder.internal.ModelCodegenMgr.getInstance(modelName);
    if isempty(h)
        DAStudio.error('RTW:buildProcess:objHandleLoadError',modelName);
    end


    htmlDir=[h.BuildDirectory,filesep,'html'];
    if~exist(htmlDir,'dir');mkdir(h.BuildDirectory,'html');end

    reportInfoList={};
    if exist(fullfile(htmlDir,'reportInfo.mat'),'file')==2
        load(fullfile(htmlDir,'reportInfo.mat'));
        reportInfoList=cell(1,length(reportInfo.FileInfo));%#ok<NODEF>
        for i=1:length(reportInfo.FileInfo)
            reportInfoList{i}=reportInfo.FileInfo{i}.FileName;
        end
    end

    reportFileInfo={};
    generatedFiles=regexp(generatedFileList,'\,','split');
    generatedFiles=unique(generatedFiles(1:end-1));
    for idx=1:length(generatedFiles)
        parsedFile=regexp(generatedFiles{idx},'\;','split');


        if isempty(strmatch(parsedFile{1},reportInfoList))
            reportFileInfo{length(reportFileInfo)+1}=struct('FileName',parsedFile{1},...
            'Group',parsedFile{2},'Type',parsedFile{3},'Path',parsedFile{4});
        end
    end





    sharedutilty=false;
    if~isequal(h.BuildDirectory,genUtilsPath)
        sharedutilty=true;
    end
    fileInfo=reportFileInfo;
    if~iscell(fileInfo)
        fileInfo={fileInfo};
    end

    if strcmp(genUtilsPath(end),filesep)
        genUtilsPath=genUtilsPath(1:end-1);
    end

    for i=1:length(fileInfo)


        [~,fname,ext]=fileparts(fileInfo{i}.FileName);
        fileInfo{i}.FileName=[fname,ext];


        if sharedutilty&&isequal(fileInfo{i}.Group,'utility')
            fileInfo{i}.Path=genUtilsPath;
            fileInfo{i}.Group='sharedutility';

        elseif isempty(fileInfo{i}.Path)
            fileInfo{i}.Path=h.BuildDirectory;
        end

    end




    if exist(fullfile(htmlDir,'reportInfo.mat'),'file')==2
        if~exist('reportInfo','var')
            load(fullfile(htmlDir,'reportInfo.mat'));
        end
        fileInfo=[reportInfo.FileInfo,fileInfo];
    end

    keys=cellfun(@(x)fullfile(x.Path,x.FileName),fileInfo,'UniformOutput',false);
    [~,tf]=unique(keys);
    fileInfo=fileInfo(tf);
    reportInfo.FileInfo=fileInfo;

    save(fullfile(htmlDir,'reportInfo.mat'),'reportInfo');
