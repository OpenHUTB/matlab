function schema





    c=schema.class(findpackage('sigcodegen'),'stringbuffer');


    p=schema.prop(c,'buffer','mxArray');
    set(p,'FactoryValue',{},'AccessFlags.Init','on','AccessFlags.PublicSet','Off',...
    'Description','Cell array storing string buffer contents');


