function success=pdfmanage(action,filename)


































    if(nargin<2)
        filename=string.empty();
    end

    if(strcmpi(action,"close"))
        success=closePDF(filename);

    elseif(strcmpi(action,'open'))
        success=openPDF(filename);

    elseif(strcmpi(action,'islocked'))
        success=mlreportgen.utils.isFileLocked(filename);

    elseif(strcmpi(action,'isopen'))
        success=mlreportgen.utils.rptviewer.isOpen(filename);

    elseif(strcmpi(action,'isvieweravailable'))
        success=1;

    else
        error(message('rptgen:rptgenrptgen:unknownActionLabel',action));
    end
end


function retVal=closePDF(filename)
    if(isempty(filename)||strcmp(filename,'all'))
        files=mlreportgen.utils.rptviewer.filenames();
        for file=files
            [~,~,fExt]=fileparts(file);
            if strcmp(fExt,".pdf")
                mlreportgen.utils.rptviewer.close(file);
            end
        end
        retVal=1;
    elseif mlreportgen.utils.rptviewer.isOpen(filename)
        mlreportgen.utils.rptviewer.close(filename);
        retVal=2;
    else
        retVal=0;
    end
end

function retVal=openPDF(filename)


    mlreportgen.utils.internal.logmsg('openPDF');

    if isempty(filename)
        retVal=0;
    else
        mlreportgen.utils.internal.logmsg('isOpen');
        isFileAlreadyOpened=mlreportgen.utils.rptviewer.isOpen(filename);
        try
            mlreportgen.utils.internal.logmsg('rptviewer open');

            mlreportgen.utils.rptviewer.open(filename);
            mlreportgen.utils.internal.logmsg('rptviewer isOpen');

            isFileOpened=mlreportgen.utils.rptviewer.isOpen(filename);
            if(isFileAlreadyOpened&&isFileOpened)
                retVal=2;
            elseif isFileOpened
                retVal=1;
            else
                retVal=0;
            end

            mlreportgen.utils.internal.logmsg('done');
        catch
            retVal=0;
            mlreportgen.utils.internal.logmsg('catch done');
        end
    end
end
