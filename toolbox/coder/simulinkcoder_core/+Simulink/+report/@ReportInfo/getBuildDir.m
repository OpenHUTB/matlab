function out=getBuildDir(obj)
    if isempty(obj.BuildDirectory)||~exist(obj.BuildDirectory,'dir')
        DAStudio.error('RTW:report:buildFolderNotFound',obj.BuildDirectory);
    end
    out=obj.BuildDirectory;
end
