function schema=getContentOptionsSchema(dlgsrc,name)%#ok<INUSD>







    tag_prefix='sdd_';









    chkIncludeDetails.Type='checkbox';
    chkIncludeDetails.Name=dlgsrc.xlate('SDDWidgetLblIncludeDetails');
    chkIncludeDetails.RowSpan=[1,1];
    chkIncludeDetails.ColSpan=[1,1];
    chkIncludeDetails.ObjectProperty='includeDetails';
    chkIncludeDetails.Tag=[tag_prefix,'IncludeDetails'];
    chkIncludeDetails.ToolTip=dlgsrc.xlate('SDDWidgetTipIncludeDetails');


    chkIncludeModelRefs.Type='checkbox';
    chkIncludeModelRefs.Name=dlgsrc.xlate('SDDWidgetLblIncludeModelRefs');
    chkIncludeModelRefs.RowSpan=[1,1];
    chkIncludeModelRefs.ColSpan=[2,2];
    chkIncludeModelRefs.ObjectProperty='includeModelRefs';
    chkIncludeModelRefs.Tag=[tag_prefix,'IncludeModelrefs'];
    chkIncludeModelRefs.ToolTip=dlgsrc.xlate('SDDWidgetTipIncludeModelRefs');


    chkIncludeCustomLibraries.Type='checkbox';
    chkIncludeCustomLibraries.Name=dlgsrc.xlate('SDDWidgetLblIncludeCustomLibraries');
    chkIncludeCustomLibraries.RowSpan=[2,2];
    chkIncludeCustomLibraries.ColSpan=[1,1];
    chkIncludeCustomLibraries.ObjectProperty='includeCustomLibraries';
    chkIncludeCustomLibraries.Tag=[tag_prefix,'IncludeCustomLibraries'];
    chkIncludeCustomLibraries.ToolTip=dlgsrc.xlate('SDDWidgetTipIncludeCustomLibraries');



    slVnVInstalled=StdRpt.SDD.isSLVNVInstalled();

    if slVnVInstalled
        chkIncludeRequirementsLinks.Type='checkbox';
        chkIncludeRequirementsLinks.Name=...
        dlgsrc.xlate('SDDWidgetLblIncludeRequirementsLinks');
        chkIncludeRequirementsLinks.RowSpan=[2,2];
        chkIncludeRequirementsLinks.ColSpan=[2,2];
        chkIncludeRequirementsLinks.ObjectProperty='includeRequirementsLinks';
        chkIncludeRequirementsLinks.Tag=[tag_prefix,'IncludeRequirementsLinks'];
        chkIncludeRequirementsLinks.ToolTip=...
        dlgsrc.xlate('SDDWidgetTipIncludeRequirementsLinks');
    end



    chkIncludeGlossary.Type='checkbox';
    chkIncludeGlossary.Name=dlgsrc.xlate('SDDWidgetLblIncludeGlossary');
    if slVnVInstalled
        chkIncludeGlossary.RowSpan=[3,3];
        chkIncludeGlossary.ColSpan=[1,1];
    else
        chkIncludeGlossary.RowSpan=[2,2];
        chkIncludeGlossary.ColSpan=[2,2];
    end
    chkIncludeGlossary.ObjectProperty='includeGlossary';
    chkIncludeGlossary.Tag=[tag_prefix,'IncludeGlossary'];
    chkIncludeGlossary.ToolTip=dlgsrc.xlate('SDDWidgetTipIncludeGlossary');


    grpContentOptions.Type='group';
    grpContentOptions.Name=dlgsrc.xlate('SDDWidgetLblRptContentOptions');
    if slVnVInstalled
        grpContentOptions.LayoutGrid=[3,2];
    else
        grpContentOptions.LayoutGrid=[2,2];
    end

    items={
    chkIncludeDetails,...
    chkIncludeModelRefs,...
    chkIncludeCustomLibraries,...
    chkIncludeGlossary};

    if StdRpt.SDD.isSLVNVInstalled()
        items=[items,chkIncludeRequirementsLinks];
    end

    grpContentOptions.Items=items;
    grpContentOptions.Name=dlgsrc.xlate('SDDWidgetLblRptContentOptions');
    grpContentOptions.LayoutGrid=[2,2];

    pnlContentOptions.Type='panel';
    pnlContentOptions.Tag=[tag_prefix,'ContentOptionsPanel'];
    pnlContentOptions.Items={grpContentOptions};


    schema=pnlContentOptions;

end
