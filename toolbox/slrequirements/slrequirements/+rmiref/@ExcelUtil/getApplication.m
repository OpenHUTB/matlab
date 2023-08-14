function app=getApplication(use_current)








    try
        hExcel=actxGetRunningServer('excel.application');
    catch Mex %#ok
        if nargin>0&&use_current
            error(message('Slvnv:rmiref:DocCheckExcel:ExcelNotRunning'));
        else
            hExcel=actxserver('excel.application');
        end
    end

    try
        hExcel.Version;
    catch Mex %#ok
        try
            hExcel=actxserver('excel.application');
        catch Mex
            error(message('Slvnv:rmiref:DocCheckExcel:FailConnectExcelServer'));
        end
    end
    app=hExcel;
end
