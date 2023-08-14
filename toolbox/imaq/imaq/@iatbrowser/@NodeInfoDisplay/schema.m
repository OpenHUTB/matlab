function schema





    pk=findpackage('iatbrowser');

    className='NodeInfoDisplay';
    infoClass=schema.class(pk,className);
    infoClass.JavaInterfaces={[pk.JavaPackage,'.',className]};

    nodeProp=schema.prop(infoClass,'node','MATLAB array');
    nodeProp.AccessFlags.PublicSet='off';
    nodeProp.AccessFlags.PublicGet='off';
