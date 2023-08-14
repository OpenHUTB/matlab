function logTypePostSet(hDialog,hSource,~,~)




    hDialog.setEnabled('SimscapeLogName',...
    SSC.Logging.isLogNameEnabled(hSource,[]));

    hDialog.setEnabled('SimscapeLogSimulationStatistics',...
    SSC.Logging.isLogNameEnabled(hSource,[]));

    hDialog.setEnabled('SimscapeLogOpenViewer',...
    SSC.Logging.isLogNameEnabled(hSource,[]));

    hDialog.setEnabled('SimscapeLogDecimation',...
    SSC.Logging.isLogNameEnabled(hSource,[]));

    hDialog.setEnabled('SimscapeLogLimitData',...
    SSC.Logging.isLogNameEnabled(hSource,[]));

    hDialog.setEnabled('SimscapeLogDataHistory',...
    SSC.Logging.isLogDataHistoryEnabled(hSource,[]));

end
