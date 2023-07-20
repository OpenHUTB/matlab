function items=createFracLengthPanel(this,panelVisibility)








    flSchema=this.ParamBlock.(this.ParamFuncName)('FL_SCHEMA');

    labelItems=cell(1,this.NumPrecs);
    editItems=cell(1,this.NumPrecs);
    for ii=1:this.NumPrecs;
        labelItems{ii}=udtGetLeafWidgetBase('text',...
        flSchema{ii}.Name,...
        [this.MaskPropNames{ii},'Text'],...
        this.Controller);
        labelItems{ii}.Alignment=6;
        labelItems{ii}.RowSpan=[ii,ii];
        labelItems{ii}.ColSpan=[1,1];
        labelItems{ii}.Visible=panelVisibility&&flSchema{ii}.Visible;

        editItems{ii}=udtGetLeafWidgetBase('edit',...
        '',...
        this.MaskPropNames{ii},...
        this.Controller,...
        this.PropNames{ii});
        editItems{ii}.Visible=panelVisibility&&flSchema{ii}.Visible;
    end

    labelPanel=udtGetContainerWidgetBase('panel','',...
    [this.Prefix,'FracLabelPanel']);
    labelPanel.Items=labelItems;
    labelPanel.RowSpan=[1,1];
    labelPanel.ColSpan=[1,1];
    labelPanel.LayoutGrid=[this.NumPrecs,1];

    editPanel=udtGetContainerWidgetBase('panel','',...
    [this.Prefix,'FracEditPanel']);
    editPanel.Items=editItems;
    editPanel.RowSpan=[1,1];
    editPanel.ColSpan=[2,2];

    items={labelPanel,editPanel};
