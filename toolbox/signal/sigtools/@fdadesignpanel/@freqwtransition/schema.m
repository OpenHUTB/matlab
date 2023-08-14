function schema





    pk=findpackage('fdadesignpanel');

    c=schema.class(pk,'freqwtransition',pk.findclass('abstractfreqwbw'));
    c.Description='abstract';

    p=schema.prop(c,'Rolloff','ustring');
    p.FactoryValue='.25';
    p.Description='spec';


