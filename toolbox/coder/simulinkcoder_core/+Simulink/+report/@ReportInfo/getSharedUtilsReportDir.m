function out=getSharedUtilsReportDir(obj)
    out=[];
    if~isempty(obj.GenUtilsPath)&&~strcmp(obj.GenUtilsPath,obj.BuildDirectory)
        out=fullfile(obj.GenUtilsPath,'html');
    end
end
