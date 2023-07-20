function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'firceqripinvsincoptsframe',pk.findclass('firceqripoptsframe'));


    p=schema.prop(c,'invSincFreqFactor','ustring');
    p.Description='The value of c in the equation 1/sinc(c*f)^p. [c < 1/wo]:';
    p.FactoryValue='1';


    p=schema.prop(c,'invSincPower','ustring');
    p.Description='The value of p in the equation 1/sinc(c*f)^p:';
    p.FactoryValue='1';


