function leftJac=MtimesLeftAdjointNonFinite(leftSize,right,currAdjoint)













    RightSize=size(right);
    CurrAdjointSize=size(currAdjoint);

























    rowIndex=cell(RightSize(1),1);
    colIndex=cell(RightSize(1),1);
    vals=cell(RightSize(1),1);
    for i=1:RightSize(1)


        thisRow=repmat(full(right(i,:)),leftSize(1),1);
        thisRow=thisRow(:);
        thisJac=thisRow.*full(currAdjoint);
        thisJac2=zeros(leftSize(1),CurrAdjointSize(2));
        for j=1:RightSize(2)
            idxThis=getRowIdx(leftSize(1),j);
            thisJac2=thisJac2+thisJac(idxThis,:);
        end


        [thisRowIndex,thisColIndex,thisVals]=find(thisJac2);
        rowIndex{i}=thisRowIndex(:)'+leftSize(1)*(i-1);
        colIndex{i}=thisColIndex(:)';
        vals{i}=thisVals(:)';
    end
    leftJac=sparse([rowIndex{:}],[colIndex{:}],[vals{:}],...
    leftSize(1)*leftSize(2),CurrAdjointSize(2));

end

function idxRows=getRowIdx(skip,i)

    idxRowStart=1+skip*(i-1);
    idxRowEnd=skip*i;
    idxRows=idxRowStart:idxRowEnd;

end


