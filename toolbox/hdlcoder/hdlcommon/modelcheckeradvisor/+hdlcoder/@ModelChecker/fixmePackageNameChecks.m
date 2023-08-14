function ResultDescription=fixmePackageNameChecks(mdlTaskObj)






    checker=hdlcoder.ModelChecker.getModelChecker(mdlTaskObj,'runPackageNameChecks');
    model=checker.m_sys;


    hdlset_param(model,'packagePostfix','_pac');
    ResultDescription=ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_package_name_fix'));
end
