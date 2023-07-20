function curContainer=initContainerItems(curContainerIn,items)







    curContainer=curContainerIn;

    curContainer.Items=items;

    [maxRow,maxCol]=getItemsMaxRowCol(items);
    curContainer.LayoutGrid=[maxRow,maxCol];
    curContainer.RowStretch=ones(1,maxRow);
    curContainer.ColStretch=ones(1,maxCol);





    function[maxRow,maxCol]=getItemsMaxRowCol(items)

        maxRow=1;
        maxCol=1;

        for i=1:length(items)

            curItem=items{i};

            maxRow=max(maxRow,max(curItem.RowSpan));

            maxCol=max(maxCol,max(curItem.ColSpan));
        end



