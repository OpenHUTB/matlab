function schema

    pk=findpackage('xregGui');
    c=schema.class(pk,'uipushtool');
    schema.prop(c,'ClickedCallback','MATLAB callback');

    schema.prop(c,'CData','MATLAB array');

    p=schema.prop(c,'Enable','on/off');
    p.AccessFlags.Init='on';
    p.FactoryValue='on';

    p=schema.prop(c,'ImageFile','ustring');
    p.AccessFlags.Listener='off';
    p.SetFunction=@i_setimfile;

    p=schema.prop(c,'Interruptible','on/off');
    p.AccessFlags.Init='on';
    p.FactoryValue='off';
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'Separator','on/off');
    p.AccessFlags.Init='on';
    p.FactoryValue='off';

    p=schema.prop(c,'ToolTipString','string');
    p.AccessFlags.Listener='off';

    schema.prop(c,'TransparentColor','MATLAB array');

    schema.prop(c,'Parent','MATLAB array');

    schema.prop(c,'Tag','string');

    p=schema.prop(c,'Type','string');
    p.AccessFlags.Init='on';
    p.FactoryValue='uipushtool';
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';

    schema.prop(c,'UserData','MATLAB array');

    p=schema.prop(c,'Visible','on/off');
    p.AccessFlags.Init='on';
    p.FactoryValue='on';



    p=schema.prop(c,'hListener','handle vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'hColors','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Init='on';
    p.FactoryValue=xregGui.SystemColors;
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'EventListener','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'IsEnabled','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Init='on';
    p.FactoryValue=true;
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'CDataSizeCache','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Init='on';
    p.FactoryValue=[0,0,0];
    p.AccessFlags.Listener='off';


    schema.event(c,'ClickedCallback');



    function val=i_setimfile(obj,val)









        resource_val=fullfile(obj.Parent.ResourceLocation,val);
        if exist(resource_val,'file')
            file=resource_val;
        else
            file=val;
        end
        if exist(file,'file')
            im=imread(file);
            obj.cdata=im;
        end
