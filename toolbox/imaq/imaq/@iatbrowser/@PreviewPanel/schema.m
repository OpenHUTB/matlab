function schema





    pk=findpackage('iatbrowser');


    className='PreviewPanel';
    previewClass=schema.class(pk,className);
    previewClass.JavaInterfaces={[pk.JavaPackage,'.',className]};




    dataProp=schema.prop(previewClass,'data','MATLAB array');
    dataProp.AccessFlags.PublicSet='on';
    dataProp.AccessFlags.PublicGet='on';


    figProp=schema.prop(previewClass,'fig','MATLAB array');
    figProp.AccessFlags.PublicSet='off';
    figProp.AccessFlags.PublicGet='on';


    imageProp=schema.prop(previewClass,'image','MATLAB array');
    imageProp.AccessFlags.PublicSet='off';
    imageProp.AccessFlags.PublicGet='on';


    schema.prop(previewClass,'imWidth','double');
    schema.prop(previewClass,'imHeight','double');


    axisProp=schema.prop(previewClass,'axis','MATLAB array');
    axisProp.AccessFlags.PublicSet='off';
    axisProp.AccessFlags.PublicGet='on';


    statLabelProp=schema.prop(previewClass,'statLabel','MATLAB array');
    statLabelProp.AccessFlags.PublicSet='off';
    statLabelProp.AccessFlags.PublicGet='on';


    timeLabelProp=schema.prop(previewClass,'timeLabel','MATLAB array');
    timeLabelProp.AccessFlags.PublicSet='off';
    timeLabelProp.AccessFlags.PublicGet='on';


    frameRateLabelProp=schema.prop(previewClass,'frameRateLabel','MATLAB array');
    frameRateLabelProp.AccessFlags.PublicSet='off';
    frameRateLabelProp.AccessFlags.PublicGet='on';


    previewingProp=schema.prop(previewClass,'previewing','MATLAB array');
    previewingProp.AccessFlags.PublicSet='off';
    previewingProp.AccessFlags.PublicGet='on';


    prevPanelButtonPanelProp=schema.prop(previewClass,'prevPanelButtonPanel','handle vector');
    prevPanelButtonPanelProp.AccessFlags.PublicSet='off';
    prevPanelButtonPanelProp.AccessFlags.PublicGet='on';

    aProp=schema.prop(previewClass,'prevPanelButtonPanelContainer','MATLAB array');
    aProp.AccessFlags.PublicSet='off';
    aProp.AccessFlags.PublicGet='on';

    toolTipProp=schema.prop(previewClass,'toolTip','MATLAB array');
    toolTipProp.AccessFlags.PublicSet='on';
    toolTipProp.AccessFlags.PublicGet='on';

    helpTextProp=schema.prop(previewClass,'helpText','MATLAB array');
    helpTextProp.AccessFlags.PublicSet='on';
    helpTextProp.AccessFlags.PublicGet='on';

    aProp=schema.prop(previewClass,'destructor','handle');
    aProp.AccessFlags.PublicSet='off';
    aProp.AccessFlags.PublicGet='off';
