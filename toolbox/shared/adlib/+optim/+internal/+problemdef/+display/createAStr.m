function AStr=createAStr(A,nelem,varInfo)











    AStr=strings(nelem,1);


    [idxNonZero,jdxNonZero,AVal]=find(A);


    if isempty(idxNonZero)
        return
    end



    [uniqueVars,~,idxUniqueVars]=unique(idxNonZero);


    uniqueVarStrings=optim.internal.problemdef.display.createVarStrings(uniqueVars,varInfo);

    for idx=1:nelem

        thisIdx=jdxNonZero==idx;

        if any(thisIdx)

            AValInAi=AVal(thisIdx);


            AStr(idx)=i_createSumStrForNamedVar(AValInAi,uniqueVarStrings(idxUniqueVars(thisIdx)));
        end

    end

    function sumStr=i_createSumStrForNamedVar(coeff,varStr)


        nTerms=numel(coeff);


        operator=strings(nTerms,1);
        negTerms=coeff<0;
        operator(~negTerms)="+ ";
        operator(negTerms)="- ";


        coeffstr=strings(nTerms,1);
        coeffAbs=abs(coeff);
        nonUnitTerms=coeffAbs~=1;
        coeffstr(nonUnitTerms)=string(coeffAbs(nonUnitTerms))+"*";


        term=operator+coeffstr+varStr;


        sumStr=join(term);