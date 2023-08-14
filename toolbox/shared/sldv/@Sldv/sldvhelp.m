function sldvhelp(hDlg)




    hSrc=getDialogSource(hDlg);
    index=get(hSrc,[hSrc.productTag,'ActiveTab']);

    switch index
    case 0
        topicID='designverifier_pane';
    case 1
        topicID='preprocess_pane';
    case 2
        topicID='dvparameters_pane';
    case 3
        topicID='testgeneration_pane';
    case 4
        topicID='designerrordetection_pane';
    case 5
        topicID='propertyproving_pane';
    case 6
        topicID='results_pane';
    case 7
        topicID='report_pane';
    end

    helpview(fullfile(docroot,'toolbox','sldv','sldv.map'),topicID);
