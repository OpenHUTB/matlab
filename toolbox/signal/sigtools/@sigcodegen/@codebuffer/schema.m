function schema





    pk=findpackage('sigcodegen');
    c=schema.class(pk,'codebuffer',pk.findclass('stringbuffer'));
    c.Description='abstract';

    findpackage('sigdatatypes');

    p=spcuddutils.addpostsetprop(c,'Wrap','on/off',@setwrap);
    set(p,'FactoryValue','on');

    p=spcuddutils.addpostsetprop(c,'MaxWidth','spt_uint32',@setmaxwidth);
    set(p,'FactoryValue',75);


