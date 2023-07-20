function schema





    pk=findpackage('siggui');

    c=schema.class(pk,'siggui');
    set(c,'Description','abstract');

    p=schema.prop(c,'Tag','ustring');
    set(p,'GetFunction',@get_tag);

    p=schema.prop(c,'Version','double');
    p.AccessFlags.PublicSet='off';
    p.FactoryValue=1.0;



    p=[...
    schema.prop(c,'LinkDatabase','mxArray');...
    schema.prop(c,'CSHMenu','mxArray');...
    ];
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off')
    set(p(2),'FactoryValue',-1);

    e=[...
    schema.event(c,'sigguiRendering');...
    schema.event(c,'sigguiClosing');...
    schema.event(c,'Notification');...
    schema.event(c,'UserModifiedSpecs');...
    ];




    function tag=get_tag(this,tag)

        if isempty(tag)
            tag=class(this);
        end


