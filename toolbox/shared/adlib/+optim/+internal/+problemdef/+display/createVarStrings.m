function uniqueVarStrings=createVarStrings(uniqueVars,varInfo)















    uniqueVarStrings=strings(numel(uniqueVars),1);



    for i=1:varInfo.NumNamedVar


        idxThisNonZeroUniqueVar=uniqueVars>=varInfo.StartIdx(i)&uniqueVars<=varInfo.EndIdx(i);
        idxThisNonZero=uniqueVars(idxThisNonZeroUniqueVar);



        if isempty(idxThisNonZero)
            continue
        end


        linIdx=idxThisNonZero-varInfo.StartIdx(i)+1;


        uniqueVarStrings(idxThisNonZeroUniqueVar)=varInfo.Name{i}+...
        optim.internal.problemdef.display.getSubDisplay(linIdx,varInfo.Size{i},varInfo.IndexNames{i});

    end
