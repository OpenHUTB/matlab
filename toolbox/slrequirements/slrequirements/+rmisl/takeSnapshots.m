function reportFile=takeSnapshots()







    rptFile=fullfile(matlabroot,'toolbox','slrequirements','slrequirements','+rmisl','snapshots.rpt');
    origViewCmd=com.mathworks.toolbox.rptgencore.tools.RptgenPrefsPanel.getViewCommand('html');
    com.mathworks.toolbox.rptgencore.tools.RptgenPrefsPanel.setViewCommand('html','disp(''Successfully cached snapshots'')');
    reportOut=rptgen.report(rptFile);
    reportFile=reportOut{1};
    com.mathworks.toolbox.rptgencore.tools.RptgenPrefsPanel.setViewCommand('html',origViewCmd);
end
