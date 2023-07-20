function schema






    c=schema.class(findpackage('sigutils'),'vector');

    p=[...
    schema.prop(c,'Data','MATLAB array');...
    schema.prop(c,'Limit','int32');...
    ];
    p(1).FactoryValue={};
    p(2).FactoryValue=512;
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');

    e=schema.event(c,'VectorChanged');


