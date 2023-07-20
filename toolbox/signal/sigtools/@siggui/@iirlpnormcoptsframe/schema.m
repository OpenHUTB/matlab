function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'iirlpnormcoptsframe',pk.findclass('iirlpnormoptsframe'));


    p=schema.prop(c,'MaxPoleRadius','ustring');
    p.FactoryValue='.92';



