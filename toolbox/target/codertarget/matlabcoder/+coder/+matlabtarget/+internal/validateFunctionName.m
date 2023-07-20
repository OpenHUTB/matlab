function[filePath,fcnName]=validateFunctionName(fcnName)










    fcnName=convertStringsToChars(fcnName);


    path=which(fcnName);

    [filePath,fcnName]=fileparts(fcnName);

    if isempty(path)

        currentDir=pwd;
        if isempty(filePath)
            try
                error(message('codertarget:matlabtarget:FcnNotFound',fcnName));
            catch me
                throwAsCaller(me);
            end
        else
            cd(filePath);
        end
    end

    try
        nargin(fcnName);
    catch exception
        if exist(fcnName,'file')~=2
            error(message('codertarget:matlabtarget:FileNotfound',fcnName));
        else
            if strcmp(exception.identifier,'MATLAB:nargin:isScript')
                error(message('codertarget:matlabtarget:FileIsScript',fcnName));
            end
        end
    end


    if isempty(path)

        cd(currentDir);
    end

end


