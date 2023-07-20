function dlgStruct=getDialogSchema(this,unused)%#ok<INUSD>




    dirTree.Type='tree';
    dirTree.RowSpan=[2,2];
    dirTree.ColSpan=[1,1];
    dirTree.MinimumSize=[600,300];
    dirTree.Tag='treeView';
    dirTree.TreeItems=this.treeItems;
    dirTree.ExpandTree=true;
    dirTree.MatlabMethod='dialogCB';
    dirTree.MatlabArgs={this,'select','%dialog'};
    dirTree.Mode=1;
    dirTree.ObjectProperty='selectedItem';

    dlgStruct.DialogTitle=pslinkprivate('pslinkMessage','get','pslink:GUIResDirDialogTitle');
    dlgStruct.Items={dirTree};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[1,0];
    dlgStruct.ColStretch=1;
    dlgStruct.StandaloneButtonSet={'Ok','Cancel'};

    dlgStruct.CloseMethod='closeCB';
    dlgStruct.CloseMethodArgs={'%closeaction'};
    dlgStruct.CloseMethodArgsDT={'string'};
    dlgStruct.Sticky=true;


