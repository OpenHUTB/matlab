function schema

    pk=findpackage('iatbrowser');

    className='PreviewPanelController';
    prevPanelControllerClass=schema.class(pk,className);
    prevPanelControllerClass.JavaInterfaces={[pk.JavaPackage,'.',className]};

    schema.event(prevPanelControllerClass,'PreviewStarting');
    schema.event(prevPanelControllerClass,'PreviewStopping');
    schema.event(prevPanelControllerClass,'StartAcquisition');
    schema.event(prevPanelControllerClass,'DiskLoggingFinished');






    stoppingProp=schema.prop(prevPanelControllerClass,'stopping','MATLAB array');
    stoppingProp.AccessFlags.PublicSet='on';
    stoppingProp.AccessFlags.PublicGet='on';

    restartPreviewProp=schema.prop(prevPanelControllerClass,'restartPreview','MATLAB array');
    restartPreviewProp.AccessFlags.PublicSet='on';
    restartPreviewProp.AccessFlags.PublicGet='on';


    prevPanelProp=schema.prop(prevPanelControllerClass,'prevPanel','MATLAB array');
    prevPanelProp.AccessFlags.PublicSet='off';
    prevPanelProp.AccessFlags.PublicGet='on';



    treeNodeListenersProp=schema.prop(prevPanelControllerClass,'treeNodeListeners','MATLAB array');
    treeNodeListenersProp.AccessFlags.PublicSet='on';
    treeNodeListenersProp.AccessFlags.PublicGet='on';

    aProp=schema.prop(prevPanelControllerClass,'startAcquisitionBtnListener','handle vector');
    aProp.AccessFlags.PublicSet='on';
    aProp.AccessFlags.PublicGet='on';

    aProp=schema.prop(prevPanelControllerClass,'widgetListeners','handle vector');
    aProp.AccessFlags.PublicSet='on';
    aProp.AccessFlags.PublicGet='on';

    acqParamListenerProp=schema.prop(prevPanelControllerClass,'acquisitionParameterListeners','MATLAB array');
    acqParamListenerProp.AccessFlags.PublicSet='off';
    acqParamListenerProp.AccessFlags.PublicGet='on';




    schema.prop(prevPanelControllerClass,'errorFcnHandled','bool');
    errorFcnInProgresProp=schema.prop(prevPanelControllerClass,'errorFcnInProgress','bool');
    errorFcnInProgresProp.AccessFlags.PublicSet='on';

    errorFcnDoneTimerProp=schema.prop(prevPanelControllerClass,'errorFcnDoneTimer','MATLAB array');
    errorFcnDoneTimerProp.AccessFlags.PublicSet='on';

    stopFcnDoneTimerProp=schema.prop(prevPanelControllerClass,'stopFcnDoneTimer','MATLAB array');
    stopFcnDoneTimerProp.AccessFlags.PublicSet='on';

    schema.prop(prevPanelControllerClass,'diskLoggingValidState','bool');
