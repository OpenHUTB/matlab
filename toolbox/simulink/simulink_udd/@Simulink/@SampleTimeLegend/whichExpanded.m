function retVal=whichExpanded(h,tsIdx,tabIdx)
    retVal=0;
    for n=1:length(h.expandedVarTs)
        if((h.expandedVarTs{n}(1)==tabIdx)&&...
            (h.expandedVarTs{n}(2)==tsIdx))
            retVal=n;
            return;
        end
    end
