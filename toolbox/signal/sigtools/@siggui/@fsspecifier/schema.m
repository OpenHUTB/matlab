function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'fsspecifier',pk.findclass('siggui'));

    p=schema.prop(c,'Units','signalFrequencyUnits');
    p=schema.prop(c,'Value','ustring');
    set(p,'FactoryValue','Fs');


