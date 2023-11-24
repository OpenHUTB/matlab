function schema

    pk=findpackage('iatbrowser');

    className='AcquisitionParameterPanelController';
    controllerClass=schema.class(pk,className);
    controllerClass.JavaInterfaces={[pk.JavaPackage,'.',className]};

    javaPeer=schema.prop(controllerClass,'javaPeer','handle vector');
    javaPeer.AccessFlags.PublicSet='off';
    javaPeer.AccessFlags.PublicGet='on';

    schema.prop(controllerClass,'treeNodeListeners','MATLAB array');

    schema.prop(controllerClass,'widgetListeners','handle vector');

    schema.prop(controllerClass,'previewPanelControllerListeners','handle vector');

    schema.prop(controllerClass,'sourcePropertyListeners','handle vector');

    schema.prop(controllerClass,'propertyUpdateTimer','MATLAB array');

    schema.prop(controllerClass,'videoWriterProfile','string');

    schema.prop(controllerClass,'LogFileIndexIncrementProps','MATLAB array');
    schema.prop(controllerClass,'incrementLogFileIndexListener','MATLAB array');

    schema.event(controllerClass,'handleFramesPerTriggerUpdated');

    clearCurrentConfigListenerProp=schema.prop(controllerClass,'clearCurrentConfigListener','handle');
    clearCurrentConfigListenerProp.AccessFlags.PublicSet='off';
    clearCurrentConfigListenerProp.AccessFlags.PublicGet='on';


