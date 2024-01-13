function filePaths=findSubfolders(filePath)

    narginchk(0,1);

    if nargin<1||isempty(filePath)
        filePath=pwd;
    end

    FILESYSTEM_FIND_SUBFOLDERS=5;
    filePaths=filesystem_mex(FILESYSTEM_FIND_SUBFOLDERS,filePath);
