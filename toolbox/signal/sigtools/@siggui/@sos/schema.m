function schema





    pk=findpackage('siggui');

    c=schema.class(pk,'sos',pk.findclass('dialog'));

    if isempty(findtype('sosScale'))
        schema.EnumType('sosScale',{'None','L-2','L-infinity'});
    end

    if isempty(findtype('sosDirection'))
        schema.EnumType('sosDirection',{'Up','Down'});
    end

    p=schema.prop(c,'Direction','sosDirection');

    p=schema.prop(c,'Scale','sosScale');
    p.SetFunction=@setscale;

    p=schema.prop(c,'Filter','MATLAB array');

    e=schema.event(c,'NewFilter');


    function out=setscale(h,out)

        switch lower(out)
        case 'none'
            dirFlag=get(h,'Direction');
        case 'l-2'
            dirFlag='DOWN';
        case 'l-infinity'
            dirFlag='UP';
        end

        set(h,'Direction',dirFlag);


