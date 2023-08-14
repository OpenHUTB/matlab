function layout=makeFitGridLayout(container,nRows,nCols)





    layout=uigridlayout(container);
    layout.RowHeight=repmat("fit",1,nRows);
    layout.ColumnWidth=repmat("fit",1,nCols);

end
