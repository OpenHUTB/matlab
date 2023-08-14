function str=getBoundStr(obj,printUnboundedMsg,paddingAmount)







    if nargin<3
        paddingAmount=4;
        if nargin<2
            printUnboundedMsg=false;
        end
    end


    objName=obj.Name;


    lb=obj.LowerBound(:);
    ub=obj.UpperBound(:);


    padding=repmat(' ',1,paddingAmount);
    finiteLowerBound=isfinite(lb);
    numFiniteLB=nnz(finiteLowerBound);
    finiteUpperBound=isfinite(ub);
    numFiniteUB=nnz(finiteUpperBound);


    if numFiniteLB+numFiniteUB==0
        if printUnboundedMsg
            notBndedMsg=getString(message('shared_adlib:OptimizationVariable:UnboundedVar',objName));
            str=""+newline+padding+notBndedMsg+newline;
        else
            str="";
        end
        return;
    end


    var=obj.Variables.(objName);
    objSize=getSize(var);
    objIdxNames=getIndexNames(var);

    linIdx=getSubscriptValues(obj);


    if prod(objSize)==1

        str=""+newline+padding;


        if numFiniteLB
            str=str+lb+" <= ";
        end


        str=str+objName;


        idxStr=optim.internal.problemdef.display.getSubDisplay(linIdx,objSize,objIdxNames);
        str=str+idxStr;


        if numFiniteUB
            str=str+" <= "+ub;
        end

        str=str+newline;


    else

        str=""+newline+padding;


        if(numFiniteLB==numel(lb))
            printIdx=1:numFiniteLB;
        else


            printIdx=find(finiteLowerBound|finiteUpperBound);
        end


        idxStr=optim.internal.problemdef.display.getSubDisplay(linIdx(printIdx),objSize,objIdxNames);


        lbStr=num2str(lb(finiteLowerBound));


        leftMaxChars=size(lbStr,2)+4;

        varMaxChars=max(strlength(idxStr));



        lowerBoundIdx=1;

        for i=1:numel(printIdx)

            printI=printIdx(i);



            if finiteLowerBound(printI)
                str=str+lbStr(lowerBoundIdx,:)+" <= ";
                lowerBoundIdx=lowerBoundIdx+1;
            else
                whiteSpace=repmat(' ',1,leftMaxChars);
                str=str+whiteSpace;
            end


            str=str+objName+idxStr(i);



            if finiteUpperBound(printI)
                whiteSpace=repmat(' ',1,varMaxChars-strlength(idxStr(i)));
                str=str+whiteSpace+" <= "+ub(printI);
            end





            str=str+newline+padding;
        end
    end

end

