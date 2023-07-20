function STFCheck=checkSTF(model)





    STFCheck=ModelAdvisor.FormatTemplate('ListTemplate');

    stf=get_param(model,'SystemTargetFile');

    switch stf
    case 'slrealtime.tlc'
        STFCheck.setSubResultStatus('Pass');
        STFCheck.setSubResultStatusText(DAStudio.message('slrealtime:advisor:correctSTF'));
    case{'slrt.tlc','slrtert.tlc','xpctarget.tlc','xpctargetert.tlc'}
        STFCheck.setSubResultStatus('Fail');
        STFCheck.setSubResultStatusText(DAStudio.message('slrealtime:advisor:stfDeprecated',stf));
    otherwise
        STFCheck.setSubResultStatus('Warn');
        STFCheck.setSubResultStatusText(DAStudio.message('slrealtime:advisor:otherSTF',stf));
    end

    STFCheck.setSubTitle(DAStudio.message('slrealtime:advisor:stfSubTitle'));

end
