function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'iirlpnormoptsframe',pk.findclass('lpnormoptionsframe'));

    p=schema.prop(c,'InitDen','ustring');
    p.Description=getString(message('signal:sigtools:siggui:InitEstForDenominator'));
    p.FactoryValue='[]';


