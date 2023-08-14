function schema





    pk=findpackage('siggui');

    c=schema.class(pk,'exportheader',pk.findclass('actionclosedlg'));


    schema.prop(c,'Filter','MATLAB array');
    p=schema.prop(c,'Filename','ustring');

    set(p,'FactoryValue','fdacoefs.h');

    pk.findclass('varsinheader');
    pk.findclass('datatypeselector');


    p=[...
    schema.prop(c,'Listeners','handle.listener vector');...
    ];

    set(p,'AccessFlag.PublicSet','Off','AccessFlag.PublicGet','Off');


