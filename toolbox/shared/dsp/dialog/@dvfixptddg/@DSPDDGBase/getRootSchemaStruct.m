function dlgStruct=getRootSchemaStruct(this,items,fixptBlurb)

















    if nargin<3
        fixptBlurb=1;
    end


    if isempty(items)

        noParamsStruct=udtGetLeafWidgetBaseID('text','dspshared:FixptDialog:noMainParameters',...
        'noMainParamsTag',0);
        items={noParamsStruct};
    end
    rows=length(items);
    for ind=1:rows
        items{ind}.RowSpan=[ind,ind];
        items{ind}.ColSpan=[1,1];
    end

    parameterPane=udtGetContainerWidgetBase('group',DAStudio.message('dspshared:FixptDialog:parameters'),...
    'parameterPane');
    parameterPane.Items=items;
    parameterPane.Tag='parameterPane';
    parameterPane.LayoutGrid=[1+rows,1];
    parameterPane.RowSpan=[1,1];
    parameterPane.RowStretch=[zeros(1,rows),1];

    generalTab.Name=DAStudio.message('dspshared:FixptDialog:main');
    generalTab.Items={parameterPane};
    dtypeTab.Name=DAStudio.message('dspshared:FixptDialog:dataTypes');
    dtypeTab.Items={this.FixptDialog.getDialogSchemaStruct(fixptBlurb)};

    tabbedPane=udtGetContainerWidgetBase('tab','','tabPane');
    tabbedPane.Tabs={generalTab,dtypeTab};
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];

    dlgStruct=this.getBaseSchemaStruct(tabbedPane,this.Block.MaskDescription);
