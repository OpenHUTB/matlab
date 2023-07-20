function schema





    pk=findpackage('siggui');

    c=schema.class(pk,'gremezoptsframe',pk.findclass('remezoptionsframe'));

    findclass(findpackage('filtdes'),'gremez');
    schema.prop(c,'Phase','gremezPhase');
    schema.prop(c,'FIRType','gremezFIRType');

    p=schema.prop(c,'InitOrder','ustring');
    set(p,'FactoryValue','[]','Description','Initial Estimate of the Filter Order');

    p=schema.prop(c,'ErrorBands','ustring');
    set(p,'Description','Independent Approximation Error Bands','FactoryValue','[]');

    p=schema.prop(c,'SinglePointBands','ustring');
    set(p,'Description','Single Point Bands','FactoryValue','[]');

    p=schema.prop(c,'ForcedFreqPoints','ustring');
    set(p,'Description','Forced Frequency Points','FactoryValue','[]');

    p=schema.prop(c,'IndeterminateFreqPoints','ustring');
    set(p,'Description','Indeterminate Frequency Points','FactoryValue','[]');

    p=schema.prop(c,'DisabledProps','MATLAB array');
    set(p,'FactoryValue',{},'SetFunction',@setdisabledprops);


    function out=setdisabledprops(h,out)

        if ischar(out)
            out={out};
        elseif~iscellstr(out)
            error(message('signal:siggui:gremezoptsframe:schema:MustBeAString'));
        end


