function out=getLegacyStorageClassInDictByPackage(sourceDD,package)











    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    dd=hlp.openDD(sourceDD);



    legacyCSCs=hlp.getCoderData(dd,'AbstractStorageClass');
    out={};
    for i=1:length(legacyCSCs)
        currentCSC=legacyCSCs(i);
        pkg=hlp.getProp(currentCSC,'Package');
        if strcmp(pkg,package)
            out{end+1}=hlp.getProp(currentCSC,'ClassName');%#ok
        end
    end
end
