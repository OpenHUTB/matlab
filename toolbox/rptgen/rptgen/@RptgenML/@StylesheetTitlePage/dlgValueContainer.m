function dlgStruct=dlgValueContainer(this,varargin)




    tag_prefix=sprintf('TitlePage%s_',getTitlePageSideName(this));

    if isLibrary(this)

        globalEnable=0;
    else

        globalEnable=1;
    end


    [loGridColsW,loGridColsL]=dlgWidget(this,'LOGridCols',...
    'ToolTip',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridNColsToolTip')),...
    'DialogRefresh',true,...
    'RowSpan',[1,1],...
    'ColSpan',[2,2]);


    [loGridRowsW,loGridRowsL]=dlgWidget(this,'LOGridRows',...
    'ToolTip',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridNRowsToolTip')),...
    'DialogRefresh',true,...
    'RowSpan',[2,2],...
    'ColSpan',[2,2]);


    wLOGridWidthType=dlgWidget(this,'LOGridWidthType',...
    'ToolTip',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridWidthTypeToolTip')),...
    'DialogRefresh',true,...
    'RowSpan',[1,1],...
    'ColSpan',[3,3]);


    loGridWidthW=dlgWidget(this,'LOGridWidth',...
    'ToolTip',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridWidthToolTip')),...
    'Enabled',strcmp(this.LOGridWidthType,'specify'),...
    'RowSpan',[1,1],...
    'ColSpan',[4,4]);

    eUnits=RptgenML.enumTypographicUnits;


    wLOGridWidthUnit.Type='combobox';
    wLOGridWidthUnit.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridWidthUnitToolTip'));
    wLOGridWidthUnit.ObjectProperty='LOGridWidthUnit';
    wLOGridWidthUnit.Entries=eUnits.DisplayNames';
    wLOGridWidthUnit.Values=0:length(wLOGridWidthUnit.Entries)-1;
    wLOGridWidthUnit.Enabled=strcmp(this.LOGridWidthType,'specify');
    wLOGridWidthUnit.RowSpan=[1,1];
    wLOGridWidthUnit.ColSpan=[5,6];


    wLOGridHeightType=dlgWidget(this,'LOGridHeightType',...
    'ToolTip',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridHeightTypeToolTip')),...
    'DialogRefresh',true,...
    'RowSpan',[2,2],...
    'ColSpan',[3,3]);


    loGridHeightW=dlgWidget(this,'LOGridHeight',...
    'ToolTip',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridHeightToolTip')),...
    'Enabled',strcmp(this.LOGridHeightType,'specify'),...
    'RowSpan',[2,2],...
    'ColSpan',[4,4]);


    wLOGridHeightUnit.Type='combobox';
    wLOGridHeightUnit.ObjectProperty='LOGridHeightUnit';
    wLOGridHeightUnit.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridHeightUnitToolTip'));
    wLOGridHeightUnit.Entries=eUnits.DisplayNames';
    wLOGridHeightUnit.Values=0:length(wLOGridWidthUnit.Entries)-1;
    wLOGridHeightUnit.Enabled=strcmp(this.LOGridHeightType,'specify');
    wLOGridHeightUnit.RowSpan=[2,2];
    wLOGridHeightUnit.ColSpan=[5,6];


    loGridShowW=dlgWidget(this,'ShowGrid',...
    'ToolTip',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridShowGridToolTip')),...
    'RowSpan',[3,3],...
    'ColSpan',[1,3]);

    gridGroup=this.dlgContainer({
    loGridColsL,...
    loGridColsW,...
    loGridRowsL,...
    loGridRowsW,...
    wLOGridWidthType,...
    loGridWidthW,...
    wLOGridWidthUnit,...
    wLOGridHeightType,...
    loGridHeightW,...
    wLOGridHeightUnit,...
loGridShowW
    },getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridGroupLabel')),...
    'ToolTip',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridGroupToolTip')),...
    'LayoutGrid',[6,6],...
    'ColStretch',[0,0,0,0,0,1],...
    'RowStretch',[0,0,0,0,0,1],...
    'RowSpan',[1,1],...
    'ColSpan',[1,3]);


    wExcludeButton.Type='pushbutton';
    wExcludeButton.Tag=[tag_prefix,'ExcludeButton'];
    wExcludeButton.Enabled=(length(this.IncludedElementDisplayNames)>1);
    wExcludeButton.FilePath=fullfile(matlabroot,'toolbox/rptgen/resources/move_right.png');
    wExcludeButton.MatlabMethod='dlgExcludeElementButtonAction';
    wExcludeButton.MatlabArgs={'%source','%dialog'};
    wExcludeButton.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:ExcludeButtonToolTip'));
    wExcludeButton.ColSpan=[2,2];
    wExcludeButton.RowSpan=[2,2];

    wIncludeButton.Type='pushbutton';
    wIncludeButton.Tag=[tag_prefix,'IncludeButton'];
    wIncludeButton.Enabled=~isempty(this.ExcludedElementDisplayNames);
    wIncludeButton.FilePath=fullfile(matlabroot,'toolbox/rptgen/resources/move_left.png');
    wIncludeButton.MatlabMethod='dlgIncludeElementButtonAction';
    wIncludeButton.MatlabArgs={'%source'};
    wIncludeButton.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:IncludeButtonToolTip'));
    wIncludeButton.ColSpan=[2,2];
    wIncludeButton.RowSpan=[3,3];

    lIncludedElementList.Type='text';
    lIncludedElementList.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:IncludeListLabel'));
    lIncludedElementList.ColSpan=[1,1];
    lIncludedElementList.RowSpan=[1,1];

    wIncludedElementList.Type='listbox';
    wIncludedElementList.Tag=[tag_prefix,'IncludedElements'];
    wIncludedElementList.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:IncludeListToolTip'));
    wIncludedElementList.MultiSelect=false;
    wIncludedElementList.Entries=this.IncludedElementDisplayNames';
    wIncludedElementList.Value=this.CurrIncludeElementIdx;
    wIncludedElementList.MatlabMethod='dlgSelectElementIncludeListItemAction';
    wIncludedElementList.MatlabArgs={'%source','%dialog','%value'};
    wIncludedElementList.ColSpan=[1,1];
    wIncludedElementList.RowSpan=[2,6];


    lExcludedElementList.Type='text';
    lExcludedElementList.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:ExcludeListLabel'));
    lExcludedElementList.ColSpan=[3,3];
    lExcludedElementList.RowSpan=[1,1];

    wExcludedElementList.Type='listbox';
    wExcludedElementList.Tag=[tag_prefix,'ExcludedElements'];
    wExcludedElementList.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:ExcludeListToolTip'));
    wExcludedElementList.MultiSelect=false;
    wExcludedElementList.Entries=this.ExcludedElementDisplayNames';
    wExcludedElementList.MatlabMethod='dlgSelectElementExcludeListItemAction';
    wExcludedElementList.MatlabArgs={'%source','%value'};
    wExcludedElementList.Value=this.CurrExcludeElementIdx;
    wExcludedElementList.ColSpan=[3,3];
    wExcludedElementList.RowSpan=[2,6];

    contentGroup.Type='group';
    contentGroup.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:PageContentGroupLabel'));
    contentGroup.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:PageContentGroupToolTip'));
    contentGroup.LayoutGrid=[6,3];
    contentGroup.ColStretch=[1,0,1];
    contentGroup.RowStretch=[0,0,0,0,0,1];
    contentGroup.RowSpan=[2,2];
    contentGroup.ColSpan=[1,3];
    contentGroup.Items={
    wIncludeButton,...
    wExcludeButton,...
    lIncludedElementList,...
    wIncludedElementList,...
    lExcludedElementList,...
wExcludedElementList
    };

    currElem=this.Format.getIncludeElement(this.IncludedElementNames(this.CurrIncludeElementIdx+1));
    elementName=char(this.IncludedElementDisplayNames(this.CurrIncludeElementIdx+1));

    lElementLORow.Type='text';
    lElementLORow.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemLORowNumberLabel'));
    lElementLORow.RowSpan=[2,2];
    lElementLORow.ColSpan=[1,1];

    wElementLORow.Type='combobox';
    wElementLORow.Tag='RowNum';
    wElementLORow.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemLORowNumberToolTip',...
    elementName));
    wElementLORow.Entries=cellstr(num2str((1:this.Format.LayoutGrid.NumberOfRows)'));
    wElementLORow.MatlabMethod='dlgSetSrcProp';
    wElementLORow.MatlabArgs={'%source','%tag','%value'};
    wElementLORow.Value=currElem.RowNum-1;
    wElementLORow.RowSpan=[2,2];
    wElementLORow.ColSpan=[2,2];

    lElementLORowSpan.Type='text';
    lElementLORowSpan.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemLORowSpanLabel'));
    lElementLORowSpan.RowSpan=[2,2];
    lElementLORowSpan.ColSpan=[3,3];

    wElementLORowSpan.Type='edit';
    wElementLORowSpan.Tag='RowSpan';
    wElementLORowSpan.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemLORowSpanToolTip',...
    elementName));
    wElementLORowSpan.MatlabMethod='dlgSetSrcProp';
    wElementLORowSpan.MatlabArgs={'%source','%tag','%value'};
    wElementLORowSpan.Value=currElem.RowSpan;
    wElementLORowSpan.RowSpan=[2,2];
    wElementLORowSpan.ColSpan=[4,4];

    lElementLOCol.Type='text';
    lElementLOCol.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemLOColNumberLabel'));
    lElementLOCol.RowSpan=[3,3];
    lElementLOCol.ColSpan=[1,1];

    wElementLOCol.Type='combobox';
    wElementLOCol.Tag='ColNum';
    wElementLOCol.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemLOColNumberToolTip',...
    elementName));
    wElementLOCol.Entries=cellstr(num2str((1:this.Format.LayoutGrid.NumberOfColumns)'));
    wElementLOCol.MatlabMethod='dlgSetSrcProp';
    wElementLOCol.MatlabArgs={'%source','%tag','%value'};
    wElementLOCol.Value=currElem.ColNum-1;
    wElementLOCol.RowSpan=[3,3];
    wElementLOCol.ColSpan=[2,2];

    lElementLOColSpan.Type='text';
    lElementLOColSpan.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemLOColSpanLabel'));
    lElementLOColSpan.RowSpan=[3,3];
    lElementLOColSpan.ColSpan=[3,3];

    wElementLOColSpan.Type='edit';
    wElementLOColSpan.Tag='ColSpan';
    wElementLOColSpan.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemLOColSpanToolTip',...
    elementName));
    wElementLOColSpan.MatlabMethod='dlgSetSrcProp';
    wElementLOColSpan.MatlabArgs={'%source','%tag','%value'};
    wElementLOColSpan.Value=currElem.ColSpan;
    wElementLOColSpan.RowSpan=[3,3];
    wElementLOColSpan.ColSpan=[4,4];

    layoutGroup.Type='group';
    layoutGroup.Tag=[tag_prefix,'LayoutGroup'];
    layoutGroup.Enabled=~isempty(this.IncludedElementNames);
    layoutGroup.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemLOGroupLabel',...
    elementName));
    layoutGroup.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemLOGroupToolTip',...
    elementName));
    layoutGroup.LayoutGrid=[6,5];
    layoutGroup.RowStretch=[0,0,0,0,0,1];
    layoutGroup.ColStretch=[0,0,0,0,1];
    layoutGroup.RowSpan=[3,3];
    layoutGroup.ColSpan=[1,3];
    layoutGroup.Items={
    lElementLORow,...
    wElementLORow,...
    lElementLORowSpan,...
    wElementLORowSpan,...
    lElementLOCol,...
    wElementLOCol,...
    lElementLOColSpan,...
wElementLOColSpan
    };

    currElemIsText=isa(currElem,'Rptgen.TitlePage.ElementFormat');


    [wFontSize,lFontSize]=dlgWidget(this,'CurrElemFontSize',...
    'Tag','FontSize',...
    'ObjectProperty','',...
    'ToolTip',getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemFormatFontSizeToolTip',...
    elementName)),...
    'MatlabMethod','dlgSetSrcProp',...
    'MatlabArgs',{'%source','%tag','%value'},...
    'RowSpan',[1,1],...
    'ColSpan',[2,2]);

    if currElemIsText
        wFontSize.Value=currElem.FontSize;
    end



    eColors=RptgenML.enumColors;

    lTextColor.Type='text';
    lTextColor.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemFormatColorLabel'));
    lTextColor.RowSpan=[2,2];
    lTextColor.ColSpan=[1,1];

    wTextColor.Type='combobox';
    wTextColor.Tag='Color';
    wTextColor.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemFormatColorToolTip',...
    elementName));
    wTextColor.MatlabMethod='dlgSetSrcProp';
    wTextColor.MatlabArgs={'%source','%tag','%value'};
    wTextColor.Editable=true;
    wTextColor.Entries=eColors.DisplayNames';
    wTextColor.Values=0:length(eColors.DisplayNames)-1;
    wTextColor.RowSpan=[2,2];
    wTextColor.ColSpan=[2,2];

    if currElemIsText
        color=eColors.findDisplayName(currElem.Color);
        if isempty(color)
            color=currElem.Color;
        end
        wTextColor.Value=color;
    end


    wTextIsBold=dlgWidget(this,'CurrElemIsBold',...
    'Tag','IsBold',...
    'ObjectProperty','',...
    'ToolTip',getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemFormatBoldToolTip',...
    elementName)),...
    'MatlabMethod','dlgSetSrcProp',...
    'MatlabArgs',{'%source','%tag','%value'},...
    'RowSpan',[1,1],...
    'ColSpan',[3,3]);

    if currElemIsText
        wTextIsBold.Value=currElem.IsBold;
    end


    wTextIsItalic=dlgWidget(this,'CurrElemIsItalic',...
    'Tag','IsItalic',...
    'ObjectProperty','',...
    'ToolTip',getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemFormatItalicToolTip',...
    elementName)),...
    'MatlabMethod','dlgSetSrcProp',...
    'MatlabArgs',{'%source','%tag','%value'},...
    'RowSpan',[1,1],...
    'ColSpan',[4,4]);

    if currElemIsText
        wTextIsItalic.Value=currElem.IsItalic;
    end

    eHorizAlign=RptgenML.enumHorizAlign;

    lElementLOHAlign.Type='text';
    lElementLOHAlign.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemFormatAlignLabel'));
    lElementLOHAlign.RowSpan=[2,2];
    lElementLOHAlign.ColSpan=[3,3];

    wElementLOHAlign.Type='combobox';
    wElementLOHAlign.Tag='HAlign';
    wElementLOHAlign.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemFormatAlignToolTip',...
    elementName));
    wElementLOHAlign.MatlabMethod='dlgSetSrcProp';
    wElementLOHAlign.MatlabArgs={'%source','%tag','%value'};
    wElementLOHAlign.Entries=eHorizAlign.DisplayNames';
    wElementLOHAlign.Values=0:length(eHorizAlign.DisplayNames)-1;
    wElementLOHAlign.RowSpan=[2,2];
    wElementLOHAlign.ColSpan=[4,4];

    if currElemIsText
        wElementLOHAlign.Value=eHorizAlign.findDisplayName(currElem.HAlign);
    end

    formatGroup.Type='group';
    formatGroup.Tag=[tag_prefix,'FormatGroup'];
    formatGroup.Enabled=~isempty(this.IncludedElementNames)&&currElemIsText;
    formatGroup.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemFormatGroupLabel',...
    elementName));
    formatGroup.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemFormatGroupToolTip',...
    elementName));
    formatGroup.LayoutGrid=[3,5];
    formatGroup.RowStretch=[0,0,1];
    formatGroup.ColStretch=[0,0,0,0,1];
    formatGroup.RowSpan=[4,4];
    formatGroup.ColSpan=[1,3];
    formatGroup.Items={
    lFontSize,...
    wFontSize,...
    lTextColor,...
    wTextColor,...
    wTextIsBold,...
    wTextIsItalic,...
    lElementLOHAlign,...
wElementLOHAlign
    };

    lElemXPath.Type='text';
    lElemXPath.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:XPathLabel'));
    lElemXPath.RowSpan=[1,1];
    lElemXPath.ColSpan=[1,1];

    wElemXPathType.Type='combobox';
    wElemXPathType.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:XPathTypeToolTip',...
    elementName));
    wElemXPathType.Entries={getString(message('rptgen:RptgenML_StylesheetTitlePage:enumDefaultLabel')),...
    getString(message('rptgen:RptgenML_StylesheetTitlePage:enumCustomLabel'))};
    wElemXPathType.Values=[0,1];
    wElemXPathType.Value=cast(~isempty(currElem.XPath),'double');
    wElemXPathType.MatlabMethod='dlgSetElemXPath';
    wElemXPathType.MatlabArgs={'%source','%value','%dialog'};
    wElemXPathType.RowSpan=[1,1];
    wElemXPathType.ColSpan=[2,2];

    wElemXPath.Type='edit';
    wElemXPath.Tag='XPath';
    wElemXPath.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:XPathToolTip',...
    elementName));
    wElemXPath.Visible=~isempty(currElem.XPath);
    wElemXPath.MatlabMethod='dlgSetSrcProp';
    wElemXPath.MatlabArgs={'%source','%tag','%value'};
    wElemXPath.Value=currElem.XPath;
    wElemXPath.RowSpan=[1,1];
    wElemXPath.ColSpan=[3,5];


    lElemXForm.Type='text';
    lElemXForm.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:XFormLabel'));
    lElemXForm.RowSpan=[2,2];
    lElemXForm.ColSpan=[1,1];

    wElemXFormType.Type='combobox';
    wElemXFormType.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:XFormTypeToolTip',...
    elementName));
    wElemXFormType.Entries=wElemXPathType.Entries;
    wElemXFormType.Values=[0,1];
    wElemXFormType.Value=cast(~isempty(currElem.XForm),'double');
    wElemXFormType.MatlabMethod='dlgSetElemXForm';
    wElemXFormType.MatlabArgs={'%source','%value','%dialog'};
    wElemXFormType.RowSpan=[2,2];
    wElemXFormType.ColSpan=[2,2];

    wElemXForm.Type='editarea';
    wElemXForm.Tag='XForm';
    wElemXForm.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:XFormToolTip',...
    elementName));
    wElemXForm.Visible=~isempty(currElem.XForm);
    wElemXForm.MatlabMethod='dlgSetSrcProp';
    wElemXForm.MatlabArgs={'%source','%tag','%value'};
    wElemXForm.Value=currElem.XForm;
    wElemXForm.RowSpan=[3,3];
    wElemXForm.ColSpan=[1,5];

    xFormGroup.Type='group';
    xFormGroup.Tag=[tag_prefix,'FormatGroup'];
    xFormGroup.Name=getString(message('rptgen:RptgenML_StylesheetTitlePage:XFormGroupLabel',...
    elementName));
    xFormGroup.ToolTip=getString(message('rptgen:RptgenML_StylesheetTitlePage:XFormGroupToolTip',...
    elementName));
    xFormGroup.LayoutGrid=[4,5];
    xFormGroup.RowStretch=[0,0,0,1];
    xFormGroup.ColStretch=[0,0,0,0,1];
    xFormGroup.RowSpan=[5,5];
    xFormGroup.ColSpan=[1,1];
    xFormGroup.Items={
    lElemXPath,...
    wElemXPathType,...
    wElemXPath,...
    lElemXForm,...
    wElemXFormType,...
    wElemXForm,...
    };

    valueGroup.Type='group';
    valueGroup.Name=getString(message('rptgen:RptgenML_StylesheetElementID:valueLabel'));
    valueGroup.Enabled=globalEnable;
    valueGroup.LayoutGrid=[6,1];
    valueGroup.RowStretch=[0,0,0,0,0,1];

    valueGroup.Items={
    gridGroup,...
    contentGroup,...
    layoutGroup,...
    formatGroup,...
xFormGroup
    };

    dlgStruct=valueGroup;


end

