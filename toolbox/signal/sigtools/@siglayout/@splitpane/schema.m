function schema





    pk=findpackage('siglayout');
    c=schema.class(pk,'splitpane',pk.findclass('abstractlayout'));

    p=schema.prop(c,'NorthWest','mxArray');
    set(p,'SetFunction',{@set_child,'northwest'});

    p=schema.prop(c,'SouthEast','mxArray');
    set(p,'SetFunction',{@set_child,'southeast'});

    if isempty(findtype('splitpaneDominantType'))
        schema.EnumType('splitpaneDominantType',{'NorthWest','SouthEast'});
    end

    if isempty(findtype('splitpaneLayoutDirectionType'))
        schema.EnumType('splitpaneLayoutDirectionType',{'Horizontal','Vertical'});
    end

    schema.prop(c,'LayoutDirection','splitpaneLayoutDirectionType');
    schema.prop(c,'Dominant','splitpaneDominantType');

    p=schema.prop(c,'DominantWidth','double');
    set(p,'FactoryValue',100);

    p=schema.prop(c,'DividerWidth','double');
    set(p,'FactoryValue',5);

    p=schema.prop(c,'DividerHandle','mxArray');
    set(p,'Visible','Off');

    schema.prop(c,'AutoUpdate','bool');

    p=[...
    schema.prop(c,'Listeners','handle.listener vector');...
    schema.prop(c,'ChildrenListeners','mxArray');...
    ];
    set(p,...
    'AccessFlags.PublicSet','Off',...
    'AccessFlags.PublicGet','Off');


