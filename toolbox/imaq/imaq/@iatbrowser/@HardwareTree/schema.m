function schema





    pk=findpackage('iatbrowser');


    className='HardwareTree';
    hardwareTreeClass=schema.class(pk,className);
    hardwareTreeClass.JavaInterfaces={[pk.JavaPackage,'.',className]};


    javaPeerProp=schema.prop(hardwareTreeClass,'javaPeer','handle vector');
    javaPeerProp.AccessFlags.PublicSet='off';
    javaPeerProp.AccessFlags.PublicGet='on';


    javaTreePeerProp=schema.prop(hardwareTreeClass,'javaTreePeer','handle vector');
    javaTreePeerProp.AccessFlags.PublicSet='off';
    javaTreePeerProp.AccessFlags.PublicGet='on';


    rootNodeProp=schema.prop(hardwareTreeClass,'rootNode','MATLAB array');
    rootNodeProp.AccessFlags.PublicSet='off';


    currentNodeProp=schema.prop(hardwareTreeClass,'currentNode','MATLAB array');
    currentNodeProp.AccessFlags.PublicGet='on';



    abortNodeSelectionChangeProp=schema.prop(hardwareTreeClass,'abortNodeSelectionChange','bool');%#ok<NASGU>


    nodeSelectedListenerProp=schema.prop(hardwareTreeClass,'treeNodeSelectedListener','MATLAB array');


    nodeSelectedListenerProp.AccessFlags.PublicSet='on';
    nodeSelectedListenerProp.AccessFlags.PublicGet='on';

    formatAddedProp=schema.prop(hardwareTreeClass,'formatNodeAddedListener','MATLAB array');


    formatAddedProp.AccessFlags.PublicSet='on';
    formatAddedProp.AccessFlags.PublicGet='on';


    exportHWConfigListenerProp=schema.prop(hardwareTreeClass,'exportHWConfigListener','handle');
    exportHWConfigListenerProp.AccessFlags.PublicSet='off';
    exportHWConfigListenerProp.AccessFlags.PublicGet='on';


    exportSelectedHWConfigListenerProp=schema.prop(hardwareTreeClass,'exportSelectedHWConfigListener','handle');
    exportSelectedHWConfigListenerProp.AccessFlags.PublicSet='off';
    exportSelectedHWConfigListenerProp.AccessFlags.PublicGet='on';


    exportMFileListenerProp=schema.prop(hardwareTreeClass,'exportMFileListenerProp','handle');
    exportMFileListenerProp.AccessFlags.PublicSet='off';
    exportMFileListenerProp.AccessFlags.PublicGet='on';


    saveConfigListenerProp=schema.prop(hardwareTreeClass,'saveConfigListener','handle');
    saveConfigListenerProp.AccessFlags.PublicSet='off';
    saveConfigListenerProp.AccessFlags.PublicGet='on';

    saveButtonsListenerProp=schema.prop(hardwareTreeClass,'saveButtonsListener','handle vector');
    saveButtonsListenerProp.AccessFlags.PublicSet='off';
    saveButtonsListenerProp.AccessFlags.PublicGet='on';


    openConfigListenerProp=schema.prop(hardwareTreeClass,'openConfigListener','handle');
    openConfigListenerProp.AccessFlags.PublicSet='off';
    openConfigListenerProp.AccessFlags.PublicGet='on';


    theProp=schema.prop(hardwareTreeClass,'preferencesListener','handle');
    theProp.AccessFlags.PublicSet='off';
    theProp.AccessFlags.PublicGet='on';


    refreshingProp=schema.prop(hardwareTreeClass,'refreshing','bool');
    refreshingProp.AccessFlags.PublicSet='on';
    refreshingProp.AccessFlags.PublicGet='on';
