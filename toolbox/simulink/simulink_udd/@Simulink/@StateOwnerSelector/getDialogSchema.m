function dlgstruct=getDialogSchema(this,~)




    dlgInstruct.Name='Choose a state owner block from the hierarchy:';
    dlgInstruct.Type='text';
    dlgInstruct.Alignment=5;
    dlgInstruct.Tag='text_Instruction';
    dlgInstruct.RowSpan=[1,1];
    dlgInstruct.ColSpan=[1,1];

    hierTree.Type='tree';
    hierTree.Name=DAStudio.message('Simulink:tools:MASystemHierarchy');
    hierTree.Tag='tree_SystemHierarchy';
    hierTree.RowSpan=[2,2];
    hierTree.ColSpan=[1,1];
    hierTree.ObjectProperty='SelectedStateOwner';
    hierTree.ExpandTree=false;
    hierTree.TreeModel=this.TreeModel;
    hierTree.TreeExpandItems=this.TreeExpandItems;
    hierTree.ObjectMethod='treeCB';
    hierTree.MethodArgs={'%value'};
    hierTree.ArgDataTypes={'mxArray'};
    hierTree.DialogRefresh=true;

    dlgstruct.DialogTitle='State Owner Block Selector';
    dlgstruct.Items={dlgInstruct,hierTree};
    dlgstruct.LayoutGrid=[2,1];
    dlgstruct.RowStretch=[0,1];
    dlgstruct.ColStretch=1;

    if this.ModelHasStateOwnerBlock
        SelectButton.Name='&Select';
        SelectButton.Type='pushbutton';
        SelectButton.Tag='SelectButtonTag';
        SelectButton.WidgetId='SelectButtonId';
        SelectButton.ColSpan=[1,1];
        SelectButton.RowSpan=[1,1];
        SelectButton.ObjectMethod='selectButtonCB';
        SelectButton.MethodArgs={'%dialog'};
        SelectButton.ArgDataTypes={'handle'};
        if~isempty(this.TreeSelectedItem)
            SelectButton.Enabled=this.isValidStateOwnerBlock(get_param(this.TreeSelectedItem,'Object'));
        end

        HighlightButton.Name='&Highlight';
        HighlightButton.Type='pushbutton';
        HighlightButton.Tag='HighlightButtonTag';
        HighlightButton.WidgetId='HighlightButtonId';
        HighlightButton.ColSpan=[2,2];
        HighlightButton.RowSpan=[1,1];
        HighlightButton.ObjectMethod='highlightButtonCB';
        HighlightButton.MethodArgs={};
        HighlightButton.ArgDataTypes={};
        HighlightButton.Enabled=~strcmp(this.TreeSelectedItem,this.ModelObj.Name);

        CancelButton.Name='&Cancel';
        CancelButton.Type='pushbutton';
        CancelButton.Tag='CancelButtonTag';
        CancelButton.WidgetId='CancelButtonId';
        CancelButton.ColSpan=[3,3];
        CancelButton.RowSpan=[1,1];
        CancelButton.ObjectMethod='cancelButtonCB';
        CancelButton.MethodArgs={'%dialog'};
        CancelButton.ArgDataTypes={'handle'};

        ButtonPanel.Type='panel';
        ButtonPanel.Items={SelectButton,HighlightButton,CancelButton};
        ButtonPanel.Tag='ButtonPanelTag';
        ButtonPanel.WidgetId='ButtonPanelId';
        ButtonPanel.LayoutGrid=[1,3];

        dlgstruct.StandaloneButtonSet=ButtonPanel;
    else
        dlgstruct.StandaloneButtonSet={'Cancel'};
    end
    dlgstruct.DefaultOk=false;

    dlgstruct.Sticky=true;
end
