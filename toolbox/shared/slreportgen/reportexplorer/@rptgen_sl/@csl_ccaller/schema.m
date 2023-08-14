function schema





    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_ccaller',pkgRG.findclass('rptcomponent'));


    rptgen.makeStaticMethods(h,{},{});







    rptgen.prop(h,'includeFcnProps','bool',true,getString(message('RptgenSL:csl_ccaller:includeFcnProps')));




    rptgen.prop(h,'FcnPropsTableTitleType',{
    'none',getString(message('rptgen:r_rpt_auto_table:noTitleLabel'))
    'auto',getString(message('RptgenSL:csl_ccaller:tblTitleType_auto'))
    'manual',[getString(message('rptgen:r_rpt_auto_table:customLabel')),':']
    },'auto',getString(message('RptgenSL:csl_ccaller:tblTitleLabel')));

    rptgen.prop(h,'FcnPropsTableTitle',rptgen.makeStringType,getString(message('RptgenSL:csl_ccaller:defaultFunctionPropTableTitle')));



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







    rptgen.prop(h,'includePortSpecificationTable','bool',true,getString(message('RptgenSL:csl_ccaller:includePortSpecificationTbl')));




    rptgen.prop(h,'PortSpecificationTableTitleType',{
    'auto',getString(message('RptgenSL:csl_ccaller:tblTitleType_auto'))
    'manual',[getString(message('RptgenSL:csl_ccaller:tblTitleType_manual')),':']
    },'auto',getString(message('RptgenSL:csl_ccaller:tblTitleLabel')));

    rptgen.prop(h,'PortSpecificationTableTitle',rptgen.makeStringType,getString(message('RptgenSL:csl_ccaller:defaultPortSpecificationTableTitle')));


    rptgen.prop(h,'spansPagePortSpecificationTable','bool',true,getString(message('RptgenSL:csl_ccaller:spansPage')));

    rptgen.prop(h,'PortSpecificationTableAlign',rptgen.enumTableHorizAlign,'left',...
    getString(message('RptgenSL:csl_ccaller:columnAlign')));

    rptgen.prop(h,'hasBorderPortSpecificationTable','bool',true,getString(message('RptgenSL:csl_ccaller:toggleGrid')));









    rptgen.prop(h,'includeAvailableFunctions','bool',false,getString(message('RptgenSL:csl_ccaller:includeAvailableFunctions')));

    rptgen.prop(h,'availableFunctionsListType',...
    'int32',...
    1,getString(message('RptgenSL:csl_ccaller:availableFunctionsListFormat')));







    rptgen.prop(h,'includeCode','bool',true,getString(message('RptgenSL:csl_ccaller:includeCode')));

