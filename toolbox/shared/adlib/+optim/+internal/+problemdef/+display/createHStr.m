function HStr=createHStr(H,nelem,varInfo)











    HStr=strings(nelem,1);


    [idxNonZero,jdxNonZero,HVal]=find(H);
    Hnnz=numel(idxNonZero);


    if isempty(idxNonZero)
        return
    end


    idxNonZeroVar=mod(idxNonZero-1,varInfo.NumVars)+1;



    [uniqueVars,~,idxUniqueVars]=unique([idxNonZeroVar,jdxNonZero]);

    jdxUniqueVars=idxUniqueVars(Hnnz+1:end);
    idxUniqueVars=idxUniqueVars(1:Hnnz);


    uniqueVarStrings=optim.internal.problemdef.display.createVarStrings(uniqueVars,varInfo);


    for idx=1:nelem


        thisIdx=(idxNonZero>=varInfo.NumVars*(idx-1)+1)&(idxNonZero<=varInfo.NumVars*idx);

        if any(thisIdx)
            thisIdxVar=find(thisIdx);
            idxNonZeroInHi=idxNonZero(thisIdx)-varInfo.NumVars*(idx-1);
            jdxNonZeroInHi=jdxNonZero(thisIdx);
            HValInHi=HVal(thisIdx);




            diagH=abs(idxNonZeroInHi-jdxNonZeroInHi);



            diagHidx=diagH==0;
            if any(diagHidx)
                HStr(idx)=" "+i_createSquareSumStrForNamedVar(HValInHi(diagHidx),uniqueVarStrings(idxUniqueVars(thisIdxVar(diagHidx))));
            end


            for i=1:varInfo.NumVars-1

                diagHidx=diagH==i;
                if any(diagHidx)
                    diagHidxVar=thisIdxVar(diagHidx);

                    thisSumStr=i_createSumProductStrForNamedVar(HValInHi(diagHidx),...
                    uniqueVarStrings(idxUniqueVars(diagHidxVar)),uniqueVarStrings(jdxUniqueVars(diagHidxVar)));

                    HStr(idx)=HStr(idx)+" "+thisSumStr;
                end

            end


            HStr(idx)=extractAfter(HStr(idx),1);
        end

    end

    function sumStr=i_createSquareSumStrForNamedVar(coeff,varStr)


        nTerms=numel(coeff);


        operator=strings(nTerms,1);
        negTerms=coeff<0;
        operator(~negTerms)="+ ";
        operator(negTerms)="- ";


        coeffstr=strings(nTerms,1);
        coeffAbs=abs(coeff);
        nonUnitTerms=coeffAbs~=1;
        coeffstr(nonUnitTerms)=string(coeffAbs(nonUnitTerms))+"*";


        term=operator+coeffstr+varStr+"^2";


        sumStr=join(term);

        function sumStr=i_createSumProductStrForNamedVar(coeff,varStr1,varStr2)


            nTerms=numel(coeff);


            operator=strings(nTerms,1);
            operator(coeff>=0)="+ ";
            operator(coeff<0)="- ";


            coeffstr=string(abs(coeff))+"*";
            coeffstr(abs(coeff)==1)="";


            term=operator+coeffstr+varStr1+"*"+varStr2;


            sumStr=join(term);