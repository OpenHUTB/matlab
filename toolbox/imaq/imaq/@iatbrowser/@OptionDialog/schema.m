function schema






    pk=findpackage('iatbrowser');


    className='OptionDialog';
    dialogClass=schema.class(pk,className);
    dialogClass.JavaInterfaces={[pk.JavaPackage,'.',className]};

    schema.prop(dialogClass,'listeners','handle vector');
