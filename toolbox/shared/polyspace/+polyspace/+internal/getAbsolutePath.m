function filePath=getAbsolutePath(filePath,currDir)

    narginchk(1,2);

    if nargin<2

        currDir=pwd;
    end

    if isempty(filePath)
        filePath=currDir;
        return
    end

    validateattributes(filePath,{'char'},{'row'},mfilename('class'),'',1)
    validateattributes(currDir,{'char'},{'row'},mfilename('class'),'',1)

    if isunix&&strncmp(filePath,'~/',2)
        res=deblank(getenv('HOME'));
        if~isempty(res)
            filePath=[res,filePath(2:end)];
        end
    end

    FILESYSTEM_GETABSOLUTEPATH=1;
    filePath=filesystem_mex(FILESYSTEM_GETABSOLUTEPATH,currDir,filePath);
