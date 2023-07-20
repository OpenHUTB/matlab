function[fullDirName]=create_directory_path(baseDirName,varargin)


    if baseDirName(end)==filesep
        baseDirName=baseDirName(1:end-1);
    end

    fullDirName=baseDirName;

    for i=1:(nargin-1)
        childDirName=varargin{i};
        fullDirName=[baseDirName,filesep,childDirName];
        if~exist(fullDirName,'dir')
            [success,errorMessage]=mkdir(baseDirName,childDirName);
            if~success
                throw(MException(message('Simulink:cgxe:FailedToCreateDirectory',...
                fullDirName,errorMessage)));
            end
        end
        baseDirName=fullDirName;
    end
