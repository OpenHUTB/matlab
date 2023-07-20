function rightJac=MtimesRightAdjointNonFinite(left,rightSize,currAdjoint)












    LeftSize=size(left);
    CurrAdjointSize=size(currAdjoint);


















    rowIndex=cell(rightSize(2),1);
    colIndex=cell(rightSize(2),1);
    vals=cell(rightSize(2),1);
    for i=1:rightSize(2)
        idxRowsAdj=getRowIdx(LeftSize(1),i);


        thisJac2=full(left')*full(currAdjoint(idxRowsAdj,:));
        [thisRowIndex,thisColIndex,thisVals]=find(thisJac2);
        rowIndex{i}=thisRowIndex(:)'+(i-1)*LeftSize(2);
        colIndex{i}=thisColIndex(:)';
        vals{i}=thisVals(:)';
    end
    rightJac=sparse([rowIndex{:}],[colIndex{:}],[vals{:}],...
    rightSize(1)*rightSize(2),CurrAdjointSize(2));

end

function idxRows=getRowIdx(skip,i)

    idxRowStart=1+skip*(i-1);
    idxRowEnd=skip*i;
    idxRows=idxRowStart:idxRowEnd;

end

