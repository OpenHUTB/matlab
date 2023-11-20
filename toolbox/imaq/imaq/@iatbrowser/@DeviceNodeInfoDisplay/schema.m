function schema

    pk=findpackage('iatbrowser');
    parent=pk.findclass('NodeInfoDisplay');

    className='DeviceNodeInfoDisplay';
    infoClass=schema.class(pk,className,parent);
    infoClass.JavaInterfaces={[pk.JavaPackage,'.',className]};