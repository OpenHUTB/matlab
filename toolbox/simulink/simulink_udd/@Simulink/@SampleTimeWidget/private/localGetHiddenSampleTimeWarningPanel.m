function panel=localGetHiddenSampleTimeWarningPanel(tag,blockType)














    warning.Type='image';
    warning.Tag=[tag,'_Info_Icon'];
    warning.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','info_suggestion.png');
    warning.RowSpan=[1,1];
    warning.ColSpan=[1,1];


    if strcmp(blockType,'Constant')
        suggestion.Name=DAStudio.message('Simulink:blkprm_prompts:SampleTimeWidgetSuggestionConstant');
    else
        suggestion.Name=DAStudio.message('Simulink:blkprm_prompts:SampleTimeWidgetSuggestion');
    end
    suggestion.Type='text';
    suggestion.Italic=1;
    suggestion.Tag=[tag,'_Suggestion_Tag'];
    suggestion.RowSpan=[1,1];
    suggestion.ColSpan=[2,2];


    reason.Name=DAStudio.message('Simulink:blkprm_prompts:SampleTimeWidgetReason');
    reason.Type='hyperlink';
    reason.Tag=[tag,'_Reason_Tag'];
    reason.RowSpan=[1,1];
    reason.ColSpan=[3,3];
    reason.MatlabMethod='helpview';
    reason.MatlabArgs={[docroot,'/toolbox/simulink/helptargets.map'],'ConditionalApplicationOfTs'};

    items={warning,suggestion,reason};
    panel.Type='panel';
    panel.Tag=[tag,'_Panel_Tag'];
    panel.Items=items;
    panel.LayoutGrid=[1,3];
    panel.RowStretch=1;
    panel.ColStretch=[0,0,0];


