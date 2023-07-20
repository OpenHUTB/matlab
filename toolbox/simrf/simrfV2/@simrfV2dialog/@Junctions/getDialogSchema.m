function dlgStruct=getDialogSchema(this,~)







    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;


    runit=20;






    rs=1;















    rs=rs+1;
    devicecirculatorprompt=simrfV2GetLeafWidgetBase('text',...
    'Select component:','DeviceCirculatorprompt',0);
    devicecirculatorprompt.RowSpan=[rs,rs];
    devicecirculatorprompt.ColSpan=[lprompt,rprompt];

    devicecirculator=simrfV2GetLeafWidgetBase('combobox','',...
    'DeviceCirculator',this,'DeviceCirculator');
    devicecirculator.Entries=set(this,'DeviceCirculator');
    devicecirculator.RowSpan=[rs,rs];
    devicecirculator.ColSpan=[ledit,runit];
    devicecirculator.DialogRefresh=1;




    devicedividerprompt=simrfV2GetLeafWidgetBase('text',...
    'Select component:','DeviceDividerprompt',0);
    devicedividerprompt.RowSpan=[rs,rs];
    devicedividerprompt.ColSpan=[lprompt,rprompt];

    devicedivider=simrfV2GetLeafWidgetBase('combobox','',...
    'DeviceDivider',this,'DeviceDivider');
    devicedivider.Entries=set(this,'DeviceDivider');
    devicedivider.RowSpan=[rs,rs];
    devicedivider.ColSpan=[ledit,runit];
    devicedivider.DialogRefresh=1;




    devicecouplerprompt=simrfV2GetLeafWidgetBase('text',...
    'Select component:','DeviceCouplerprompt',0);
    devicecouplerprompt.RowSpan=[rs,rs];
    devicecouplerprompt.ColSpan=[lprompt,rprompt];

    devicecoupler=simrfV2GetLeafWidgetBase('combobox','',...
    'DeviceCoupler',this,'DeviceCoupler');
    devicecoupler.Entries=set(this,'DeviceCoupler');
    devicecoupler.RowSpan=[rs,rs];
    devicecoupler.ColSpan=[ledit,runit];
    devicecoupler.DialogRefresh=1;




    rs=rs+1;
    phase12prompt=simrfV2GetLeafWidgetBase(...
    'text','Phase shift, ports 1 and 2 (rad):','Phase12Prompt',0);
    phase12prompt.RowSpan=[rs,rs];
    phase12prompt.ColSpan=[lprompt,rprompt];

    phase12=simrfV2GetLeafWidgetBase('edit','',...
    'Phase12',this,'Phase12');
    phase12.RowSpan=[rs,rs];
    phase12.ColSpan=[ledit,runit];




    rs=rs+1;
    phase33prompt=simrfV2GetLeafWidgetBase(...
    'text','Phase shift, port 3 (rad):','Phase33Prompt',0);
    phase33prompt.RowSpan=[rs,rs];
    phase33prompt.ColSpan=[lprompt,rprompt];

    phase33=simrfV2GetLeafWidgetBase('edit','',...
    'Phase33',this,'Phase33');
    phase33.RowSpan=[rs,rs];
    phase33.ColSpan=[ledit,runit];




    rs=rs+1;
    couplingprompt=simrfV2GetLeafWidgetBase(...
    'text','Coupling (dB):','CouplingPrompt',0);
    couplingprompt.RowSpan=[rs,rs];
    couplingprompt.ColSpan=[lprompt,rprompt];

    coupling=simrfV2GetLeafWidgetBase('edit','',...
    'Coupling',this,'Coupling');
    coupling.RowSpan=[rs,rs];
    coupling.ColSpan=[ledit,runit];




    rs=rs+1;
    numberdivideroutportsprompt=simrfV2GetLeafWidgetBase(...
    'text','Number of divider outports:','NumberDividerOutportsPrompt',0);
    numberdivideroutportsprompt.RowSpan=[rs,rs];
    numberdivideroutportsprompt.ColSpan=[lprompt,rprompt];

    numberdivideroutports=simrfV2GetLeafWidgetBase('edit','',...
    'NumberDividerOutports',this,'NumberDividerOutports');
    numberdivideroutports.RowSpan=[rs,rs];
    numberdivideroutports.ColSpan=[ledit,runit];




    rs=rs+1;
    directivityprompt=simrfV2GetLeafWidgetBase(...
    'text','Directivity (dB):','DirectivityPrompt',0);
    directivityprompt.RowSpan=[rs,rs];
    directivityprompt.ColSpan=[lprompt,rprompt];

    directivity=simrfV2GetLeafWidgetBase('edit','',...
    'Directivity',this,'Directivity');
    directivity.RowSpan=[rs,rs];
    directivity.ColSpan=[ledit,runit];




    rs=rs+1;
    insertionlossprompt=simrfV2GetLeafWidgetBase(...
    'text','Insertion loss (dB):','InsertionLossPrompt',0);
    insertionlossprompt.RowSpan=[rs,rs];
    insertionlossprompt.ColSpan=[lprompt,rprompt];

    insertionloss=simrfV2GetLeafWidgetBase('edit','',...
    'InsertionLoss',this,'InsertionLoss');
    insertionloss.RowSpan=[rs,rs];
    insertionloss.ColSpan=[ledit,runit];




    rs=rs+1;
    returnlossprompt=simrfV2GetLeafWidgetBase(...
    'text','Return loss (dB):','ReturnLossPrompt',0);
    returnlossprompt.RowSpan=[rs,rs];
    returnlossprompt.ColSpan=[lprompt,rprompt];

    returnloss=simrfV2GetLeafWidgetBase('edit','',...
    'ReturnLoss',this,'ReturnLoss');
    returnloss.RowSpan=[rs,rs];
    returnloss.ColSpan=[ledit,runit];




    rs=rs+1;
    alphaprompt=simrfV2GetLeafWidgetBase(...
    'text','Power transmission coefficient:','AlphaPrompt',0);
    alphaprompt.RowSpan=[rs,rs];
    alphaprompt.ColSpan=[lprompt,rprompt];

    alpha=simrfV2GetLeafWidgetBase('edit','','Alpha',this,'Alpha');
    alpha.RowSpan=[rs,rs];
    alpha.ColSpan=[ledit,runit];




    rs=rs+1;
    sparamZ0prompt=simrfV2GetLeafWidgetBase(...
    'text','Reference impedances (Ohm):','SparamZ0Prompt',0);
    sparamZ0prompt.RowSpan=[rs,rs];
    sparamZ0prompt.ColSpan=[lprompt,rprompt];

    sparamZ0=simrfV2GetLeafWidgetBase('edit','',...
    'SparamZ0',this,'SparamZ0');
    sparamZ0.RowSpan=[rs,rs];
    sparamZ0.ColSpan=[ledit,runit];




    rs=rs+1;
    switch this.Block.classname
    case 'circulators'
        currentDevice=this.DeviceCirculator;
        devicecirculatorprompt.Visible=1;
        devicecirculator.Visible=1;
        devicedividerprompt.Visible=0;
        devicedivider.Visible=0;
        devicecouplerprompt.Visible=0;
        devicecoupler.Visible=0;
    case 'dividers'
        currentDevice=this.DeviceDivider;
        devicecirculatorprompt.Visible=0;
        devicecirculator.Visible=0;
        devicedividerprompt.Visible=1;
        devicedivider.Visible=1;
        devicecouplerprompt.Visible=0;
        devicecoupler.Visible=0;
    case 'couplers'
        currentDevice=this.DeviceCoupler;
        devicecirculatorprompt.Visible=0;
        devicecirculator.Visible=0;
        devicedividerprompt.Visible=0;
        devicedivider.Visible=0;
        devicecouplerprompt.Visible=1;
        devicecoupler.Visible=1;
    end

    fname=[lower(regexprep(currentDevice,'[- ()=]','')),'.png'];
    imagepath=fullfile(matlabroot,'toolbox','simrf','simrfV2',...
    '@simrfV2dialog','@Junctions','private');
    junctionimage.Name='...';
    junctionimage.Type='image';
    junctionimage.Tag='junctionimage';
    junctionimage.RowSpan=[rs,rs+3];
    junctionimage.ColSpan=[lprompt,runit];
    junctionimage.Alignment=6;
    junctionimage.FilePath=fullfile(imagepath,fname);




    rs=rs+4;
    grounding=simrfV2GetLeafWidgetBase('checkbox',...
    'Ground and hide negative terminals','InternalGrounding',...
    this,'InternalGrounding');
    grounding.RowSpan=[rs,rs];
    grounding.ColSpan=[lprompt,runit];




    rs=rs+1;
    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,rprompt];



    hBlk=get_param(this,'Handle');
    slBlkVis=get_param(hBlk,'MaskVisibilities');
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);

    slBlkVis([...
    idxMaskNames.Phase12,idxMaskNames.Phase33...
    ,idxMaskNames.Coupling,idxMaskNames.Directivity...
    ,idxMaskNames.InsertionLoss,idxMaskNames.ReturnLoss...
    ,idxMaskNames.Alpha,idxMaskNames.NumberDividerOutports...
    ])={'off'};
    phase12prompt.Visible=0;
    phase12.Visible=0;
    phase33prompt.Visible=0;
    phase33.Visible=0;
    couplingprompt.Visible=0;
    coupling.Visible=0;
    numberdivideroutportsprompt.Visible=0;
    numberdivideroutports.Visible=0;
    directivityprompt.Visible=0;
    directivity.Visible=0;
    insertionlossprompt.Visible=0;
    insertionloss.Visible=0;
    returnlossprompt.Visible=0;
    returnloss.Visible=0;
    alphaprompt.Visible=0;
    alpha.Visible=0;
    switch currentDevice
    case 'Reciprocal phase shifter'
        phase12prompt.Visible=1;
        phase12.Visible=1;
        phase33prompt.Visible=1;
        phase33.Visible=1;
        slBlkVis([idxMaskNames.Phase12,idxMaskNames.Phase33])={'on'};
    case 'Wilkinson power divider'
        numberdivideroutportsprompt.Visible=1;
        numberdivideroutports.Visible=1;
        slBlkVis([idxMaskNames.NumberDividerOutports])={'on'};
    case 'Directional coupler'
        couplingprompt.Visible=1;
        coupling.Visible=1;
        directivityprompt.Visible=1;
        directivity.Visible=1;
        insertionlossprompt.Visible=1;
        insertionloss.Visible=1;
        returnlossprompt.Visible=1;
        returnloss.Visible=1;
        slBlkVis([...
        idxMaskNames.Coupling,idxMaskNames.Directivity...
        ,idxMaskNames.InsertionLoss,idxMaskNames.ReturnLoss])...
        ={'on'};
    case{'Coupler symmetrical','Coupler antisymmetrical'}
        alphaprompt.Visible=1;
        alpha.Visible=1;
        slBlkVis([idxMaskNames.Alpha])={'on'};
    end


    if~strcmpi(get_param(bdroot(hBlk),'Lock'),'on')
        set_param(hBlk,'MaskVisibilities',slBlkVis);
    end



    mainParamsPanel.Type='group';

    mainParamsPanel.Tag='mainParamsPanel';
    mainParamsPanel.Items={...
    devicecirculatorprompt,devicecirculator,...
    devicedividerprompt,devicedivider,...
    devicecouplerprompt,devicecoupler,...
    numberdivideroutportsprompt,numberdivideroutports,...
    phase12prompt,phase12,...
    phase33prompt,phase33,...
    couplingprompt,coupling...
    ,directivityprompt,directivity...
    ,insertionlossprompt,insertionloss...
    ,returnlossprompt,returnloss...
    ,alphaprompt,alpha,...
    sparamZ0prompt,sparamZ0,...
    junctionimage,grounding,spacerMain};
    mainParamsPanel.LayoutGrid=[rs,runit];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];




    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);
end

