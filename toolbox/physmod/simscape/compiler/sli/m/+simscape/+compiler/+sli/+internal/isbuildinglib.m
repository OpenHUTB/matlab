function retStatus=isbuildinglib(statusVal)














    persistent internalStatus;
    if isempty(internalStatus)
        internalStatus=0;
    end
    if(nargin==1)
        internalStatus=statusVal;
    end
    retStatus=internalStatus;
end
