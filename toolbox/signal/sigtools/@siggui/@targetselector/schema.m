function schema





    pk=findpackage('siggui');
    c=schema.class(pk,'targetselector',pk.findclass('siggui'));

    p=schema.prop(c,'BoardNumber','ustring');
    set(p,'Description','DSP Board #','FactoryValue','0');

    p=schema.prop(c,'ProcessorNumber','ustring');
    set(p,'Description','DSP Processor #','FactoryValue','0');


