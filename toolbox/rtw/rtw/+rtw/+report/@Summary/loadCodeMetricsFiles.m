function loadCodeMetricsFiles(obj)




    resourcesBuild={'rtwcodemetricsreport_utils.js'};

    resourceDir=Simulink.report.ReportInfo.getResourceDir;

    coder.report.ReportInfoBase.copyFiles(resourceDir,resourcesBuild,obj.ReportFolder);

    obj.Doc.addHeadItem(['<script language="JavaScript" ','type="text/javascript" src="rtwcodemetricsreport_utils.js"></script>',sprintf('\n')]);
    obj.Doc.addHeadItem(['<script language="JavaScript" ','id="metrics.js" type="text/javascript" src="metrics.js"></script>',sprintf('\n')]);

end
