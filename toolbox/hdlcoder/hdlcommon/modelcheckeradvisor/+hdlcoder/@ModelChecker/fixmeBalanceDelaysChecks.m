function ResultDescription=fixmeBalanceDelaysChecks(mdlTaskObj)




    checker=hdlcoder.ModelChecker.getModelChecker(mdlTaskObj,'runBalanceDelaysChecks');
    model=checker.m_sys;
    List=ModelAdvisor.List;
    List.setType('bulleted');


    hdlset_param(model,'BalanceDelays','On');

    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:fix_runBalanceDelaysChecks')),List];
end
