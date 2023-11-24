function schema

    pk=findpackage('iatbrowser');
    handlePackage=findpackage('handle');

    parentClass=handlePackage.findclass('EventData');

    className='PreviewStartingEventData';
    eventDataClass=schema.class(pk,className,parentClass);
    eventDataClass.JavaInterfaces={[pk.JavaPackage,'.',className]};

    aProp=schema.prop(eventDataClass,'acquisitionStarting','bool');
    aProp.AccessFlags.PublicSet='off';

