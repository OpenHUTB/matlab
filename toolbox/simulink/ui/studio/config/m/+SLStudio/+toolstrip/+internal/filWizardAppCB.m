



function filWizardAppCB(~,~)
    try
        filWizard;
    catch ex
        label=DAStudio.message('EDALink:studio:FILDlg');
        errordlg(loc_getErrorString(ex),label,'modal');
        return;
    end
end


function errstr=loc_getErrorString(ex,indent)
    if nargin==1
        indent=1;
    end
    spaces='    ';
    errstr=[repmat(spaces,1,indent-1),ex.message,sprintf('\n')];
    for i=1:numel(ex.cause)
        newerror=loc_getErrorString(ex.cause{i},indent+1);
        errstr=[errstr,...
        repmat(spaces,1,indent),'Caused By:',sprintf('\n'),newerror];%#ok<AGROW>
    end
end