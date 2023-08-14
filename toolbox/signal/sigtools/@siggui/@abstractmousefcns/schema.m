function schema




    pk=findpackage('siggui');

    c=schema.class(pk,'abstractmousefcns',pk.findclass('sigcontainer'));
    c.Description='abstract';

    if isempty(findtype('sigguiButtonClickType'))
        schema.EnumType('sigguiButtonClickType',{'Left','Right','Shift','Double'});
    end

    if isempty(findtype('sigguiButtonState'))
        schema.EnumType('sigguiButtonState',{'Up','Down','DoubleDown'});
    end


    p=[...
    schema.prop(c,'CurrentAxes','mxArray');...
    schema.prop(c,'CallbackObject','mxArray');...
    schema.prop(c,'MovementTransaction','handle.transaction');...
    schema.prop(c,'WindowButtonMotionFcn','MATLAB array');...
    schema.prop(c,'WindowButtonUpFcn','MATLAB array');...
    ];
    p(1).FactoryValue=-1;
    p(2).FactoryValue=-1;
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');


    spcuddutils.addpostsetprop(c,'AnnounceNewSpecs','on/off',@set_announcenewspecs);


    p=[...
    schema.prop(c,'ButtonState','sigguiButtonState');
    schema.prop(c,'ButtonClickType','sigguiButtonClickType');...
    schema.prop(c,'CurrentPoint','double_vector');...
    ];
    set(p,'AccessFlags.PublicSet','Off');

    schema.event(c,'ButtonDown');
    schema.event(c,'ButtonUp');
    schema.event(c,'MouseMotion');
    schema.event(c,'NewSpecs');


