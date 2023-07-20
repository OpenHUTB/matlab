function items=createSlopePanel(this,panelVisibility)








    slSchema=this.ParamBlock.(this.ParamFuncName)('SL_SCHEMA');

    labelItems=cell(1,this.NumPrecs);
    editItems=cell(1,this.NumPrecs);
    for ii=1:this.NumPrecs;
        labelItems{ii}=udtGetLeafWidgetBase('text',...
        slSchema{ii}.Name,...
        [this.Prefix,this.SlopeTags{ii},'Text'],...
        this.Controller);
        labelItems{ii}.Alignment=6;
        labelItems{ii}.RowSpan=[ii,ii];
        labelItems{ii}.ColSpan=[1,1];
        labelItems{ii}.Visible=panelVisibility&&slSchema{ii}.Visible;

        editItems{ii}=udtGetLeafWidgetBase('edit',...
        '',...
        [this.Prefix,this.SlopeTags{ii}],...
        this.Controller);
        editItems{ii}.Visible=panelVisibility&&slSchema{ii}.Visible;
        editItems{ii}.ObjectMethod='updateFracLengthNFromSlopeN';
        editItems{ii}.MethodArgs={'%value',this.PropNames{ii}};
        editItems{ii}.ArgDataTypes={'mxArray','string'};
        editItems{ii}.Value=this.loadSlopeNFromFracLengthN(this.PropNames{ii});
        editItems{ii}.SaveState=0;
    end

    labelPanel=udtGetContainerWidgetBase('panel','',...
    [this.Prefix,'SlopeLabelPanel']);
    labelPanel.Items=labelItems;
    labelPanel.RowSpan=[1,1];
    labelPanel.ColSpan=[1,1];
    labelPanel.LayoutGrid=[this.NumPrecs,1];

    editPanel=udtGetContainerWidgetBase('panel','',...
    [this.Prefix,'SlopeEditPanel']);
    editPanel.Items=editItems;
    editPanel.RowSpan=[1,1];
    editPanel.ColSpan=[2,2];

    items={labelPanel,editPanel};
