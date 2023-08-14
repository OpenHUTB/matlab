function moveDictionary(src,dst)













    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    [~,~,srcDD]=hlp.openDD(src);
    [~,~,dstDD]=hlp.openDD(dst);

    if dstDD.isEmpty

        coder.internal.CoderDataStaticAPI.createSWCTIfNotExists(dstDD)
    end

    copyDictionary(src,dst);
    deleteAll(srcDD,true);
end


