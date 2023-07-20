function[tfNum,tfDen]=getEquivalentTfOf1stOrderFilterSum(gainsVec,tausVec)%#codegen











    coder.allowpcode('plain');

    numElements=length(gainsVec);
    numTerms=numElements+1;

    tfDen=getExpandedTermsFromProduct(tausVec);

    tfNum=zeros(numTerms,1);


    for idxTerm=1:numTerms
        expandedDenMat=zeros(numElements,numTerms);
        for idxNum=1:numElements
            tausVecWithoutExcludedTerm=tausVec;
            tausVecWithoutExcludedTerm(idxNum)=[];
            expandedDenMat(idxNum,:)=[getExpandedTermsFromProduct(tausVecWithoutExcludedTerm)',0];
        end
        tfNum(idxTerm)=sum(gainsVec(:).*expandedDenMat(:,idxTerm));
    end


    tfNum=flip(tfNum);
    tfDen=flip(tfDen);

end



function termsList=getExpandedTermsFromProduct(coeffList)%#codegen



    coder.allowpcode('plain');

    numElements=length(coeffList);
    numTerms=numElements+1;

    termsList=zeros(numTerms,1);
    termsList(1)=1;

    for idxElement=1:numElements
        combinations=nchoosek(coeffList(:),idxElement);
        termsList(idxElement+1)=sum(prod(combinations,2));
    end

end


