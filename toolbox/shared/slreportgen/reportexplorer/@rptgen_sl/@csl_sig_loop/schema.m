function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_sig_loop',pkgRG.findclass('rpt_looper'));

    lic='SIMULINK_Report_Gen';


    p=rptgen.prop(h,'SortBy',{
    'alphabetical',getString(message('RptgenSL:rsl_csl_sig_loop:alpabeticallyByNameLabel'))
    'alphabetical-exclude-empty',getString(message('RptgenSL:rsl_csl_sig_loop:alphabeticallyByNonEmptyNameLabel'))
    'systemalpha',getString(message('RptgenSL:rsl_csl_sig_loop:alphabeticallyBySystemNameLabel'))
    'depth',getString(message('RptgenSL:rsl_csl_sig_loop:bySignalDepthLabel'))
    },'alphabetical',getString(message('RptgenSL:rsl_csl_sig_loop:sortSignalsLabel')),lic);


    p=rptgen.prop(h,'isBlockIncoming','bool',true,...
    getString(message('RptgenSL:rsl_csl_sig_loop:includeInputSignalsLabel')),lic);


    p=rptgen.prop(h,'isBlockOutgoing','bool',true,...
    getString(message('RptgenSL:rsl_csl_sig_loop:includeOutputSignalsLabel')),lic);


    p=rptgen.prop(h,'isSystemIncoming','bool',true,...
    getString(message('RptgenSL:rsl_csl_sig_loop:includeSystemInputSignalsLabel')),lic);


    p=rptgen.prop(h,'isSystemOutgoing','bool',true,...
    getString(message('RptgenSL:rsl_csl_sig_loop:includeSystemOutputSignalsLabel')),lic);


    p=rptgen.prop(h,'isSystemInternal','bool',true,...
    getString(message('RptgenSL:rsl_csl_sig_loop:includeSystemInternalSignalsLabel')),lic);


    rptgen.makeStaticMethods(h,{
    },{
'loop_getContextString'
'loop_getDialogSchema'
'loop_getLoopObjects'
'loop_getPropSrc'
'loop_restoreState'
'loop_saveState'
'loop_setState'
    });
