function[outputGroup]=createOutputGroup(source,block)





    selectionList=source.createSelectionList(block);

    outputCheckBox=source.createOutputCheckBox;

    upButton=source.createUpButton([1,1],[2,2]);

    downButton=source.createDownButton([2,2],[2,2]);

    removeButton=source.createRemoveButton([3,3],[2,2]);

    outputGroup.Name='';
    outputGroup.Type='panel';
    outputGroup.Items={selectionList,upButton,downButton,removeButton,outputCheckBox};
    outputGroup.LayoutGrid=[5,2];
    outputGroup.RowStretch=[0,0,0,1,0];
    outputGroup.RowSpan=[1,1];
    outputGroup.ColSpan=[2,2];
end

