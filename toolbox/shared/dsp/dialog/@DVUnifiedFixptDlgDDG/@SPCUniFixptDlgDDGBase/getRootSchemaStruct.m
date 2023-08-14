function dlgStruct=getRootSchemaStruct(this,items,fixptBlurb)












    if isempty(items)

        noParamsStruct=udtGetLeafWidgetBaseID('text',...
        'dspshared:FixptDialog:noMainParameters',...
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
    parameterPane.LayoutGrid=[rows,1];
    parameterPane.RowSpan=[1,1];

    generalTab.Name=DAStudio.message('dspshared:FixptDialog:main');
    generalTab.Items={parameterPane};


    generalTab.LayoutGrid=[2,1];



    generalTab.RowStretch=[0,1];

    if nargin<3
        fixptBlurb=1;
    end
    dtypesTab.Name=DAStudio.message('dspshared:FixptDialog:dataTypes');
    dtypesTab.Items={this.SPCUniFixptDialog.getDialogSchemaStruct(fixptBlurb)};
    tabbedPane=udtGetContainerWidgetBase('tab','','tabPane');
    tabbedPane.Tabs={generalTab,dtypesTab};
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];



    dlgStruct=this.getBaseSchemaStruct(tabbedPane,this.Block.MaskDescription);


