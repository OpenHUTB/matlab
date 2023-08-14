function[bResult,ft]=getListReport(FailingObjs,MsgCtlPrefix)

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setInformation(DAStudio.message([MsgCtlPrefix,'_tip']));
    ft.setSubBar(true);

    if isempty(FailingObjs)
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([MsgCtlPrefix,'_pass']));
        bResult=true;
    else
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([MsgCtlPrefix,'_warn']));
        ft.setRecAction(DAStudio.message([MsgCtlPrefix,'_recAction']));
        ft.setListObj(FailingObjs);
        bResult=false;
    end

end
