function DT=resolveFilterDT(this,inDT)




    if isnumerictype(inDT)
        DT=inDT;
    elseif strcmpi(inDT,'Inherit via internal rule')
        DT='Full precision';
    else
        DT=inDT;
    end
