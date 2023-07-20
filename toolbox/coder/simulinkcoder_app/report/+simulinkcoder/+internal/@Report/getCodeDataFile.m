function[codeFile,annotationFile,covFiles,ref]=getCodeDataFile(model,ref)

    if nargin<2
        ref=false;
    end

    name='scv';
    [rptInfo,ref]=simulinkcoder.internal.util.getReportInfo(model,ref);
    rootDir=rptInfo.StartDir;


    type=rptInfo.ModelReferenceTargetType;
    if strcmpi(type,'RTW')
        name=[name,'_ref'];
    end


    path=fullfile(rootDir,rptInfo.ModelRefRelativeBuildDir,'tmwinternal');
    codeFile=fullfile(path,name);
    annotationFile=fullfile(path,[name,'.anno']);


    fileInfoList=rptInfo.getSortedFileInfoList_Cached();
    files=fileInfoList.FileName;
    n=length(files);
    covFiles=cell(n,1);
    for i=1:n
        file=files{i};
        [path,name,ext]=fileparts(file);
        covFiles{i}=fullfile(path,'html',[name,ext,'.cov']);
    end