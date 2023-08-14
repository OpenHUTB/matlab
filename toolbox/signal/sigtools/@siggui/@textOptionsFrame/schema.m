function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'textOptionsFrame',pk.findclass('abstractoptionsframe'));


    p=schema.prop(c,'Text','string vector');
    p.FactoryValue={'',getString(message('signal:sigtools:siggui:NoOptionalParameter'))};


