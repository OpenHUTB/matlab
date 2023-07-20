function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'convert',pk.findclass('okcanceldlg'));

    p=schema.prop(c,'TargetStructure','ustring');

    p=schema.prop(c,'ReferenceFilter','MATLAB array');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';

    p=schema.prop(c,'DSPMode','bool');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';

    p=schema.prop(c,'Filter','MATLAB array');
    p.SetFunction=@setfilter;

    e=schema.event(c,'FilterConverted');


    function newfilt=setfilter(hC,newfilt)

        constructor=getconstructor(hC);

        reffilt=getreffilt(hC);


        if~isempty(reffilt)&~strcmpi(constructor,classname(reffilt))
            if ismethod(reffilt,'convert')
                try,
                    reffilt=convert(reffilt,constructor);
                end
            end



            setisapplied(hC,0);
        end



        if~isequal(newfilt,reffilt)
            hC.setreffilt(newfilt);
        end


