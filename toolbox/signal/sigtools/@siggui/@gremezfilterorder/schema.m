function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'gremezfilterorder',pk.findclass('abstractfilterorder'));

    p=schema.prop(c,'mode','gremezOrderMode');
    set(p,'SetFunction',@setmode,'FactoryValue','minimum');


    function mode=setmode(h,mode)


        modeOpts=set(h,'Mode');

        if~get(h,'IsMinOrd')&&~strcmpi(mode,modeOpts{1})
            error(message('signal:siggui:gremezfilterorder:schema:InternalError'));
        end


