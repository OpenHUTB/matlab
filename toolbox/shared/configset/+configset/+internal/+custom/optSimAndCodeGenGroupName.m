function dispName=optSimAndCodeGenGroupName(cs)


    showRTW=cs.get_param('ShowRTWWidgets');
    if strcmp(showRTW,'on')
        dispName=message('RTW:configSet:optSimAndCodeGenName').getString;
    else
        dispName='';
    end


