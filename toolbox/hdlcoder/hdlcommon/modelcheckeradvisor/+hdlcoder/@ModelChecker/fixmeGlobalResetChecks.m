function ResultDescription=fixmeGlobalResetChecks(mdlTaskObj)






    checker=hdlcoder.ModelChecker.getModelChecker(mdlTaskObj,'runGlobalResetChecks');
    model=checker.m_sys;

    synthtool=hdlget_param(model,'SynthesisTool');
    isXilinxTool=any([strcmpi(synthtool,'Xilinx ISE'),strfind(synthtool,'Vivado')]);
    isAlteraTool=strcmpi(synthtool,'Altera Quartus II');

    resettype='Synchronous';
    if isXilinxTool
        hdlset_param(model,'ResetType','Synchronous');
    end

    if isAlteraTool
        hdlset_param(model,'ResetType','Asynchronous');
        resettype='Asynchronous';
    end

    ResultDescription=ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:global_reset_fix',resettype));
end
