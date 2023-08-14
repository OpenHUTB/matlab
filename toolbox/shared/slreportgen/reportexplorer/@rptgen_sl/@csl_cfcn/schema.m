function schema





    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_cfcn',pkgRG.findclass('rptcomponent'));


    rptgen.makeStaticMethods(h,{},{});







    rptgen.prop(h,'includeFcnProps','bool',true,getString(message('RptgenSL:csl_cfcn:includeFcnProps')));




    rptgen.prop(h,'FcnPropsTableTitleType',{
    'none',getString(message('rptgen:r_rpt_auto_table:noTitleLabel'))
    'auto',getString(message('RptgenSL:csl_cfcn:tblTitleType_auto'))
    'manual',[getString(message('rptgen:r_rpt_auto_table:customLabel')),':']
    },'auto',getString(message('RptgenSL:csl_cfcn:tblTitleLabel')));

    rptgen.prop(h,'FcnPropsTableTitle',rptgen.makeStringType,getString(message('RptgenSL:csl_cfcn:defaultFunctionPropTableTitle')));



    rptgen.prop(h,'FcnPropsHeaderType',{
    'none',getString(message('rptgen:r_rpt_auto_table:noHeaderLabel'))
    'typename',getString(message('rptgen:r_rpt_auto_table:typenameLabel'))
    'manual',[getString(message('rptgen:r_rpt_auto_table:customLabel')),':']
    },'none',getString(message('rptgen:r_rpt_auto_table:headerRowLabel')));

    rptgen.prop(h,'FcnPropsHeaderColumn1','ustring',getString(message('rptgen:r_rpt_auto_table:nameLabel')),'');
    rptgen.prop(h,'FcnPropsHeaderColumn2','ustring',getString(message('rptgen:r_rpt_auto_table:valueLabel')),'');


    rptgen.prop(h,'FcnPropsPropListMode',{
    'auto',getString(message('RptgenSL:rsl_csl_auto_table:autoPropertiesLabel'))
    'manual',getString(message('RptgenSL:rsl_csl_auto_table:showPropertiesLabel'))
    },'auto','','SIMULINK_Report_Gen');


    rptgen.prop(h,'FcnPropsPropList','MATLAB array',{},...
    '','SIMULINK_Report_Gen');


    rptgen.prop(h,'FcnPropsShowNamePrompt','bool',true,...
    getString(message('RptgenSL:rsl_csl_auto_table:propertyNamesAsPromptsLabel')),'SIMULINK_Report_Gen');


    rptgen.prop(h,'FcnPropsRemoveEmpty','bool',true,...
    getString(message('rptgen:r_rpt_auto_table:noEmptyValuesLabel')));







    rptgen.prop(h,'includeSymbolsTable','bool',true,getString(message('RptgenSL:csl_cfcn:includeSymbolsTbl')));




    rptgen.prop(h,'SymbolsTableTitleType',{
    'auto',getString(message('RptgenSL:csl_cfcn:tblTitleType_auto'))
    'manual',[getString(message('RptgenSL:csl_cfcn:tblTitleType_manual')),':']
    },'auto',getString(message('RptgenSL:csl_cfcn:tblTitleLabel')));

    rptgen.prop(h,'SymbolsTableTitle',rptgen.makeStringType,getString(message('RptgenSL:csl_cfcn:defaultSymbolsTableTitle')));


    rptgen.prop(h,'spansPageSymbolsTable','bool',true,getString(message('RptgenSL:csl_cfcn:spansPage')));

    rptgen.prop(h,'SymbolsTableAlign',rptgen.enumTableHorizAlign,'left',...
    getString(message('RptgenSL:csl_cfcn:columnAlign')));

    rptgen.prop(h,'hasBorderSymbolsTable','bool',true,getString(message('RptgenSL:csl_cfcn:toggleGrid')));









    rptgen.prop(h,'includeOutputCode','bool',true,getString(message('RptgenSL:csl_cfcn:includeOutputCode')));







    rptgen.prop(h,'includeStartCode','bool',true,getString(message('RptgenSL:csl_cfcn:includeStartCode')));







    rptgen.prop(h,'includeInitializeConditionsCode','bool',true,getString(message('RptgenSL:csl_cfcn:includeInitConditionsCode')));








    rptgen.prop(h,'includeTerminateCode','bool',true,...
    getString(message('RptgenSL:csl_cfcn:includeTerminateCode')));
