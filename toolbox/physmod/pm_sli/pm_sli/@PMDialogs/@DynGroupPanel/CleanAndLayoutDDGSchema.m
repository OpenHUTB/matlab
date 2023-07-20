function retSchema=CleanAndLayoutDDGSchema(hThis,hNode,varargin)





















    if~isempty(varargin)&&numel(varargin)&&ischar(varargin{1})
        layoutHint=varargin{1};
    else
        layoutHint=[];
    end


    if ismac












        scaleUpCols=50;
    else
        scaleUpCols=100;
    end


    schema=lScaleColsDownToLeaves(hNode,scaleUpCols);


    retSchema=lMapAndBurstDdgContainers(schema,layoutHint);


    if iscell(retSchema)
        retSchema=[retSchema{:}];
    end
end

function schema=lScaleColsDownToLeaves(hNode,nNewCols)

    if~lIsContainer(hNode)
        schema=hNode;
        return;
    end

    origColSpan=hNode.ColSpan;
    origLayoutGrid=hNode.LayoutGrid;


    hNode.LayoutGrid(2)=nNewCols;
    if isfield(hNode,'ColStretch')
        hNode.ColStretch=zeros(nNewCols);
        hNode.ColStretch(1)=.5;
        hNode.ColStretch(nNewCols)=.5;
    end


    origNodeWidth=origLayoutGrid(2);

    hNode.Items=lSortKidsLeftToRight(hNode.Items);

    nItems=numel(hNode.Items);
    for idx=1:nItems
        hItem=hNode.Items{idx};
        if~isfield(hItem,'ColSpan')
            hItem.ColSpan=[1,1];
        end
        srcSpan=hItem.ColSpan;

        origItemWidth=srcSpan(2)-srcSpan(1)+1;
        newItemWidth=floor((origItemWidth/origNodeWidth)*nNewCols);

        if(srcSpan(1)==1)
            startCol=1;
        else
            startCol=ceil(((srcSpan(1)-1)/origNodeWidth)*nNewCols);
            prevIdx=idx-1;
            if(idx>1&&startCol<=hNode.Items{prevIdx}.ColSpan(2))
                startCol=hNode.Items{prevIdx}.ColSpan(2)+1;
            end
        end

        endCol=startCol+newItemWidth-1;
        if(endCol>nNewCols)
            endCol=nNewCols;
        end

        hItem.ColSpan=[startCol,endCol];
        if lIsContainer(hItem)
            hItem=lScaleColsDownToLeaves(hItem,newItemWidth);
        end

        hNode.Items{idx}=hItem;
    end

    schema=hNode;
end

function retItems=lMapAndBurstDdgContainers(hNodeItem,layoutHint)


    retItems={};%#ok


    if lIsWidget(hNodeItem)
        retItems={hNodeItem};
        return;
    end

    nKids=numel(hNodeItem.Items);


    for idx=1:nKids
        newLst=lMapAndBurstDdgContainers(hNodeItem.Items{idx},layoutHint);
        retItems={retItems{:},newLst{:}};
    end



    if~lItemIsBurstable(hNodeItem)
        hNodeItem.Items=retItems;

        hNodeItem=lAdjustLayout(hNodeItem,layoutHint);
        if~iscell(hNodeItem)
            retItems={hNodeItem};
        else
            retItems=hNodeItem;
        end
        return;
    end

    nItems=numel(retItems);
    parentGridCols=hNodeItem.LayoutGrid(2);
    parentColSpan=hNodeItem.ColSpan;
    parentRowSpan=hNodeItem.RowSpan;
    parentSpanWidth=hNodeItem.ColSpan(2)-hNodeItem.ColSpan(1)+1;


    for idx=1:nItems
        hItem=retItems{idx};
        srcSpan=hItem.ColSpan;

        origItemWidth=srcSpan(2)-srcSpan(1)+1;
        newItemWidth=floor((origItemWidth/parentGridCols)*parentSpanWidth);

        if(srcSpan(1)==1)
            startCol=parentColSpan(1);
        else
            startCol=parentColSpan(1)+ceil(((srcSpan(1)-1)/parentGridCols)*parentSpanWidth);
            prevIdx=idx-1;
            if(idx>1&&startCol<=retItems{prevIdx}.ColSpan(2))
                startCol=retItems{prevIdx}.ColSpan(2)+1;
            end
        end

        endCol=startCol+newItemWidth-1;
        if(endCol>parentColSpan(2))
            endCol=parentColSpan(2);
        end

        hItem.ColSpan=[startCol,endCol];
        hItem.RowSpan=parentRowSpan;

        retItems{idx}=hItem;
    end

    if~iscell(retItems)
        retItems={retItems}
    end

end

function retStatus=lIsWidget(item)
    typeList={'pushbutton','radiobutton','combobox','checkbox',...
    'listbox','table','edit','editarea','text','image',...
    'hyperlink','textbrowser'};
    retStatus=(any(strcmpi(item.Type,typeList)));
end

function retStatus=lIsContainer(item)
    typeList={'panel','group','toggelpanel','tab'};
    retStatus=(any(strcmpi(item.Type,typeList)));
end

function retStatus=lItemIsBurstable(item)
    retStatus=(any(strcmpi(item.Type,{'panel'})));
end

function sortLst=lSortKidsLeftToRight(locKids)
    nKids=numel(locKids);
    if~nKids
        sortLst=[];
        return
    end

    sortLst=locKids(1);
    for idx=2:nKids
        itemAdded=false;
        for retIdx=1:numel(sortLst)
            if locKids{idx}.ColSpan(1)<sortLst{retIdx}.ColSpan(1)
                swpItem=sortLst{retIdx};
                sortLst{retIdx}=locKids{idx};
                for tmpIdx=retIdx+1:numel(sortLst)
                    swpItem2=sortLst{tmpIdx};
                    sortLst{tmpIdx}=swpItem;
                    swpItem=swpItem2;
                end
                sortLst{numel(sortLst)+1}=swpItem;
                itemAdded=true;
                break;
            end
        end
        if~itemAdded
            sortLst{end+1}=locKids{idx};
        end
    end
end

function hRetNodeItem=lAdjustLayout(hNodeItem,layoutHint)
    if isempty(layoutHint)
        hRetNodeItem=hNodeItem;
        return;
    end

    switch(layoutHint)
    case 'Unset'
        hRetNodeItem=hNodeItem;
        return;
    case{'1ColLayout','2ColLayout','3ColLayout'}

    otherwise
        error('DynGroupPanel:Render:UnsupportedLayoutHint',...
        'Layout Type not handled, ignored: ''%s''.',layoutHint);
        return;
    end

    nRows=hNodeItem.LayoutGrid(1);
    nCols=hNodeItem.LayoutGrid(2);
    nItems=numel(hNodeItem.Items);

    for rowIdx=1:nRows;
        rowItemIndexes=[];

        for idx=1:nItems;
            if(hNodeItem.Items{idx}.RowSpan(1)==rowIdx&&...
                hNodeItem.Items{idx}.RowSpan(2)==rowIdx)
                rowItemIndexes=[rowItemIndexes,idx];
            end
        end

        numRowItems=numel(rowItemIndexes);
        if numRowItems<1
            continue;
        end

        switch(layoutHint)
        case '1ColLayout'
            if(numRowItems<2)
                continue;
            end
            hNodeItem.Items{rowItemIndexes(1)}.ColSpan(1)=1;
            hNodeItem.Items{rowItemIndexes(numRowItems)}.ColSpan(2)=nCols;

        case '2ColLayout'
            numRowItems=numel(rowItemIndexes);
            if(numRowItems<2)
                continue;
            end

            nLeftItems=floor(numRowItems/2);



            hNodeItem.Items{rowItemIndexes(nLeftItems)}.ColSpan(2)=floor(nCols/2);
            hNodeItem.Items{rowItemIndexes(nLeftItems+1)}.ColSpan(1)=floor(nCols/2)+1;

            lastCol=hNodeItem.Items{rowItemIndexes(numRowItems)}.ColSpan(2);
            if abs((lastCol-nCols)/nCols)<3
                hNodeItem.Items{rowItemIndexes(numRowItems)}.ColSpan(2)=nCols;
            end

            lastCol=hNodeItem.Items{rowItemIndexes(numRowItems)}.ColSpan(2);
            if abs((lastCol-nCols)/nCols)<.03
                hNodeItem.Items{rowItemIndexes(numRowItems)}.ColSpan(2)=nCols;
            end

        case '3ColLayout'
            numRowItems=numel(rowItemIndexes);
            if(numRowItems<2)
                continue;
            end



            hNodeItem.Items{rowItemIndexes(1)}.ColSpan(2)=floor(nCols/3);
            hNodeItem.Items{rowItemIndexes(2)}.ColSpan(1)=floor(nCols/3)+1;

            lastCol=hNodeItem.Items{rowItemIndexes(numRowItems)}.ColSpan(2);
            if abs((lastCol-nCols)/nCols)<.03
                hNodeItem.Items{rowItemIndexes(numRowItems)}.ColSpan(2)=nCols;
            end
        end
    end
    hRetNodeItem=hNodeItem;
end
