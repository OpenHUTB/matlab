function varargout=pptview(fileName,varargin)



















    ME=[];
    retVal=true;
    errMsg=string.empty();

    fullFilePath=mlreportgen.utils.findFile(...
    fileName,...
    "FileExtensions",mlreportgen.utils.PPTPres.FileExtensions);

    try
        if ispc()
            implPC(fullFilePath,varargin{:});
        elseif ismac()
            implMAC(fullFilePath,varargin{:})
        else
            implGLNX(fullFilePath,varargin{:})
        end
    catch ME
        retVal=false;
        errMsg=ME.message;
    end

    if(nargout==1)
        varargout={retVal};
    elseif(nargout==2)
        varargout={retVal,errMsg};
    elseif~isempty(ME)
        throw(ME);
    end
end

function implPC(fullFilePath,varargin)
    if mlreportgen.utils.powerpoint.isAvailable()
        implPCPowerpoint(fullFilePath,varargin{:});
    else
        implPCNoPowerpoint(fullFilePath,varargin{:});
    end
end

function implPCNoPowerpoint(fullPath,varargin)
    if~isempty(varargin)
        error(message(...
        "mlreportgen:utils:error:unsupportedPlatformOfficeCommands",...
        mlreportgen.utils.PPTApp.Name));
    end
    winopen(fullPath);
end

function implPCPowerpoint(fullFilePath,varargin)
    pres=mlreportgen.utils.powerpoint.load(fullFilePath);
    try
        if~isempty(varargin)
            commands=string(varargin);
            for command=commands
                switch lower(command)
                case "converttopdf"
                    exportToPDF(pres);
                    close(pres);
                case "showaspdf"
                    pdfFile=exportToPDF(pres);
                    close(pres);
                    mlreportgen.utils.rptviewer.open(pdfFile);
                case "closedoc"
                    close(pres,false);
                case "closeapp"
                    if isOpen(pres)
                        close(pres,false);
                    end
                otherwise
                    warning(message(...
                    "mlreportgen:utils:warning:unsupportedCommand",...
                    command));
                end
            end
        end

        if~isOpen(pres)
            mlreportgen.utils.powerpoint.close();
        else
            show(pres);
        end
    catch ME
        mlreportgen.utils.powerpoint.close();
        rethrow(ME);
    end
end

function implMAC(fullPath,varargin)
    if~isempty(varargin)
        [~,reason]=mlreportgen.utils.powerpoint.isAvailable();
        error(message(...
        "mlreportgen:utils:error:unsupportedPlatformOfficeCommands",...
        mlreportgen.utils.PPTApp.Name,...
        reason));
    end

    cmd=sprintf('/Applications/OpenOffice.app/Contents/MacOS/soffice -impress "%s"',fullPath);
    [status,errmsg]=system(cmd);
    if(status==1)
        error(message("mlreportgen:utils:error:systemCallFailed",cmd,errmsg));
    end
end

function implGLNX(fullPath,varargin)
    if~isempty(varargin)
        error(message(...
        "mlreportgen:utils:error:unsupportedPlatformOfficeCommands",...
        mlreportgen.utils.PPTApp.Name));
    end

    cmd=sprintf('soffice -impress "%s" &',fullPath);
    [status,errmsg]=system(cmd);
    if(status==1)
        error(message("mlreportgen:utils:error:systemCallFailed",cmd,errmsg));
    end
end

