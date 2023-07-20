function rightTan=MtimesRightTangentNonFinite(left,RightSize,currTangent)












    LeftSize=size(left);
    CurrAdjointSize=size(currTangent);





















    rowIndex=cell(RightSize(2),1);
    colIndex=cell(RightSize(2),1);
    vals=cell(RightSize(2),1);
    for j=1:RightSize(2)
        idxColsTan=getColIdx(LeftSize(2),j);


        thisJac2=full(currTangent(:,idxColsTan))*full(left');
        [thisRowIndex,thisColIndex,thisVals]=find(thisJac2);
        rowIndex{j}=thisRowIndex(:)';
        colIndex{j}=thisColIndex(:)'+(j-1)*LeftSize(1);
        vals{j}=thisVals(:)';
    end
    rightTan=sparse([rowIndex{:}],[colIndex{:}],[vals{:}],...
    CurrAdjointSize(1),LeftSize(1)*RightSize(2));

end

function idxCols=getColIdx(skip,i)

    idxColStart=1+skip*(i-1);
    idxColEnd=skip*i;
    idxCols=idxColStart:idxColEnd;

end

