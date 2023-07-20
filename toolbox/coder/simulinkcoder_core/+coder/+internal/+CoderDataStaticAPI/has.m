function ret=has(sourceDD,type,name)

















    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    ret=false;
    dd=hlp.openDD(sourceDD);
    if isa(dd,'Simulink.data.Dictionary')
        sec=hlp.getDDSection(dd,type);
        ret=exist(sec,name);
    end
end
