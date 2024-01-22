function schema

    pk=findpackage('fdadesignpanel');
    c=schema.class(pk,'abstractfiltertypewfs',findclass(pk,'abstractfiltertype'));
    c.Description='abstract';
    p=schema.prop(c,'freqUnits','signalFrequencyUnits');
    p.FactoryValue='Hz';
    p.Description='spec';

    p=schema.prop(c,'Fs','ustring');
    p.FactoryValue='48000';
    p.Description='spec';


