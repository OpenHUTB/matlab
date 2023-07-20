function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'coeffspecifier',pk.findclass('siggui'));


    p=[...
    schema.prop(c,'Labels','MATLAB array');...
    schema.prop(c,'AllStructures','MATLAB array');...
    ];
    set(p,'AccessFlags.PublicGet','Off','AccessFlags.PublicSet','Off');


    p=[...
    schema.prop(c,'Coefficients','MATLAB array');...
    schema.prop(c,'SelectedStructure','ustring');...
    schema.prop(c,'SOS','on/off');...
    ];

    p(3).GetFunction=@getsos;


