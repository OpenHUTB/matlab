function cineqVals=inequalityConstraintValues4Solver(obj)










    cineqnames=obj.NonlinearInequalityConstraints;


    numVals=obj.NumValues;


    numLabelledIneq=numel(cineqnames);
    allNumCIneq=zeros(1,numLabelledIneq);
    idxStart=zeros(1,numLabelledIneq);
    idxEnd=zeros(1,numLabelledIneq);
    totalNumCIneq=0;
    for i=1:numel(cineqnames)
        allNumCIneq(i)=prod(obj.ConstraintSize.(cineqnames(i)));
        totalNumCIneq=totalNumCIneq+allNumCIneq(i);
        idxEnd(i)=totalNumCIneq;
        idxStart(i)=idxEnd(i)-allNumCIneq(i)+1;
    end


    cineqVals=zeros(numVals,totalNumCIneq);


    for i=1:numel(cineqnames)




        thisCineqVals=obj.Values.(cineqnames);
        reshapeSize=[allNumCIneq(i),numVals];
        thisCineqVals=reshape(thisCineqVals,reshapeSize);


        cineqVals(:,idxStart(i):idxEnd(i))=thisCineqVals';
    end