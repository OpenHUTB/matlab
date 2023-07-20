function schema






    pk=findpackage('iatbrowser');


    className='MessageDialog';
    dialogClass=schema.class(pk,className);
    dialogClass.JavaInterfaces={[pk.JavaPackage,'.',className]};

    schema.prop(dialogClass,'listener','handle vector');
