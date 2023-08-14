function[dd,needSLPkg]=openCDefinitions(sourceDD)














    import coder.internal.CoderDataStaticAPI.*;

    hlp=getHelper();

    slRoot=slroot;
    needSLPkg=true;

    if slRoot.isValidSlObject(sourceDD)
        dd=hlp.openDD(sourceDD,'C',true);

        needSLPkg=~hasSharedDictionaryWithCoderDictionary(sourceDD);
    else
        dd=hlp.openDD(sourceDD);
    end

end


