function isVolatile=getIsVolatile(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));

    isVolatile=false;


    if hCSCDefn.IsMemorySectionInstanceSpecific
        ca=hData.CoderInfo.CustomAttributes;
        thisMemSec=ca.MemorySection;
    else
        thisMemSec=hCSCDefn.MemorySection;
    end

    memSecs=processcsc('GetMemorySectionDefns',hCSCDefn.OwnerPackage);
    sizeMS=size(memSecs);
    for i=1:sizeMS(1)
        if strcmp(thisMemSec,memSecs(i).Name)
            isVolatile=memSecs(i).IsVolatile;
            break;
        end
    end



