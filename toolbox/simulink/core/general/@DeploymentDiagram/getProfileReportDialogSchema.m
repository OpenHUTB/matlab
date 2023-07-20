function dlgstruct=getProfileReportDialogSchema(h,name)%#ok




    fileName=fullfile(pwd,[h.ParentDiagram,'_ProfileReport.html']);
    row=1;
    desc={};


    bdH=h.ParentDiagram;

    explicitParitioning=strcmp(get_param(bdH,...
    'ExplicitPartitioning'),'on');

    stfName=get_param(bdH,'SystemTargetFile');
    stfOptionEG=strcmp(stfName,'ert.tlc')||strcmp(stfName,'grt.tlc');

    stfOptionXPC=strcmp(stfName,'slrealtime.tlc');
    stfOptionIDE=strcmp(stfName,'idelink_ert.tlc')||...
    strcmp(stfName,'idelink_grt.tlc');

    reportStatus=explicitParitioning&stfOptionEG;


    profileGenStatus=h.ProfileGenCode;


    buttonGenDisable=DeploymentDiagram.isTaskConfigurationInUse(h);


    numStepsTxt.Name=DAStudio.message(...
    'Simulink:taskEditor:GenerateProfileNumSteps');
    numStepsTxt.Type='text';
    numStepsTxt.RowSpan=[1,1];
    numStepsTxt.ColSpan=[1,1];

    numStepsEdit.Name='';
    numStepsEdit.Type='edit';
    numStepsEdit.ObjectProperty='ProfileNumSamples';
    numStepsEdit.Source=h;
    numStepsEdit.Tag='edit_numStepsProfile';
    numStepsEdit.Enabled=reportStatus&&~profileGenStatus;
    numStepsEdit.RowSpan=[1,1];
    numStepsEdit.ColSpan=[2,2];
    numStepsTxt.Buddy=numStepsEdit.Tag;

    numPanel.Name='';
    numPanel.Type='panel';
    numPanel.Items={numStepsTxt,numStepsEdit};
    numPanel.LayoutGrid=[1,2];



    generateProfileText.Name=DAStudio.message(...
    'Simulink:taskEditor:GenerateProfileText');
    generateProfileText.Type='text';
    generateProfileText.Tag='text_generateProfile';
    generateProfileText.RowSpan=[1,1];
    generateProfileText.ColSpan=[1,1];

    button_generateProfile.Type='pushbutton';
    button_generateProfile.Name='';
    button_generateProfile.Tag='button_generateProfile';
    button_generateProfile.WidgetId='button_generateProfile';
    button_generateProfile.Enabled=reportStatus&&~profileGenStatus&&~buttonGenDisable;
    button_generateProfile.MatlabMethod='DeploymentDiagram.callbackFunction';
    button_generateProfile.MatlabArgs={'generateProfile','%dialog'};
    button_generateProfile.ToolTip=DAStudio.message(...
    'Simulink:taskEditor:GenerateProfileButtonToolTip');
    button_generateProfile.FilePath=DeploymentDiagram.colorUtil(...
    'getProfileReportIconPath');
    button_generateProfile.MinimumSize=[37,26];
    button_generateProfile.MaximumSize=[37,26];
    button_generateProfile.RowSpan=[1,1];
    button_generateProfile.ColSpan=[2,2];

    buttonPanel.Name='';
    buttonPanel.Type='panel';
    buttonPanel.Items={generateProfileText,...
    button_generateProfile};
    buttonPanel.LayoutGrid=[1,2];
    buttonPanel.Alignment=1;

    buttonGrp.Name='';
    buttonGrp.Type='group';
    buttonGrp.Items={numPanel,buttonPanel};
    buttonGrp.LayoutGrid=[2,1];
    buttonGrp.ColStretch=1;




    mapId=['mapkey:',class(h)];
    dlgstruct.DialogTitle=DAStudio.message(...
    'Simulink:taskEditor:GenerateProfileTitle');
    dlgstruct.Items={buttonGrp};
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={mapId,'help_button','CSHelpWindow'};
    dlgstruct.StandaloneButtonSet={''};






    description.Type='group';
    description.Name='';
    description.Items={};

    reportGrp.Name='';
    reportGrp.Type='panel';
    reportGrp.Items={};




    if(reportStatus&&exist(fileName,'file'))


        desc.Url=['file:///',fileName];
        desc.Name='profileReport';
        desc.Type='webbrowser';
        desc.WebKit=true;
        desc.ObjectProperty='stringProp';
        desc.Tag='profileTag';

        [indexedItems,layout]=...
        slprivate('getIndexedGroupItems',1,{...
        desc});

    else


        textArea.Type='text';
        textArea.WordWrap=true;
        textArea.Visible=true;
        textArea.Tag='noProfileReport_tag';


        infoLink.Type='hyperlink';
        infoLink.Name=DAStudio.message(...
        'Simulink:taskEditor:ExternalProfilerHelp');
        infoLink.MatlabMethod='helpview';

        if reportStatus



            textArea.Name=DAStudio.message(...
            'Simulink:taskEditor:NoProfileReportFoundRegenerate');

            infoLink.Visible=false;
        else




            if stfOptionXPC
                infoLink.Visible=true;
                infoLink.MatlabArgs={fullfile(docroot,'xpc','xpc.map'),...
                'xpc_profiler'};
            elseif stfOptionIDE
                infoLink.Visible=true;
                infoLink.MatlabArgs={fullfile(docroot,'toolbox','ecoder',...
                'helptargets.map'),'embedded_tgt_profiling'};
            else
                infoLink.Visible=false;
            end


            if stfOptionXPC||stfOptionIDE

                textArea.Name=DAStudio.message(...
                'Simulink:taskEditor:UseExternalProfiler',['''',stfName,'''']);
            else

                textArea.Name=DAStudio.message(...
                'Simulink:taskEditor:NoProfileReportFound');
            end


        end
        row=row+1;
        [indexedItems,layout]=...
        slprivate('getIndexedGroupItems',1,{...
        textArea,infoLink});
    end

    reportGrp.Items=indexedItems;
    reportGrp.LayoutGrid=layout;

    description.Flat=true;
    description.LayoutGrid=[row,1];
    description.RowSpan=[row,1];
    description.Visible=1;
    description.Items={reportGrp};
    row=row+1;

    dlgstruct.Items{end+1}=description;
    dlgstruct.LayoutGrid=[row,1];
    dlgstruct.RowStretch=[zeros(1,row-1),1];
    dlgstruct.IsScrollable=false;




