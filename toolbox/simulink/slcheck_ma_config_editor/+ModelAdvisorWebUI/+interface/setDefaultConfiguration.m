function resultJSON=setDefaultConfiguration(filePath)
    try
        ModelAdvisor.setDefaultConfiguration(filePath);

        success=true;
        title='';
        msg='';
    catch E
        success=false;
        title='Error';
        msg=E.message;
        filePath='';
    end
    result=struct('success',success,'message',jsonencode(struct('title',title,'content',msg)),'warning',false,'filepath',filePath,'value','');
    resultJSON=jsonencode(result);
    t=ModelAdvisorWebUI.interface.MACEUI.getInstance;
    t.bringToFront;
end