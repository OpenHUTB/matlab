function WidgetGroup=getOutputTypesWidgets(this)





    OutputDataTypeTxt.Name=this.getCatalogMsgStr('OutputDataTypeTable_Text');
    OutputDataTypeTxt.Type='text';
    OutputDataTypeTxt.Tag='edaOutputDataTypeTxt';
    OutputDataTypeTxt.RowSpan=[1,1];
    OutputDataTypeTxt.ColSpan=[1,1];


    OutputDataTypeTbl.Tag='edaOutputDataTypeTable';
    OutputDataTypeTbl.Type='table';
    OutputDataTypeTbl.RowSpan=[2,10];
    OutputDataTypeTbl.ColSpan=[1,10];
    OutputDataTypeTbl.Size=size(this.OutputDataTypeTableData);
    OutputDataTypeTbl.Data=this.OutputDataTypeTableData;
    OutputDataTypeTbl.HeaderVisibility=[0,1];
    OutputDataTypeTbl.ColHeader={this.getCatalogMsgStr('OutputName_ColHeader'),...
    this.getCatalogMsgStr('OutputWidth_ColHeader'),...
    this.getCatalogMsgStr('OutputType_ColHeader'),...
    this.getCatalogMsgStr('OutputSign_ColHeader'),...
    this.getCatalogMsgStr('OutputFrac_ColHeader')};
    OutputDataTypeTbl.RowHeader={};
    OutputDataTypeTbl.ColumnHeaderHeight=2;
    OutputDataTypeTbl.ColumnCharacterWidth=[30,7,14,12,10];
    OutputDataTypeTbl.Enabled=true;
    OutputDataTypeTbl.Editable=true;
    OutputDataTypeTbl.Mode=1;
    OutputDataTypeTbl.FontFamily='Courier';
    OutputDataTypeTbl.ValueChangedCallback=@l_tableValueChangeCb;
    OutputDataTypeTbl.ReadOnlyColumns=[0,1];


    WidgetGroup=this.getWidgetGroup;
    WidgetGroup.Tag='edaWidgetGroupOutputTypes';
    WidgetGroup.LayoutGrid=[10,10];
    WidgetGroup.RowStretch=ones(1,10);
    WidgetGroup.ColStretch=ones(1,10);
    WidgetGroup.Items={OutputDataTypeTxt,OutputDataTypeTbl};


end

function l_tableValueChangeCb(dlg,row,col,value)
    src=dlg.getSource;
    if src.IsInHDLWA
        this=Advisor.Utils.convertMCOS(dlg.getSource);
    else
        this=src;
    end


    SignCombo.Type='combobox';
    SignCombo.Entries={'Unsigned','Signed'};
    SignCombo.Value=0;
    SignCombo.Enabled=true;

    SignEmpty.Type='edit';
    SignEmpty.Value=' ';
    SignEmpty.Enabled=false;


    switch(col)
    case{2}
        this.OutputDataTypeTableData{row+1,3}.Value=value;
        switch this.OutputDataTypeTableData{row+1,3}.Entries{value+1}
        case{'Logical','Boolean','Inherit','Single','Double'}
            this.OutputDataTypeTableData{row+1,4}=SignEmpty;
            this.OutputDataTypeTableData{row+1,5}.Enabled=false;
            this.OutputDataTypeTableData{row+1,5}.Value=' ';
        case{'Integer'}
            if~strcmp(this.OutputDataTypeTableData{row+1,4}.Type,'combobox')
                this.OutputDataTypeTableData{row+1,4}=SignCombo;
            end
            this.OutputDataTypeTableData{row+1,5}.Enabled=false;
            this.OutputDataTypeTableData{row+1,5}.Value=' ';
        otherwise
            if~strcmp(this.OutputDataTypeTableData{row+1,4}.Type,'combobox')
                this.OutputDataTypeTableData{row+1,4}=SignCombo;
            end
            this.OutputDataTypeTableData{row+1,5}.Enabled=true;
            this.OutputDataTypeTableData{row+1,5}.Value='0';
        end
    case{3}
        this.OutputDataTypeTableData{row+1,4}.Value=value;
    case{4}
        this.OutputDataTypeTableData{row+1,5}.Value=value;
    end

    dlg.refresh;

end

