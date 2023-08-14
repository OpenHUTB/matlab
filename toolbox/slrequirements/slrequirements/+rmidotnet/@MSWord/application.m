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

        setupAppSettingsForImport();

    case 'current'
        if~isempty(myApplication)&&isValid()
            result=myApplication;
        else
            myApplication=getRunning();
            result=myApplication;
        end

        setupAppSettingsForImport();

    case 'kill'
        if isempty(myApplication)||~isValid()
            myApplication=getRunning();
        end
        if~isempty(myApplication)
            try

                rmidotnet.docUtilObj('clearWord');

                allDocs=myApplication.Documents;
                for i=allDocs.Count:-1:1
                    allDocs.Item(i).Close(0);
                end
                myApplication.Quit();
            catch
            end
            myApplication=[];
        end
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
            NET.addAssembly('microsoft.office.interop.word');
            result=System.Runtime.InteropServices.Marshal.GetActiveObject('Word.Application');
            if~isa(result,'Microsoft.Office.Interop.Word.ApplicationClass')
                result=Microsoft.Office.Interop.Word.Application(result);
            end
        catch
            result=[];
        end
    end

    function result=getNew()
        NET.addAssembly('microsoft.office.interop.word');
        result=Microsoft.Office.Interop.Word.ApplicationClass;
    end




    function success=setupAppSettingsForImport()
        myApplication.Options.AllowReadingMode=0;

        success=true;
    end

end
