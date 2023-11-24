function handleInvalidDiskLoggerFileName(this)


    javaPeer=java(this.javaPeer);
    formatNodePanel=javaPeer.getFormatNodePanel();
    formatNodePanel.selectLoggingTab();
    formatNodePanel.setInvalidFilenameSpecified(true);
    formatNodePanel.setFocusInFileNameField();
