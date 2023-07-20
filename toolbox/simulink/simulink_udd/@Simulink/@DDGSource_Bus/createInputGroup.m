function[inputGroup]=createInputGroup(source,~)






    sigviewgroup=getDialogSchema(source.signalSelector,'');
    inputsTree.Name='Bus Hierarchy Viewer';
    inputsTree.Type='panel';
    inputsTree.Items={sigviewgroup};
    inputsTree.RowSpan=[1,4];
    inputsTree.ColSpan=[1,1];
    inputsTree.Source=source.signalSelector;

    findButton=source.createFindButton([1,1],[2,2]);

    selectButton=source.createSelectButton([2,2],[2,2]);

    refreshButton=source.createRefreshButton([3,3],[2,2]);

    inputGroup.Name='';
    inputGroup.Type='panel';
    inputGroup.Items={inputsTree,findButton,selectButton,refreshButton};
    inputGroup.LayoutGrid=[4,2];
    inputGroup.RowStretch=[0,0,0,1];
    inputGroup.RowSpan=[1,1];
    inputGroup.ColSpan=[1,1];
end

