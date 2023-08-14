function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_blk_bus',pkgRG.findclass('rptcomponent'));


    p=rptgen.prop(h,'isHierarchy','bool',false,...
    getString(message('RptgenSL:rsl_csl_blk_bus:showBusHierarchyLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'BusAnchor','bool',false,...
    getString(message('RptgenSL:rsl_csl_blk_bus:anchorBusBlocksLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'SignalAnchor','bool',false,...
    getString(message('RptgenSL:rsl_csl_blk_bus:anchorSignalsLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'ListTitle',rptgen.makeStringType,'',...
    getString(message('RptgenSL:rsl_csl_blk_bus:titleLabel')),'SIMULINK_Report_Gen');


    rptgen.makeStaticMethods(h,{
    },{
    });