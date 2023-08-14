function selection=handleAlerts(figHandle,condition,msg,title)

    switch condition
    case 'question'

        yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
        no=vision.getMessage('MATLAB:uistring:popupdialogs:No');

        if useAppContainer
            selection=uiconfirm(figHandle,msg,title,'Options',{yes,no},...
            'DefaultOption',yes);
        else
            selection=questdlg(vision.getMessage...
            ('vision:labeler:LoadingDlgSourcePendingWarning'),...
            vision.getMessage('vision:labeler:LoadingDlgWarningTitle'),...
            yes,no,yes);

            if isempty(selection)
                selection=no;
            end
        end

    case 'error'
        selection=[];
        if useAppContainer
            uialert(figHandle,msg,title);
        else
            errordlg(msg,title);
        end
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end