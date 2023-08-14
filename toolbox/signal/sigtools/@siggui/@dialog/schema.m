function schema




    pk=findpackage('siggui');


    c=schema.class(pk,'dialog',pk.findclass('sigcontainer'));

    if isempty(findtype('sigguiDialogWindowStyle'))
        schema.EnumType('sigguiDialogWindowStyle',{'Normal','Modal'});
    end

    p=[...
    schema.prop(c,'DialogHandles','MATLAB array');...
    schema.prop(c,'isApplied','bool');...
    schema.prop(c,'Operations','handle vector');...
    schema.prop(c,'WindowStyle','sigguiDialogWindowStyle');...
    ];
    set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');
    set(p(3),'AccessFlags.Listener','Off');
    set(p(4),'FactoryValue','Normal');

    schema.event(c,'DialogBeingApplied');
    schema.event(c,'DialogApplied');
    schema.event(c,'DialogCancelled');


