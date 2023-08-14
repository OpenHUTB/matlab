function ret = checkFilePath(inpath, isReport)
%
% Check a file path is valid or not

% Copyright 2014-2015 The MathWorks, Inc.
%
    errors.INVALID_FILE_PATH = -1;
    errors.FAIL_TO_CREATE_PATH = -2;
    errors.FAIL_TO_CREATE_FILE = -3;    

    [outputPath,outputName,outputExt] = fileparts(inpath);
    if(isempty(outputPath))
        outputPath = pwd();
    end
    
    if(isempty(outputName) || isempty(outputExt))
        ret = errors.INVALID_FILE_PATH;
        return;
    end

    if(isReport)
        % report, create file/path if it does not exist
        checkPath = stm.internal.report.createPath(outputPath);
        if(~checkPath)
            ret =  errors.FAIL_TO_CREATE_PATH;
            return;
        end
        if(exist(outputPath,'dir') == 0)
            ret =  errors.FAIL_TO_CREATE_PATH;
            return;
        end
        % directory part is good.

        inpath = fullfile(outputPath,[outputName outputExt]);
        if(exist(inpath,'file') == 0)
            fid = fopen(inpath,'a');
            if(fid < 0)
                ret = errors.FAIL_TO_CREATE_FILE;
                return;
            else
                fclose(fid);
                delete(inpath);
            end
        end
    else
        % template, check file existence
        if(exist(inpath,'file') == 0)
            ret = errors.INVALID_FILE_PATH;
            return;
        end
    end

    ret = 1;
end

