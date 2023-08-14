function ResultDescription=fixmeGenericChecks(mdlTaskObj)





    checker=hdlcoder.ModelChecker.getModelChecker(mdlTaskObj,'runGenericChecks');
    model=checker.m_sys;


    hdlset_param(model,'MaskParameterAsGeneric','off');
    ResultDescription=ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_generic_fix'));
end
