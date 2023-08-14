function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'sidebar',pk.findclass('sigcontainer'));


    p=schema.prop(c,'CurrentPanel','int32');

    p=[schema.prop(c,'Constructors','MATLAB array');...
    schema.prop(c,'Labels','string vector')];

    p(1).FactoryValue={};
    p(2).FactoryValue={};

    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');


