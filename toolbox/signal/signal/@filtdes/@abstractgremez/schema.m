function schema





    pk=findpackage('filtdes');

    c=schema.class(pk,'abstractgremez',pk.findclass('remez'));
    c.Description='abstract';

    if isempty(findtype('gremezPhase'))
        schema.EnumType('gremezPhase',{'Linear','Minimum','Maximum'});
    end
    schema.prop(c,'Phase','gremezPhase');

    if isempty(findtype('gremezFIRType'))
        schema.EnumType('gremezFIRType',{'Unspecified','1','2','3','4'});
    end


