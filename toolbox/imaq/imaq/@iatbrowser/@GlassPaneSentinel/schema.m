function schema





    pk=findpackage('iatbrowser');


    className='GlassPaneSentinel';
    sentinelClass=schema.class(pk,className);
    sentinelClass.JavaInterfaces={[pk.JavaPackage,'.',className]};

    listenerProp=schema.prop(sentinelClass,'listener','handle');
    listenerProp.AccessFlags.PublicSet='off';
    listenerProp.AccessFlags.PublicGet='off';
