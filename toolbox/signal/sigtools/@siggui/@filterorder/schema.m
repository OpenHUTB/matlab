function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'filterorder',pk.findclass('abstractfilterorder'));

    p=schema.prop(c,'mode','SignalFdatoolFilterOrderMode');
    set(p,'SetFunction',@setmode,'FactoryValue','minimum');


    function mode=setmode(h,mode)


        modeOpts=set(h,'Mode');

        if~get(h,'IsMinOrd')&&strmatch(lower(mode),modeOpts{2})
            error(message('signal:siggui:filterorder:schema:InternalError'));
        end


