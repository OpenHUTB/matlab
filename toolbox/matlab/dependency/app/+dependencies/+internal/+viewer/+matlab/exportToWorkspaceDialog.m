function exportToWorkspaceDialog(value)





    closeExistingDialogs();

    varName=string(inputdlg(...
    i_getResource("DialogVariableName"),...
    i_getResource("DialogTitle"),...
    [1,35],i_getDefaultVariableName("files")));

    if isempty(varName)
        return
    end

    if evalin("base","exist('"+varName+"','var')")&&...
        i_getOverwrite(varName)~=i_getResource("ReplaceVariableDialogAnswerYes")
        return;
    end

    try
        assignin("base",char(varName),value);
    catch exc
        if exc.identifier=="MATLAB:assigninInvalidVariable"
            errorDlg=errordlg(...
            i_getResource("InvalidVariableDialogText",varName),...
            i_getResource("InvalidVariableDialogTitle"));
            uiwait(errorDlg);
        else
            rethrow(exc);
        end
    end

end


function closeExistingDialogs
    allRootWindows=allchild(groot);

    existingQuestDlg=findobj(...
    allRootWindows,...
    'Name',i_getResource("ReplaceVariableDialogTitle"),...
    'Tag',i_getResource("ReplaceVariableDialogTitle"),...
    'Parent',groot,...
    'Type','figure',...
    'WindowStyle','modal');
    close(existingQuestDlg);

    existingErrorDlg=findobj(...
    allRootWindows,...
    'Name',i_getResource("InvalidVariableDialogTitle"),...
    'Tag',['Msgbox_',i_getResource("InvalidVariableDialogTitle")],...
    'Parent',groot,...
    'Type','figure',...
    'WindowStyle','modal');
    close(existingErrorDlg);

    existingDlg=findobj(...
    allRootWindows,...
    'Name',i_getResource("DialogTitle"),...
    'Tag',i_getResource("DialogTitle"),...
    'Parent',groot,...
    'Type','figure',...
    'WindowStyle','modal');
    close(existingDlg);
end


function answer=i_getOverwrite(varName)
    ansYes=i_getResource("ReplaceVariableDialogAnswerYes");
    ansNo=i_getResource("ReplaceVariableDialogAnswerNo");
    answer=questdlg(...
    i_getResource("ReplaceVariableDialogQuestion",varName),...
    i_getResource("ReplaceVariableDialogTitle"),...
    ansYes,...
    ansNo,...
    ansYes);
end


function defName=i_getDefaultVariableName(baseName,counter)
    if nargin==1
        defName=baseName;
        counter=0;
    else
        defName=baseName+"_"+num2str(counter);
    end
    if evalin("base","exist('"+defName+"','var')")
        defName=i_getDefaultVariableName(baseName,counter+1);
        return
    end
end

function res=i_getResource(key,varargin)
    key="MATLAB:dependency:viewer:ToBaseWorkspace"+key;
    res=string(message(key,varargin{:}));
end
