function out=getCustomCodeList(mdlName)





    currDir=pwd;
    mdlName=bdroot(mdlName);
    customFiles=get_param(mdlName,'CustomSource');
    includePaths=get_param(mdlName,'CustomInclude');
    customLibs=get_param(mdlName,'CustomLibrary');

    lStartDirToRestore=currDir;
    lBuildDirectory=RptgenRTW.getBuildDir;
    lCodeFormat='';

    custCode=rtwprivate('rtw_resolve_custom_code',mdlName,...
    lCodeFormat,lStartDirToRestore,lBuildDirectory,...
    includePaths,...
    customFiles,customLibs);

    out=custCode.parsedSrcFiles(:);
    for i=1:length(out)
        if isempty(custCode.parsedSrcPaths)
            out(i)=fullfile(currDir,out(i));
        end
    end
