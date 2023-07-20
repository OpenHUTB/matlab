function schema=getContentOptionsSchema(dlgsrc,name)%#ok<INUSD>







    tag_prefix='rtw_';








    chkModelInformation.Type='checkbox';
    chkModelInformation.Name=dlgsrc.xlate('RTWWidgetLblModelInformation');
    chkModelInformation.RowSpan=[1,1];
    chkModelInformation.ColSpan=[1,3];
    chkModelInformation.ObjectProperty='modelInformation';
    chkModelInformation.Tag=[tag_prefix,'ModelInformation'];
    chkModelInformation.ToolTip=dlgsrc.xlate('RTWWidgetTipModelInformation');


    chkGeneratedCodeListings.Type='checkbox';
    chkGeneratedCodeListings.Name=...
    dlgsrc.xlate('RTWWidgetLblGeneratedCodeListings');
    chkGeneratedCodeListings.RowSpan=[2,2];
    chkGeneratedCodeListings.ColSpan=[1,3];
    chkGeneratedCodeListings.ObjectProperty='generatedCodeListings';
    chkGeneratedCodeListings.Tag=[tag_prefix,'GeneratedCodeListings'];
    chkGeneratedCodeListings.ToolTip=...
    dlgsrc.xlate('RTWWidgetTipGeneratedCodeListings');


    grpContentOptions.Type='group';
    grpContentOptions.Name=dlgsrc.xlate('RTWReportContents');
    grpContentOptions.LayoutGrid=[3,3];

    items={chkModelInformation,chkGeneratedCodeListings};

    grpContentOptions.Items=items;

    pnlContentOptions.Type='panel';
    pnlContentOptions.Tag=[tag_prefix,'OutputFormatPanel'];
    pnlContentOptions.Items={grpContentOptions};

    schema=pnlContentOptions;
end


