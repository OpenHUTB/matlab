function rptview(name,varargin)




    if~isempty(varargin)
        arg=string(varargin{1});
        if isConvertToPDF(name,arg)
            wordDoc=mlreportgen.utils.word.open(name);
            update(wordDoc);
            fileName=exportToPDF(wordDoc);
            close(wordDoc,0);
        else
            fileName=getFileName(name,arg);
        end
    else
        fileName=getFileName(name,"html");
    end

    if isempty(fileName)
        error(message("mlreportgen:utils:error:fileNotFound",name));
    end

    if isdeployed
        unmanagedView(fileName);
    else
        try
            viewer=mlreportgen.utils.rptviewer.viewer(fileName);
            if isa(viewer,"mlreportgen.utils.WordDoc")&&~isReadOnly(viewer)
                update(viewer);
                save(viewer);
            end
            show(viewer);
        catch ME
            if strcmp(ME.identifier,"mlreportgen:utils:error:supportedOnlyOnWindows")

                unmanagedView(fileName);
            else
                try
                    mlreportgen.utils.rptviewer.close(fileName);
                catch
                end
                rethrow(ME);
            end
        end
    end
end

function tf=isConvertToPDF(name,arg)
    tf=false;
    if strcmp(arg,"pdf")
        [~,~,fExt]=fileparts(name);
        tf=ismember(fExt,mlreportgen.utils.WordDoc.FileExtensions);
    end
end

function fileName=getFileName(name,format)
    if(isa(name,"mlreportgen.dom.Document")...
        ||isa(name,"slreportgen.webview.DocumentBase"))
        fileName=getFileNameFromDOMDoc(name);
    elseif isa(name,"mlreportgen.ppt.Presentation")
        fileName=getFileNameFromPPTDoc(name);
    else
        fileName=getFileNameWithFormat(name,format);
        if isfolder(name)
            folderPath=mlreportgen.utils.findFile(name,"FileMustExist",false);
            if~isempty(fileName)


                if strcmp(format,"html")
                    [~,~,fExt]=fileparts(fileName);
                    if strcmp(fExt,".htmtx")
                        mainPart=mlreportgen.utils.HTMXDoc.getMainPart(fileName);
                        fileName=fullfile(folderPath,mainPart);
                    end
                end
            else
                mainPart=mlreportgen.utils.HTMXDoc.getMainPart(folderPath);
                fileName=fullfile(folderPath,mainPart);
            end
        end
    end
end

function fileName=getFileNameWithFormat(name,format)
    switch lower(format)
    case "html"
        fileName=mlreportgen.utils.findFile(name,...
        "FileExtensions",mlreportgen.utils.HTMXDoc.FileExtensions);
    case "docx"
        fileName=mlreportgen.utils.findFile(name,...
        "FileExtensions",mlreportgen.utils.WordDoc.FileExtensions);
    case "pdf"
        fileName=mlreportgen.utils.findFile(name,...
        "FileExtensions",[mlreportgen.utils.PDFDoc.FileExtensions,".pdftx"]);
    case "html-file"
        fileName=mlreportgen.utils.findFile(name,...
        "FileExtensions",mlreportgen.utils.HTMLDoc.FileExtensions);
    case "ppt"
        fileName=mlreportgen.utils.findFile(name,...
        "FileExtensions",mlreportgen.utils.PPTPres.FileExtensions);
    otherwise
        error(message("mlreportgen:utils:error:invalidFormat",format));
    end
end

function fileName=getFileNameFromDOMDoc(domDoc)
    switch string(domDoc.OpenStatus)
    case "closed"
        fileName=domDoc.OutputPath;
    case "open"
        if~close(domDoc)
            error(message("mlreportgen:utils:error:cannotCloseViewer",domDoc.OutputPath));
        end
        fileName=domDoc.OutputPath;
    otherwise
        error(message("mlreportgen:utils:error:unopenedDocument",domDoc.OutputPath));
    end

    if isfolder(fileName)
        try
            mainPart=mlreportgen.utils.HTMXDoc.getMainPart(fileName);
            fileName=fullfile(fileName,mainPart);
        catch ME
            if(domDoc.PackageType=="unzipped")


                fileName=findRootHTMLFile(fileName);
                if isempty(fileName)
                    rethrow(ME);
                end
            else
                rethrow(ME);
            end
        end
    end
    fileName=mlreportgen.utils.findFile(fileName);
end

function fileName=getFileNameFromPPTDoc(pptDoc)
    close(pptDoc);
    fileName=mlreportgen.utils.findFile(pptDoc.OutputPath);
end

function fileName=findRootHTMLFile(folderPath)
    guess=fullfile(folderPath,"root.html");
    if isfile(guess)
        fileName=guess;
        return;
    end

    guess=fullfile(folderPath,"report.html");
    if isfile(guess)
        fileName=guess;
        return;
    end

    listing=dir(fullfile(folderPath,"*.html"));
    if~isempty(listing)
        guess=fullfile(folderPath,listing(1).name);
        if isfile(guess)
            fileName=guess;
            return;
        end
    end

    fileName=string.empty();
end

function unmanagedView(fileName)
    status=0;
    if(ispc)
        winopen(fileName);
    else
        fileName=replace(fileName," ","\ ");
        if ismac
            cmd="open "+fileName;
        else


            cmd="xdg-open "+fileName;
        end
        [status,result]=system(cmd);
    end

    if(status~=0)
        error(message("mlreportgen:utils:error:systemCallFailed",cmd,result));
    end
end