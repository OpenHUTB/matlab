function schema





    pk=findpackage('iatbrowser');


    className='Browser';
    browserClass=schema.class(pk,className);
    browserClass.JavaInterfaces={[pk.JavaPackage,'.',className]};


    messageBusProp=schema.prop(browserClass,'messageBus','MATLAB array');
    messageBusProp.AccessFlags.PublicSet='on';
    messageBusProp.AccessFlags.PublicGet='on';


    vidObjProp=schema.prop(browserClass,'currentVideoinputObject','MATLAB array');
    vidObjProp.AccessFlags.PublicSet='on';
    vidObjProp.AccessFlags.PublicGet='on';


    theProp=schema.prop(browserClass,'isRefreshingHardware','bool');
    theProp.AccessFlags.PublicSet='on';
    theProp.AccessFlags.PublicGet='on';


    treePanelProp=schema.prop(browserClass,'treePanel','handle vector');
    treePanelProp.AccessFlags.PublicSet='off';
    treePanelProp.AccessFlags.PublicGet='on';

    infoPanelProp=schema.prop(browserClass,'infoPanel','handle vector');
    infoPanelProp.AccessFlags.PublicSet='off';
    infoPanelProp.AccessFlags.PublicGet='on';

    acqParamPanelProp=schema.prop(browserClass,'acqParamPanel','handle vector');
    acqParamPanelProp.AccessFlags.PublicSet='off';
    acqParamPanelProp.AccessFlags.PublicGet='on';

    prevPanelControllerProp=schema.prop(browserClass,'prevPanelController','handle vector');
    prevPanelControllerProp.AccessFlags.PublicSet='on';
    prevPanelControllerProp.AccessFlags.PublicGet='on';

    sessionLogControllerProp=schema.prop(browserClass,'sessionLogPanelController','MATLAB array');
    sessionLogControllerProp.AccessFlags.PublicSet='on';
    sessionLogControllerProp.AccessFlags.PublicGet='on';


    aProp=schema.prop(browserClass,'roiGUIElementsController','MATLAB array');
    aProp.AccessFlags.PublicSet='on';
    aProp.AccessFlags.PublicGet='on';


    supportListenerProp=schema.prop(browserClass,'supportListener','handle');
    supportListenerProp.AccessFlags.PublicSet='off';
    supportListenerProp.AccessFlags.PublicGet='on';

    demosListenerProp=schema.prop(browserClass,'demosListener','handle');
    demosListenerProp.AccessFlags.PublicSet='off';
    demosListenerProp.AccessFlags.PublicGet='on';

    toolboxHelpListenerProp=schema.prop(browserClass,'toolboxHelpListener','handle');
    toolboxHelpListenerProp.AccessFlags.PublicSet='off';
    toolboxHelpListenerProp.AccessFlags.PublicGet='on';

    desktopListenerProp=schema.prop(browserClass,'desktopHelpListener','handle');
    desktopListenerProp.AccessFlags.PublicSet='off';
    desktopListenerProp.AccessFlags.PublicGet='on';


    closeListenerProp=schema.prop(browserClass,'closeListener','handle');
    closeListenerProp.AccessFlags.PublicSet='off';
    closeListenerProp.AccessFlags.PublicGet='on';


    theProp=schema.prop(browserClass,'reopenListener','handle');
    theProp.AccessFlags.PublicSet='on';
    theProp.AccessFlags.PublicGet='on';


    refreshListenerProp=schema.prop(browserClass,'refreshListener','handle');
    refreshListenerProp.AccessFlags.PublicSet='off';
    refreshListenerProp.AccessFlags.PublicGet='on';


    theProp=schema.prop(browserClass,'imaqregisterListener','handle');
    theProp.AccessFlags.PublicSet='off';
    theProp.AccessFlags.PublicGet='on';


    schema.prop(browserClass,'isClosing','bool');
