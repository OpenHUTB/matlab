function ResultDescription=fixmeClockChecks(mdlTaskObj)





    checker=hdlcoder.ModelChecker.getModelChecker(mdlTaskObj,'runClockChecks');
    model=checker.m_sys;
    List=ModelAdvisor.List;
    List.setType('bulleted');

    clkInputs=hdlget_param(model,'ClockInputs');
    triggerAsClk=hdlget_param(model,'TriggerAsClock');


    if strcmpi(clkInputs,'Multiple')
        hdlset_param(model,'ClockInputs','Single');
        List.addItem(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_clockinput_fix'));
    end


    if strcmpi(triggerAsClk,'on')
        hdlset_param(model,'TriggerAsClock','off');
        List.addItem(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_triggerasclock_fix'));

    end

    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_modified_fix')),List];
end
