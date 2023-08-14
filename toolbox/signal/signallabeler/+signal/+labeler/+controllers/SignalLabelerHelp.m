function SignalLabelerHelp(helpType)

    mapRoot=fullfile(docroot,'/signal/','signal.map');

    switch helpType
    case 'sigLabelerAppHelp'
        helpview(mapRoot,'labeler_app');
    case 'autoLabelModeHelp'
        helpview(mapRoot,'labeler_autoLabelMode');
    case 'dashboardModeHelp'
        helpview(mapRoot,'labeler_dashboardMode');
    case 'fastLabelModeHelp'
        helpview(mapRoot,'labeler_fastLabelMode');
    case 'featureExtractionModeHelp'
        helpview(mapRoot,'labeler_featureExtractionMode');
    case 'addLabelDefinitionHelp'
        helpview(mapRoot,'labeler_addLabelDefinition');
    case 'addSublabelDefinitionHelp'
        helpview(mapRoot,'labeler_addSublabelDefinition');
    case{'editLabelDefinitionHelp','editSublabelDefinitionHelp'}
        helpview(mapRoot,'labeler_editLabelDefinition');
    case 'deleteLabelDefinitionHelp'
        helpview(mapRoot,'labeler_deleteLabelDefinition');
    case 'importLabelDefinitionHelp'
        helpview(mapRoot,'labeler_importLabelDefinition');
    case 'exportLabelDefinitionHelp'
        helpview(mapRoot,'labeler_exportLabelDefinition');
    case 'acceptAllHelp'
        helpview(mapRoot,'labeler_acceptAllCancel');
    case 'labelSelectedSignalsHelp'
        helpview(mapRoot,'labeler_labelSelectedSignals');
    case 'fastLabelModeSignalSelectionWidgetHelp'
        helpview(mapRoot,'labeler_fastLabelSignalSelection');
    case 'updateLabelInstanceHelp'
        helpview(mapRoot,'labeler_editLabel');
    case 'commitLabelHelp'
        helpview(mapRoot,'labeler_commitLabel');
    case 'peakLabelerHelp'
        helpview(mapRoot,'labeler_labelPeaks');
    case 'customLabelerHelp'
        helpview(mapRoot,'labeler_customLabeling');
    case 'addCustomLabelerHelp'
        helpview(mapRoot,'labeler_addCustomLabeler');
    case 'editCustomLabelerDesctriptionHelp'
        helpview(mapRoot,'labeler_editCustomLabelerDescription');
    case 'manageCustomLabelerHelp'
        helpview(mapRoot,'labeler_manageCustomLabelers');
    case 'exportLSSToWSHelp'
        helpview(mapRoot,'labeler_exportLSSToWS');
    case 'exportLabelDefinitionToWSHelp'
        helpview(mapRoot,'labeler_exportLabelDefinitionToWS');
    case 'exportLSSToFileHelp'
        helpview(mapRoot,'labeler_exportLSSToFile');
    case 'importSignalsHelp'
        helpview(mapRoot,'labeler_importSignalsFromWS');
    case 'importFromFileHelp'
        helpview(mapRoot,'labeler_importFromFile');
    case 'importFromFilesInFolderHelp'
        helpview(mapRoot,'labeler_importFromFilesInFolder');
    case 'signalFrequencyFeatureExtractorHelp'
        helpview(mapRoot,'labeler_signalFrequencyFeatureExtractorHelp');
    case 'signalTimeFeatureExtractorHelp'
        helpview(mapRoot,'labeler_signalTimeFeatureExtractorHelp');
    case 'featureExtractionModeSignalSelectionWidgetHelp'
        helpview(mapRoot,'labeler_featureExtractionSignalSelectionHelp');
    case 'editFeatureDefinitionHelp'
        helpview(mapRoot,'labeler_editFeatureDefinitionHelp');
    case 'exportFeatureToWS'
        helpview(mapRoot,'labeler_exportFeatureToWS');
    case 'exportFeatureToCL'
        helpview(mapRoot,'labeler_exportFeatureToCL');

    case 'aboutSPT'
aboutsignaltbx
    otherwise
        helpview(mapRoot,'labeler_app');
    end
end
