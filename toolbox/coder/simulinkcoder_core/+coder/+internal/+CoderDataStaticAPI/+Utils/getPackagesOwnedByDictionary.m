function pkgs=getPackagesOwnedByDictionary(dd)









    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    dd=hlp.openDD(dd);
    scsMap=containers.Map;
    mssMap=containers.Map;
    scs=dd.StorageClasses;
    mss=dd.MemorySections;
    for i=1:scs.Size
        if isa(scs(i),'coderdictionary.data.LegacyStorageClass')
            package=scs(i).Package;
            if~isKey(scsMap,package)
                scsMap(package)=1;
            end
        end
    end
    for i=1:mss.Size
        if isa(mss(i),'coderdictionary.data.LegacyMemorySection')
            package=mss(i).Package;
            if~isKey(mssMap,package)
                mssMap(package)=1;
            end
        end
    end
    pkgs=unique([scsMap.keys,mssMap.keys]);
end


