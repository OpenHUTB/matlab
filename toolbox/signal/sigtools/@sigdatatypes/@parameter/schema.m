function schema





    pk=findpackage('sigdatatypes');

    c=schema.class(pk,'parameter');

    p=[schema.prop(c,'Name','ustring');...
    schema.prop(c,'Tag','ustring');...
    schema.prop(c,'ValidValues','MATLAB array')];
    set(p,'AccessFlags.PublicSet','off');
    p(3).GetFunction=@getvalidvalues;

    p=[...
    schema.prop(c,'DisabledOptions','double_vector');...
    schema.prop(c,'AllOptions','string vector');...
    schema.prop(c,'DefaultValue','MATLAB array');...
    ];

    set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');

    schema.event(c,'NewValue');
    schema.event(c,'UserModified');
    schema.event(c,'NewValidValues');
    schema.event(c,'ForceUpdate');


