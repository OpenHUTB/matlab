function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'abstractDesignMethodwFs',findclass(pk,'abstractDesignMethod'));
    c.description='abstract';


    p=schema.prop(c,'freqUnits','signalFrequencyUnits');
    p.FactoryValue='Hz';


    p=schema.prop(c,'freqUnitsListener','handle.listener');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';

