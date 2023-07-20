function leftTan=MtimesLeftTangentNonFinite(leftSize,right,currTangent)












    RightSize=size(right);
    CurrTangentSize=size(currTangent);























    rowIndex=cell(RightSize(2),1);
    colIndex=cell(RightSize(2),1);
    vals=cell(RightSize(2),1);
    for j=1:RightSize(2)


        thisJac2=zeros(CurrTangentSize(1),leftSize(1));
        for i=1:RightSize(1)
            idxLeft=(1+(i-1)*leftSize(1)):i*leftSize(1);
            thisJac2=thisJac2+full(currTangent(:,idxLeft))*right(i,j)*eye(leftSize(1));
        end



        [thisRowIndex,thisColIndex,thisVals]=find(thisJac2);
        rowIndex{j}=thisRowIndex(:)';
        colIndex{j}=thisColIndex(:)'+leftSize(1)*(j-1);
        vals{j}=thisVals(:)';
    end
    leftTan=sparse([rowIndex{:}],[colIndex{:}],[vals{:}],...
    CurrTangentSize(1),leftSize(1)*RightSize(2));

end



