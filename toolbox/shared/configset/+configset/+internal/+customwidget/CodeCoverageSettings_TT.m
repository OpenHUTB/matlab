function tooltip=CodeCoverageSettings_TT(cs,~)


    if configset.internal.customwidget.isSlCovVisible(cs)
        tooltip=configset.internal.getMessage('ERTDialogCodeCoverageToolSimcoverageToolTip');
    else
        tooltip=configset.internal.getMessage('ERTDialogCodeCoverageToolToolTip');
    end
