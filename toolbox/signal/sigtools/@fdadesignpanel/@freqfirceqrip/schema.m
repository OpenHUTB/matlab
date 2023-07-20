function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'freqfirceqrip',findclass(pk,'abstractfiltertypewfs'));

    findclass(findpackage('siggui'),'firceqripfreqspecs');

    p=schema.prop(c,'freqSpecType','fireqrip_FreqOpts');
    p.SetFunction=@setspectype;
    p.Description='spec';

    p=schema.prop(c,'DynamicSpec','schema.prop');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';

    p=schema.prop(c,'DynamicSpecListener','handle.listener');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';


