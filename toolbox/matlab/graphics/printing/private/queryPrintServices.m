function varargout=queryPrintServices(action,varargin)









    varargout={};
    action=lower(action);
    switch action
    case 'validate'
        if length(varargin)==1
            pname=varargin{1};

            varargout{1}=isValidPrinter(pname);
        else
            varargout{1}=false;
        end

    case 'getdefaultandlist'
        varargout{1}=getDefaultPrinter();
        varargout{2}=getPrinterList();
    case 'supportscolor'
        varargout{1}=printerSupportsColor(varargin{:});

    end

end


function valid=isValidPrinter(printerName)
    if(usesJava())
        import com.mathworks.hg.util.PrinterUtils.*;
        valid=isPrinterValid(printerName);
    else
        valid=matlab.graphics.internal.isPrinterValid(printerName);
    end
end


function def=getDefaultPrinter()
    if(usesJava())
        import com.mathworks.hg.util.PrinterUtils.*;
        def=getDefaultPrinterName;
        if~isempty(def)

            def=(def.toCharArray())';
        end




        if isempty(def)
            def='';
        end
    else
        def=matlab.graphics.internal.getDefaultPrinterName();
    end
end


function plist=getPrinterList()
    if(usesJava())
        import com.mathworks.hg.util.PrinterUtils.*;
        svcList=getAvailablePrinterNames();
        if~isempty(svcList)
            for idx=1:length(svcList)
                plist{idx}=(svcList(idx).toCharArray())';%#ok<AGROW>
            end
        else
            plist={};
        end
    else
        plist=matlab.graphics.internal.getAvailablePrinterNames();
    end
end


function doesColor=printerSupportsColor(printername)


    persistent LastPrinter;
    persistent LastPrinterDoesColor;

    if isempty(printername)
        printername=getDefaultPrinter();
    end


    if~isempty(LastPrinter)&&strcmpi(LastPrinter,printername)
        doesColor=LastPrinterDoesColor;
    else
        if(usesJava())
            import com.mathworks.hg.util.PrinterUtils.*;
            doesColor=supportsColor(printername);
        else
            doesColor=matlab.graphics.internal.supportsColor(printername);
        end
        LastPrinter=printername;
        LastPrinterDoesColor=doesColor;
    end
end

function isJava=usesJava()
    s=settings;
    isJava=~s.matlab.ui.internal.figuretype.webfigures.ActiveValue;
end
