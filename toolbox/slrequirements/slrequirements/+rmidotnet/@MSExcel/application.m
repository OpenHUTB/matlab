function result=application(method)





    persistent myApplication

    if nargin==0
        method='get';
    end

    switch method
    case 'get'
        if~isempty(myApplication)&&isValid()
            result=myApplication;
        else
            myApplication=getApp();
            result=myApplication;
        end

    case 'current'
        if~isempty(myApplication)&&isValid()
            result=myApplication;
        else
            myApplication=getRunning();
            result=myApplication;
        end

    case 'kill'
        if isempty(myApplication)||~isValid()
            myApplication=getRunning();
        end
        try

            rmidotnet.docUtilObj('clearExcel');

            allDocs=myApplication.Workbooks;
            for i=allDocs.Count:-1:1
                allDocs.Item(i).Close(0);
            end
            myApplication.Quit();


            System.Runtime.InteropServices.Marshal.ReleaseComObject(myApplication);
        catch
        end
        myApplication=[];
        result=[];

    otherwise
        error('unsupported method: %s',method);
    end

    function yesno=isValid()
        try
            myApplication.Version;
            yesno=true;
        catch
            yesno=false;
        end
    end

    function app=getApp()
        app=getRunning();
        if isempty(app)
            app=getNew();
        end
    end

    function result=getRunning()
        try
            NET.addAssembly('microsoft.office.interop.excel');
            result=System.Runtime.InteropServices.Marshal.GetActiveObject('Excel.Application');
            if~isa(result,'Microsoft.Office.Interop.Excel.ApplicationClass')
                result=Microsoft.Office.Interop.Excel.Application(result);
            end
        catch
            result=[];
        end
    end

    function result=getNew()
        NET.addAssembly('microsoft.office.interop.excel');
        result=Microsoft.Office.Interop.Excel.ApplicationClass;
    end

end
