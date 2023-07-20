function outStr=showDisplay(obj,printHeaders,type,varargin)




























    showDocLink=nargin<4;


    truncate=false;



    isLinearLSQOrNonlinearExpression=isa(obj,'optim.problemdef.OptimizationExpression')&&...
    (isNonlinear(obj)||(isQuadratic(obj)&&isSumSquares(obj)));
    isQuadraticOrNonlinearConstraint=isa(obj,'optim.problemdef.OptimizationConstraint')&&...
    (isQuadratic(obj)||isNonlinear(obj));
    if isLinearLSQOrNonlinearExpression||isQuadraticOrNonlinearConstraint
        [objStr,extraParamsStr,displayEntrywise,nzIdx]=expandNonlinearStr(obj,showDocLink);

        if~displayEntrywise

            outStr=optim.internal.problemdef.display.printNonlinearForCommandWindow(...
            objStr,extraParamsStr,truncate,type,varargin{:});
            outStr=newline+outStr+newline;
            return;
        end
    else



        [objStr,nzIdx]=expand2str(obj,showDocLink);
    end




    nzIdx=find(nzIdx);
    numNNZ=max(1,numel(nzIdx));

    if printHeaders
        if isempty(nzIdx)||isscalar(obj)

            idxStr=newline;
            nzIdx=1;
        else

            simplifySub=false;
            idxStr=newline+optim.internal.problemdef.display.getSubDisplay(nzIdx,getSize(obj),getIndexNames(obj),simplifySub)+newline+newline;
        end
    else
        idxStr=strings(numNNZ,1);
        idxStr(1)=newline;
        if isempty(nzIdx)


            nzIdx=1;
        end
    end

    outStr="";
    for i=1:numNNZ

        outStr=outStr+idxStr(i);


        StrI=optim.internal.problemdef.display.printForCommandWindow("  "+objStr(nzIdx(i)),truncate,type,varargin{:});
        outStr=outStr+StrI+newline;
    end

end
