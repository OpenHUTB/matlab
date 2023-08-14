function schema

















    pkg=findpackage('RptgenRTW');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'CCodeGenSummary',pkgRG.findclass('rpt_section'));


    p=rptgen.prop(h,'Makefile','bool',false,...
    DAStudio.message('RTW:report:makefileAndMakeCommand'));


    p=rptgen.prop(h,'Imported_files','bool',false,...
    DAStudio.message('RTW:report:importedFiles'));


    p=rptgen.prop(h,'Subsystem','bool',true,...
    DAStudio.message('RTW:report:subsystemMap'));



    p=rptgen.prop(h,'Configuration_settings','bool',true,...
    DAStudio.message('RTW:report:configurationSettings'));


    p=rptgen.prop(h,'General_information','bool',true,...
    DAStudio.message('RTW:report:generalInformation'));


    p=rptgen.prop(h,'Use_setting_from_model','bool',true,...
    DAStudio.message('RTW:report:useSettingsFromModel'));


    p=rptgen.prop(h,'Eliminated_virtual_blocks','bool',true,...
    DAStudio.message('RTW:report:secEliminatedVirtualBlocks'));


    p=rptgen.prop(h,'Traceable_Simulink_blocks','bool',true,...
    DAStudio.message('RTW:report:secTraceableSimulinkBlocks'));


    p=rptgen.prop(h,'Traceable_Stateflow_objects','bool',true,...
    DAStudio.message('RTW:report:secTraceableStateflowObjects'));


    p=rptgen.prop(h,'Traceable_Embedded_MATLAB_functions','bool',true,...
    DAStudio.message('RTW:report:secTraceableEmbeddedMatlabFunctions'));


    rptgen.makeStaticMethods(h,{
    },{
    });


