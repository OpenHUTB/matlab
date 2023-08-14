function return_flag=pagesetupdlg_helper(hFig)






    return_flag=true;
    warningKey='FunctionRemoved';
    if isappdata(hFig,'useDeprecatedPageSetupDlg')
        if getappdata(hFig,'useDeprecatedPageSetupDlg')

            return_flag=false;
            warningKey='FunctionToBeRemoved';
        else
            return_flag=true;
            warningKey='FunctionRemoved';
        end
    end



    warning(message(['MATLAB:pagesetupdlg:',warningKey]));

