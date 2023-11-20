function schema

    pk=findpackage('iatbrowser');

    className='InfoPanelController';
    controllerClass=schema.class(pk,className);
    controllerClass.JavaInterfaces={[pk.JavaPackage,'.',className]};
    javaPeer=schema.prop(controllerClass,'javaPeer','handle vector');
    javaPeer.AccessFlags.PublicSet='off';
    javaPeer.AccessFlags.PublicGet='on';

    aProp=schema.prop(controllerClass,'treeNodeListeners','MATLAB array');
    aProp.AccessFlags.PublicSet='on';
    aProp.AccessFlags.PublicGet='on';

    aProp=schema.prop(controllerClass,'sourcePropertyChangedListener','MATLAB array');
    aProp.AccessFlags.PublicSet='on';
    aProp.AccessFlags.PublicGet='on';

    aProp=schema.prop(controllerClass,'videoinputPropertyChangedListener','MATLAB array');
    aProp.AccessFlags.PublicSet='on';
    aProp.AccessFlags.PublicGet='on';
