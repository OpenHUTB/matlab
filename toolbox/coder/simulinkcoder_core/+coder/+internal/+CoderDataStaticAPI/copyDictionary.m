function copyDictionary(src,dst)













    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();


    slRoot=slroot;
    if slRoot.isValidSlObject(src)&&slRoot.isValidSlObject(dst)
        [~,~,srcDD]=hlp.openDD(src,'C',true);
        [~,~,dstDD]=hlp.openDD(dst,'C',true);
    else
        [~,~,srcDD]=hlp.openDD(src);
        [~,~,dstDD]=hlp.openDD(dst);
    end

    if(srcDD.isEmpty)
        return;
    end



    pkgSrc=getCurrentNonBuiltinPackages(srcDD);
    pkgDst=getCurrentNonBuiltinPackages(dstDD);


    lcic=srcDD.ReferencedContainers;
    for i=1:lcic.Size
        importLegacyPackage(dstDD,lcic(i).Name);
    end
    for i=1:length(pkgSrc)
        pkg=pkgSrc{i};
        if~ismember(pkg,pkgDst)
            importLegacyPackage(dstDD,pkg);
        end
    end
    Utils.copyDictionary(src,dst);
end
