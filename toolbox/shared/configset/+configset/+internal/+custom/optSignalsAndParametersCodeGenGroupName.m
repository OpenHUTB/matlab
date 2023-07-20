function dispName=optSignalsAndParametersCodeGenGroupName(cs)


    showRTW=cs.get_param('ShowRTWWidgets');
    if strcmp(showRTW,'on')
        dispName=message('RTW:configSet:optCodeGenName').getString;
    else
        dispName='';
    end


