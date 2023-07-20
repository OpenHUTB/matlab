function[pkg,classname]=getLegacyMemorySectionInfo(sourceDD,name)









    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    pkg='';
    classname='';
    dd=hlp.openDD(sourceDD);
    msEntry=hlp.findEntry(dd,'AbstractMemorySection',name);
    if~isempty(msEntry)
        pkg=hlp.getProp(msEntry,'Package');
        classname=hlp.getProp(msEntry,'ClassName');
    end
end
