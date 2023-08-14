function schema





    pk=findpackage('sigutils');

    c=schema.class(pk,'stack');


    p=[schema.prop(c,'Data','MATLAB array');...
    schema.prop(c,'StackLimit','int32')];
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','off');
    set(p(1),'FactoryValue',{});


    e=schema.event(c,'TopChanged');


