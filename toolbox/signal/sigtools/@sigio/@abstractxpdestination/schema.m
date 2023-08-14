function schema





    pk=findpackage('sigio');
    pk1=findpackage('siggui');
    c=schema.class(pk,'abstractxpdestination',pk1.findclass('sigcontainer'));
    c.Description='abstract';


    p=schema.prop(c,'Data','mxArray');
    set(p,'SetFunction',@setdata,'GetFunction',@getdata);

    findclass(findpackage('sigutils'),'vector');
    p=[...
    schema.prop(c,'VariableCount','int32')...
    ,schema.prop(c,'VectorChangedListener','handle.listener')...
    ,schema.prop(c,'privData','sigutils.vector')...
    ];
    set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');
    set(p(3),'SetFunction',@setprivdata);

    schema.prop(c,'Toolbox','ustring');


    schema.event(c,'NewFrameHeight');

