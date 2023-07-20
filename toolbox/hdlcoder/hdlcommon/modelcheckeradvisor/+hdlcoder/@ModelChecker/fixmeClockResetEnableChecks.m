function ResultDescription=fixmeClockResetEnableChecks(mdlTaskObj)





    checker=hdlcoder.ModelChecker.getModelChecker(mdlTaskObj,'runClockResetEnableChecks');
    model=checker.m_sys;
    List=ModelAdvisor.List;
    List.setType('bulleted');

    clkName=hdlget_param(model,'ClockInputPort');
    rstName=hdlget_param(model,'ResetInputPort');
    clkenName=hdlget_param(model,'ClockEnableInputPort');


    if~contains(lower(clkName),{'clk','ck'})
        hdlset_param(model,'ClockInputPort','clk');
        item=DAStudio.message('HDLShared:hdlmodelchecker:desc_Config_Param_link',model,'ClockInputPort','Clock signal');
        List.addItem(item);
    end


    if~contains(lower(rstName),{'rstx','resetx','rst_x','reset_x','reset_n','RST_N'})
        hdlset_param(model,'ResetInputPort','reset_x');
        item=DAStudio.message('HDLShared:hdlmodelchecker:desc_Config_Param_link',model,'ResetInputPort','Reset signal');
        List.addItem(item);
    end


    if~contains(lower(clkenName),'en')
        hdlset_param(model,'ClockEnableInputPort','clk_enable');
        item=DAStudio.message('HDLShared:hdlmodelchecker:desc_Config_Param_link',model,'ClockEnableInputPort','Clock enable signal');
        List.addItem(item);
    end

    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_clock_reset_enable_fix')),List];
end
