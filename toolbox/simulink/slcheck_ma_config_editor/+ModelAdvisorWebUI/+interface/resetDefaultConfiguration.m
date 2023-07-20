function resultJSON=resetDefaultConfiguration()

    try
        ModelAdvisor.ConfigUI.openRestoreDlg('MACEWeb');
        success=true;
        title='';
        msg='';
    catch E
        success=false;
        title='Error';
        msg=E.message;
    end
    result=struct('success',success,'message',jsonencode(struct('title',title,'content',msg)),'warning',false,'filepath','');
    resultJSON=jsonencode(result);
end