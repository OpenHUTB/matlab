function out=excelApp(method,varargin)




    persistent hExcel;
    mlock;


    if reqmgt('rmiFeature','UseDotNet')
        useDotNet=true;
    else
        useDotNet=false;
    end

    if nargin==0
        hExcel=get_app();
        out=hExcel;
    else
        switch method

        case 'get'
            hExcel=get_app();
            out=hExcel;

        case 'kill'
            if isempty(hExcel)||~isValid()
                hExcel=get_running();
            end
            if~isempty(hExcel)
                if useDotNet
                    System.Runtime.InteropServices.Marshal.ReleaseComObject(hExcel);
                else
                    hExcel.Quit();
                end
                hExcel=[];
                out=true;
            else
                out=false;
            end



            rmicom.excelRpt('clear');

        case 'clear'


            hExcel=[];
            rmicom.excelRpt('clear');

        case 'exists'
            if isempty(hExcel)||~isValid()
                hExcel=get_running();
            end
            out=~isempty(hExcel);

        case 'dispdoc'
            if isempty(hExcel)||~isValid()
                hExcel=get_app();
            end
            hExcel.Visible=1;
            out=dispdoc(varargin{1});

        case 'finddoc'
            if isempty(hExcel)||~isValid()
                hExcel=get_running();
            end
            if isempty(hExcel)
                out=[];
            else
                out=finddoc(varargin{1});
            end

        case 'loaddoc'
            if isempty(hExcel)||~isValid()
                hExcel=get_app();
            end
            out=loaddoc(varargin{1});

        case 'dispapp'
            if isempty(hExcel)||~isValid()
                hExcel=get_app();
            end
            hExcel.Visible=1;
            out=hExcel;

        case 'activeapp'
            hExcel=get_app();

        case 'activedoc'
            if isempty(hExcel)||~isValid()
                hExcel=get_running();
            end
            out=get_active_workbook();

        case 'activecell'
            if isempty(hExcel)||~isValid()
                hExcel=get_running();
            end
            out=hExcel.ActiveCell;

        case 'activetext'
            if isempty(hExcel)||~isValid()
                hExcel=get_running();
            end
            out=get_active_text();

        case 'activebookmark'
            if isempty(hExcel)||~isValid()
                hExcel=get_running();
            end
            out=get_active_named_item();

        case 'setname'
            if isempty(hExcel)||~isValid()
                hExcel=get_running();
            end
            out=set_name_for_selection(varargin{1});

        otherwise
            error(message('Slvnv:reqmgt:com_excel_app:UnknownMethod'));
        end
    end



    function result=get_app()
        result=get_running();
        if isempty(result)
            result=get_new();
        end
    end

    function result=get_new()
        if useDotNet
            NET.addAssembly('microsoft.office.interop.excel');
            result=Microsoft.Office.Interop.Excel.ApplicationClass;
        else
            result=actxserver('excel.application');
        end
    end

    function result=get_running()
        try
            if useDotNet
                NET.addAssembly('microsoft.office.interop.excel');
                hObject=System.Runtime.InteropServices.Marshal.GetActiveObject('Excel.Application');
                if isa(hObject,'Microsoft.Office.Interop.Excel.ApplicationClass')
                    result=hObject;
                else
                    result=Microsoft.Office.Interop.Excel.Application(hObject);
                end
            else
                result=actxGetRunningServer('excel.application');
            end
        catch ex %#ok<NASGU>
            result=[];
        end
    end

    function targetAddress=set_name_for_selection(bName)
        targetAddress=hExcel.Selection.Address;
        if any(targetAddress==':')
            hExcel.Selection.Name=bName;
        else
            hExcel.ActiveCell.Name=bName;
        end
    end

    function bName=get_active_named_item()

        if useDotNet
            try
                hRange=Microsoft.Office.Interop.Excel.Range(hExcel.Selection);
                hName=Microsoft.Office.Interop.Excel.Name(hRange.Name);
                bName=hName.NameLocal.char;
            catch ex %#ok<NASGU>
                bName='';
            end
        else
            try
                bName=hExcel.Selection.Name.get('Name');
            catch ex %#ok<NASGU>
                bName='';
            end
        end
    end

    function text=get_active_text()

        if useDotNet
            text=hExcel.ActiveCell.Text.char;
        else
            text=hExcel.ActiveCell.Text;
        end
    end

    function workbook=get_active_workbook()
        workbook=[];
        if~isempty(hExcel)
            workbook=hExcel.ActiveWorkbook;
        end
    end

    function hDoc=finddoc(filename)
        hDoc=[];
        hDocs=hExcel.Workbooks;
        openCount=hDocs.Count;
        for i=1:openCount
            thisDoc=hDocs.Item(i);
            if useDotNet
                docFullName=thisDoc.FullName.char;
            else
                docFullName=thisDoc.FullName;
            end
            if rmiut.cmp_paths(docFullName,filename)
                hDoc=thisDoc;
                break;
            end
        end
    end

    function hDoc=loaddoc(filename)
        hDoc=finddoc(filename);

        if isempty(hDoc)
            hDocs=hExcel.Workbooks;
            hDoc=hDocs.Open(filename,[],0);
        else

            hDoc.Windows.Item(1).Activate;
        end
    end

    function hDoc=dispdoc(filename)

        hDoc=loaddoc(filename);

        if reqmgt('rmiFeature','UseDotNet')
            if strcmpi(hExcel.Windows.Item(1).WindowState,'xlMinimized')
                hExcel.Windows.Item(1).WindowState='xlNormal';
            end
        else
            if strcmpi(hExcel.WindowState,'xlMinimized')
                hExcel.WindowState='xlNormal';
            end
        end
        hDoc.Activate;
    end

    function result=isValid()
        result=1;
        try
            hExcel.Version;
        catch Mex2 %#ok<NASGU>
            result=0;
        end
    end

end

