function ov2=v1convert(ov2,sv1)






    ov2.SysLoopType=sv1.SysLoopType(2:end);


    ov2.Active=sv1.isActive;


    ov2.MdlName=sv1.MdlName;
    ov2.MdlCurrSys=sv1.MdlCurrSys;

    if ischar(sv1.isMask)
        ov2.isMask=sv1.isMask;
    elseif sv1.isMask
        ov2.isMask='functional';
    else
        ov2.isMask='none';
    end

    if ischar(sv1.isLibrary)
        ov2.isLibrary=sv1.isLibrary;
    elseif sv1.isLibrary
        ov2.isLibrary='on';
    else
        ov2.isLibrary='off';
    end


