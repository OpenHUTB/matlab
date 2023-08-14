classdef Messages<handle






    properties(Constant,Access=public)
        unchangedMsgId='slrealtime:explorer:unchanged';
        singleWarningMsgId='slrealtime:explorer:singleWarning';
        multipleWarningsMsgId='slrealtime:explorer:multipleWarnings';
        warningsForTargetMsgId='slrealtime:explorer:warningsForTarget';
        noTargetMsgId='slrealtime:explorer:noTargetAssert';
        targetExistsMsgId='slrealtime:explorer:targetExistsAssert';
        disconnectMsgId='slrealtime:explorer:disconnect';
        disconnectingMsgId='slrealtime:explorer:disconnecting';
        disconnectingTargetComputerMsgId='slrealtime:explorer:disconnectingTargetComputer';
        connectMsgId='slrealtime:explorer:connect';
        connectingMsgId='slrealtime:explorer:connecting';
        connectingTargetComputerMsgId='slrealtime:explorer:connectingTargetComputer';
        errorMsgId='slrealtime:explorer:error';
        defaultMsgId='slrealtime:explorer:default';
        configuringMsgId='slrealtime:explorer:configuring';
        configureTargetComputerSoftwareMsgId='slrealtime:explorer:configureTargetComputerSoftware';
        configureTargetComputerSoftwarePromptMsgId='slrealtime:explorer:configureTargetComputerSoftwarePrompt';
        configureTargetComputerSoftwareConfirmMsgId='slrealtime:explorer:configureTargetComputerSoftwareConfirm';
        configureTargetComputerSoftwareUpToDateMsgId='slrealtime:target:updateUpToDate';
        configureTargetComputerSoftwareNotAliveMsgId='slrealtime:explorer:targetComputerNotAlive';
        configureTargetComputerIPAddressMsgId='slrealtime:explorer:configureTargetComputerIPAddress';
        configureTargetComputerIPAddressPromptMsgId='slrealtime:explorer:configureTargetComputerIPAddressPrompt';
        configureTargetComputerIPAddressConfirmMsgId='slrealtime:explorer:configureTargetComputerIPAddressConfirm';
        configureTargetComputerIPAddressOnlyMsgId='slrealtime:explorer:configureTargetComputerIPAddressOnly';
        configureTargetComputerIPAddressAndNetmaskMsgId='slrealtime:explorer:configureTargetComputerIPAddressAndNetmask';
        configureTargetComputerIPAddressGetValuesMsgId='slrealtime:explorer:configureTargetComputerIPAddressGetValues';
        startupMsgId='slrealtime:explorer:startup';
        rebootingMsgId='slrealtime:explorer:rebooting';
        targetComputerRebootMsgId='slrealtime:explorer:targetComputerReboot';
        targetComputerRebootPromptMsgId='slrealtime:explorer:targetComputerRebootPrompt';
        targetComputerRebootConfirmMsgId='slrealtime:explorer:targetComputerRebootConfirm';
        targetComputerRebootRequiredMsgId='slrealtime:explorer:targetComputerRebootRequired';
        targetComputerRebootNotAliveMsgId='slrealtime:explorer:targetComputerNotAlive';
        targetComputerRebootSuccessMsgId='slrealtime:explorer:targetComputerRebootSuccess';
        deleteTargetPromptMsgId='slrealtime:explorer:deleteTargetPrompt';
        deleteTargetConfirmMsgId='slrealtime:explorer:deleteTargetConfirm';
        emptyTargetNameMsgId='slrealtime:explorer:emptyTargetNameError';
        invalidFileFormatMsgID='slrealtime:explorer:invalidFileFormat';
        invalidFileContentMsgID='slrealtime:explorer:invalidFileContent';
        invalidStopTimeMsgID='slrealtime:explorer:invalidStopTime';
        slrtVersionMismatchMsgID='slrealtime:explorer:slrtVersionMismatch';
        supportPkgVersionMismatch1MsgId='slrealtime:explorer:supportPkgVersionMismatch1';
        supportPkgVersionMismatch2MsgId='slrealtime:explorer:supportPkgVersionMismatch2';
        invalidIpAddressMsgId='slrealtime:explorer:invalidIpAddress';
        invalidNetmaskMsgId='slrealtime:explorer:invalidNetmask';
        configureRunOnStartupMsgId='slrealtime:explorer:configureRunOnStartup';
        targetVersionMismatch='slrealtime:explorer:targetVersionMismatch';

        slrtExplorerTitleMsgId='slrealtime:explorer:slrtExplorer';
        targetMsgId='slrealtime:explorer:target';
        connectToTargetComputerSectionMsgId='slrealtime:explorer:connectToTargetComputer';
        prepareSectionMsgId='slrealtime:explorer:prepare';
        runOnTargetSectionMsgId='slrealtime:explorer:runOnTarget';
        reviewResultsSectionMsgId='slrealtime:explorer:reviewResults';
        connectedMsgId='slrealtime:explorer:connected';
        disconnectedMsgId='slrealtime:explorer:disconnected';
        connectToTargetMsgId='slrealtime:explorer:connectToTarget';
        startMsgId='slrealtime:explorer:start';
        stopMsgId='slrealtime:explorer:stop';
        stopTimeLabelMsgId='slrealtime:explorer:stopTime';
        sdiButtonMsgId='slrealtime:explorer:dataInspector';
        tetMonitorButtonMsgId='slrealtime:explorer:tetMonitor';
        importFileLogButtonMsgId='slrealtime:explorer:importFileLog';
        targetsTreePanelTitleMsgId='slrealtime:explorer:targetsTree';
        applicationTreePanelTitleMsgId='slrealtime:explorer:applicationTree';
        signalsTabTitleMsgId='slrealtime:explorer:signals';
        parametersTabTitleMsgId='slrealtime:explorer:parameters';
        targetConfigurationTabTitleMsgId='slrealtime:explorer:targetConfiguration';
        systemLogViewerTabTitleMsgId='slrealtime:explorer:systemLogViewer';
        loadApplicationDescriptionMsgId='slrealtime:explorer:loadApplicationDescription';
        dataInspectorDescriptionMsgId='slrealtime:explorer:dataInspectorDescription';
        tetMonitorDescriptionMsgId='slrealtime:explorer:tetMonitorDescription';
        importFileLogDescriptionMsgId='slrealtime:explorer:importFileLogDescription';
        ImportFileLogUIFigureNameMsgId='slrealtime:explorer:importFileLogUI';
        ImportFileLogPanelTitleMsgId='slrealtime:explorer:availableFileLogs';
        importFileLogTableColumnApplicationsMsgId='slrealtime:explorer:importFileLogTableApplications';
        importFileLogTableColumnStartDateMsgId='slrealtime:explorer:importFileLogTableStartDate';
        importFileLogTableColumnSizeMsgId='slrealtime:explorer:size';
        importFileLogImportButtonMsgId='slrealtime:explorer:import';
        deleteMsgId='slrealtime:explorer:delete';
        importFileLogCancelButtonMsgId='slrealtime:explorer:cancel';
        highlightInModelButtonTextMsgId='slrealtime:explorer:highlightInModel';
        parametersavailabletotuneontargetLabelTextMsgId='slrealtime:explorer:parametersAvailableToTuneOnTarget';
        tableColumnNameBlockPathMsgId='slrealtime:explorer:blockPath';
        nameMsgId='slrealtime:explorer:name';
        tableColumnNameValueMsgId='slrealtime:explorer:value';
        parametersTableColumnNameTypeMsgId='slrealtime:explorer:type';
        parametersTableColumnNameSizeMsgId='slrealtime:explorer:size';
        monitorModeButtonTextMsgId='slrealtime:explorer:viewValues';
        signalsAvailableOnTargetComputerLabelTextMsgId='slrealtime:explorer:signalsAvailableOntargetComputer';
        signalsTableColumnNameSignalNameMsgId='slrealtime:explorer:signalName';
        groupSignalstoStreamtoSDILabelTextMsgId='slrealtime:explorer:acquirelistforStreaming';
        systemLogViewerPanelTitleMsgId='slrealtime:explorer:filterBy';
        systemLogViewerMessageMsgId='slrealtime:explorer:message';
        systemLogViewerSeverityMsgId='slrealtime:explorer:severity';
        systemLogViewerUITableTimestampColumnNameMsgId='slrealtime:explorer:timestamp';
        systemLogViewerUITableCategoryColumnNameMsgId='slrealtime:explorer:category';
        updateSoftwareButtonTextMsgId='slrealtime:explorer:updateSoftware';
        updateSoftwareTooltipMsgId='slrealtime:explorer:updateSoftwareTooltip';
        changeIPAddressButtonTextMsgId='slrealtime:explorer:ChangeIPAddress';
        changeIPAddressButtonTooltipMsgId='slrealtime:explorer:changeIPAddressTooltip';
        rebootButtonTextMsgId='slrealtime:explorer:Reboot';
        rebootButtonTooltipMsgId='slrealtime:explorer:RebootTooltip';
        ipAddressEditFieldLabelTextMsgId='slrealtime:explorer:ipAddress';
        emptyTargetIpAddressErrorMsgId='slrealtime:explorer:emptyTargetIpAddressError';
        newIPAddressMsgId='slrealtime:explorer:newIPAddress';
        newNetmaskMsgId='slrealtime:explorer:newNetmask';
        duplicateTargetIpAddressErrorMsgId='slrealtime:explorer:duplicateTargetIpAddressError';
        loadingMsgId='slrealtime:explorer:loading';
        loadingApplicationOnTargetComputerMsgId='slrealtime:explorer:loadingApplicationOnTargetComputer';
        startingMsgId='slrealtime:explorer:starting';
        startingApplicationOnTargetComputerMsgId='slrealtime:explorer:startingApplicationOnTargetComputer';
        stoppingMsgId='slrealtime:explorer:stopping';
        stoppingApplicationOnTargetComputerMsgId='slrealtime:explorer:stoppingApplicationOnTargetComputer';
        targetComputersMsgId='slrealtime:explorer:targetComputers';
        filterContentsOfLabelTextMsgId='slrealtime:explorer:contentsof';
        hideValuesMsgId='slrealtime:explorer:hideValues';
        exportInstrumentMsgId='slrealtime:explorer:exportInstrument';
        importInstrumentMsgId='slrealtime:explorer:importInstrument';

    end


    methods
        function this=Messages()

        end
    end

end
