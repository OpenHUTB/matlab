function schema




    pkg=findpackage('rptgen_stm');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cstm_testseq',pkgRG.findclass('rptcomponent'));

    lic='SIMULINK_Report_Gen';


    rptgen.prop(h,'TitleMode',{
    'auto',getString(message('RptgenSL:rstm_cstm_testseq:useTSNameLabel'))
    'manual',...
    [getString(message('RptgenSL:rstm_cstm_testseq:customLabel')),':']
    },'auto',getString(message('RptgenSL:rstm_cstm_testseq:titleLabel')),lic);


    rptgen.prop(h,'Title',...
    rptgen.makeStringType,...
    getString(message('RptgenSL:rstm_cstm_testseq:testSeqLabel')),'',lic);


    rptgen.prop(h,'StepContent',{
    'all',getString(message('RptgenSL:rstm_cstm_testseq:includeAll'))
    'descriptionOnly',getString(message('RptgenSL:rstm_cstm_testseq:includeDescriptionOnly'))
    'actionAndTransitionOnly',getString(message('RptgenSL:rstm_cstm_testseq:includeActionAndTransitionOnly'))
    'none',getString(message('RptgenSL:rstm_cstm_testseq:includeNone'))
    },'all',getString(message('RptgenSL:rstm_cstm_testseq:stepContent')),lic);


    rptgen.prop(h,'StepRequirements',...
    'bool',false,...
    getString(message('RptgenSL:rstm_cstm_testseq:showRequirements')),lic);





    rptgen.makeStaticMethods(h,{
'findTestSeq'
    });