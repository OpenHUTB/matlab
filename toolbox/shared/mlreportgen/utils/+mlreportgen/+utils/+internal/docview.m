function varargout=docview(fileName,varargin)




























    ME=[];
    retVal=true;
    errMsg=string.empty();

    fullPath=mlreportgen.utils.findFile(...
    fileName,...
    "FileExtensions",mlreportgen.utils.WordDoc.FileExtensions);


    if isempty(fullPath)
        errMsg=message("mlreportgen:utils:error:fileNotFound",fileName);
        ME=MException(errMsg);
        retVal=false;
    else
        try
            if ispc()
                implPC(fullPath,varargin{:});
            elseif ismac()
                implMAC(fullPath,varargin{:})
            else
                implGLNX(fullPath,varargin{:})
            end
        catch ME
            retVal=false;
            errMsg=ME.message;
        end
    end

    if(nargout==1)
        varargout={retVal};
    elseif(nargout==2)
        varargout={retVal,errMsg};
    elseif~isempty(ME)
        throw(ME);
    end
end

function implPC(fullPath,varargin)
    if mlreportgen.utils.word.isAvailable()
        implPCWord(fullPath,varargin{:});
    else
        implPCNoWord(fullPath,varargin{:});
    end
end

function implPCNoWord(fullPath,varargin)
    if~isempty(varargin)
        [~,reason]=mlreportgen.utils.word.isAvailable();
        error(message(...
        "mlreportgen:utils:error:unsupportedPlatformOfficeCommands",...
        mlreportgen.utils.WordApp.Name,...
        reason));
    end
    winopen(fullPath);
end

function implPCWord(fullPath,varargin)
    wdoc=mlreportgen.utils.word.load(fullPath);
    try
        if~isempty(varargin)
            commands=string(varargin);
            for command=commands
                switch lower(command)
                case{"updatedocxfields","updatefields","-updatefield"}
                    update(wdoc);
                    if~isReadOnly(wdoc)
                        save(wdoc);
                    end
                case "unlinkfields"
                    unlinkFields(wdoc);
                case "unlinkdocxsubdoc"
                    unlinkSubdocuments(wdoc);
                case "saveasdoc"
                    saveAsDoc(wdoc);
                    close(wdoc);
                case "savedoc"
                    save(wdoc);
                    close(wdoc);
                case "printdoc"
                    show(wdoc);
                    print(wdoc,'ScaleToFitPaper',false);
                case "printdocscaled"
                    show(wdoc);
                    print(wdoc,'ScaleToFitPaper',true);
                case "convertdocxtopdf"
                    saved=isSaved(wdoc);
                    exportToPDF(wdoc);
                    close(wdoc,~saved);
                case "showdocxaspdf"
                    saved=isSaved(wdoc);
                    pdfFile=exportToPDF(wdoc);
                    close(wdoc,~saved);
                    mlreportgen.utils.rptviewer.open(pdfFile);
                case "closedoc"
                    close(wdoc,false);
                case "closeapp"
                    if isOpen(wdoc)
                        close(wdoc,false);
                    end
                otherwise
                    warning(message(...
                    "mlreportgen:utils:warning:unsupportedCommand",...
                    command));
                end
            end
        end

        if~isOpen(wdoc)
            mlreportgen.utils.word.close();
        else
            show(wdoc);
        end
    catch ME
        mlreportgen.utils.word.close();
        rethrow(ME);
    end
end


function implMAC(fullPath,varargin)
    if~isempty(varargin)
        error(message(...
        "mlreportgen:utils:error:unsupportedPlatformOfficeCommands",...
        mlreportgen.utils.WordApp.Name));
    end

    openOfficeApp='/Applications/OpenOffice.app/Contents/MacOS/soffice';
    if~isfile(openOfficeApp)
        error(message("mlreportgen:utils:error:fileNotFound",openOfficeApp));
    end



    cmd=sprintf('%s -writer "%s" &',openOfficeApp,fullPath);
    system(cmd);
end

function implGLNX(fullPath,varargin)
    if~isempty(varargin)
        error(message(...
        "mlreportgen:utils:error:unsupportedPlatformOfficeCommands",...
        mlreportgen.utils.WordApp.Name));
    end

    cmd='which soffice';
    [status,errmsg]=system(cmd);
    if(status~=0)
        error(message("mlreportgen:utils:error:systemCallFailed",cmd,errmsg));
    end



    cmd=sprintf('soffice -writer "%s" &',fullPath);
    system(cmd);
end
