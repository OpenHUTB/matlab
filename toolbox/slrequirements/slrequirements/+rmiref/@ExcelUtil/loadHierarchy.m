function loadHierarchy(this,progressBarInfo)



    myRows=this.hDoc.Sheets.Item(1).Rows;
    parents=zeros(0,2);

    currentRow=0;
    while true
        [currentRow,currentCell]=getNextRow(myRows,currentRow);
        if currentRow<0
            break;
        end

        myFont=myRows.Item(currentRow).Cells.Item(currentCell).Font.Size;
        if isempty(parents)
            parents(currentRow,:)=[myFont,-1];
        else
            parentIdx=findNearestParent(parents,myFont);
            parents(currentRow,:)=[myFont,parentIdx];
        end


        if~isempty(progressBarInfo)&&mod(currentRow,20)==0
            if rmiut.progressBarFcn('isCanceled')
                break;
            else
                rmiut.progressBarFcn('set',progressBarInfo(1)+(currentRow/1000)*progressBarInfo(2),...
                getString(message('Slvnv:reqmgt:linktype_rmi_word:GeneratingDocumentIndex')));
            end
        end
    end

    this.iLevels=parents(:,1);
    this.iParents=parents(:,2);

end

function parentIdx=findNearestParent(parents,fontSize)
    isBiggerFont=find(parents(:,1)>fontSize);
    if isempty(isBiggerFont)
        parentIdx=-1;
    else
        parentIdx=isBiggerFont(end);
    end
end

function[nextRow,goodCell]=getNextRow(myRows,current)
    allowSpace=5;
    goodCell=-1;
    for i=1:allowSpace
        oneRow=myRows.Item(current+i);
        goodCell=nextGoodCell(oneRow);
        if goodCell>0
            nextRow=current+i;
            return;
        else
            continue;
        end
    end
    nextRow=-1;
end

function goodCell=nextGoodCell(oneRow)
    allowSpace=3;
    for i=1:allowSpace
        oneCell=oneRow.Cells.Item(i);
        if isempty(oneCell.Text)
            continue;
        else
            goodCell=i;
            return;
        end
    end
    goodCell=-1;
end

