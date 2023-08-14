function schema





    pk=findpackage('iatbrowser');
    parent=pk.findclass('NodeInfoDisplay');

    className='RootNodeInfoDisplay';
    infoClass=schema.class(pk,className,parent);
    infoClass.JavaInterfaces={[pk.JavaPackage,'.',className]};