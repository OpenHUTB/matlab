function schema





    pk=findpackage('xregGui');
    c=schema.class(pk,'uitoolbar');


    p=schema.prop(c,'Children','handle vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';
    p.GetFunction=@i_getchildren;

    p=schema.prop(c,'DesiredHeight','double');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';
    p.GetFunction=@i_getheight;

    schema.prop(c,'Parent','MATLAB array');

    p=schema.prop(c,'Position','rect');
    p.AccessFlags.Init='on';
    p.FactoryValue=[1,1,10,31];

    p=schema.prop(c,'ResourceLocation','ustring');
    p.AccessFlags.Listener='off';

    schema.prop(c,'Tag','string');

    p=schema.prop(c,'Type','string');
    p.AccessFlags.Init='on';
    p.FactoryValue='uitoolbar';
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';

    schema.prop(c,'UserData','MATLAB array');

    p=schema.prop(c,'Visible','on/off');
    p.AccessFlags.Init='on';
    p.FactoryValue='on';



    p=schema.prop(c,'hListeners','handle vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'hRenderer','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';
    p.Visible='off';


    function val=i_getheight(obj,val)
        if~isempty(obj.hRenderer)
            val=obj.hRenderer.ButtonHeight+6;
        else
            val=6;
        end

        function val=i_getchildren(obj,val)
            if~isempty(obj.hRenderer)
                val=obj.hRenderer.Children;
            end
