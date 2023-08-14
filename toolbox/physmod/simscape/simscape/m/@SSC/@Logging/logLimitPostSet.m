function logLimitPostSet(hDialog,hSource,~,~)





    hDialog.setEnabled('SimscapeLogDataHistory',...
    SSC.Logging.isLogDataHistoryEnabled(hSource,[]));

end
