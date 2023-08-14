function isConst=getIsConst(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));

    isConst=false;


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
            isConst=memSecs(i).IsConst;
            break;
        end
    end




