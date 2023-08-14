function schema





    pk=findpackage('siggui');

    c=schema.class(pk,'sigcontainer',pk.findclass('siggui'));
    c.Description='abstract';



    p=[...
    schema.prop(c,'NotificationListener','handle.listener vector');...
    ];

    set(p,'AccessFlags.PublicGet','Off','AccessFlags.PublicSet','Off');


