function[items,layout,slBlkVis]=simrfV2create_filedata_pane(this,...
    slBlkVis,idxMaskNames,varargin)





    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;
    lbutton=19;
    rbutton=number_grid;
    lunit=19;
    runit=number_grid;


    rs=1;

    datasourceprompt=simrfV2GetLeafWidgetBase('text','Data source:',...
    'DataSourcePrompt',0);
    datasourceprompt.RowSpan=[rs,rs];
    datasourceprompt.ColSpan=[lprompt,rprompt];

    datasource=simrfV2GetLeafWidgetBase('combobox','','DataSource',...
    this,'DataSource');
    datasource.Entries=set(this,'DataSource')';
    datasource.RowSpan=[rs,rs];
    datasource.ColSpan=[lwidget,runit];
    datasource.DialogRefresh=1;


    rs=rs+1;

    fileprompt=simrfV2GetLeafWidgetBase('text','Data file:',...
    'FilePrompt',0);
    fileprompt.RowSpan=[rs,rs];
    fileprompt.ColSpan=[lprompt,rprompt];

    file=simrfV2GetLeafWidgetBase('edit','','File',this,'File');
    file.RowSpan=[rs,rs];
    file.ColSpan=[lwidget,rwidget-1];

    browse=simrfV2GetLeafWidgetBase('pushbutton','Browse ...',...
    'Browse',this);
    browse.RowSpan=[rs,rs];
    browse.ColSpan=[lbutton-1,rbutton];
    browse.ObjectMethod='simrfV2browsefile';
    browse.MethodArgs={'%dialog'};
    browse.ArgDataTypes={'handle'};


    rs=rs+1;

    if this.isNetworkObj
        extraChar=':';
    else
        extraChar='';
    end
    isnetworkobj=simrfV2GetLeafWidgetBase('checkbox',...
    ['Network-parameter object',extraChar],'isNetworkObj',...
    this,'isNetworkObj');
    isnetworkobj.RowSpan=[rs,rs];
    isnetworkobj.ColSpan=[lprompt,rprompt];
    isnetworkobj.DialogRefresh=1;

    networkobjectname=simrfV2GetLeafWidgetBase('edit','',...
    'NetworkObject',this,'NetworkObject');
    networkobjectname.RowSpan=[rs,rs];
    networkobjectname.ColSpan=[lwidget,runit];


    if this.isRationalObj
        extraChar=':';
    else
        extraChar=' ';
    end
    isrationalobj=simrfV2GetLeafWidgetBase('checkbox',...
    ['Use rational object',extraChar],'isRationalObj',...
    this,'isRationalObj');
    isrationalobj.RowSpan=[rs,rs];
    isrationalobj.ColSpan=[lprompt,rprompt];
    isrationalobj.DialogRefresh=1;

    rationalobjectname=simrfV2GetLeafWidgetBase('edit','',...
    'RationalObject',this,'RationalObject');
    rationalobjectname.RowSpan=[rs,rs];
    rationalobjectname.ColSpan=[lwidget,runit];


    rs=rs+1;

    Paramtypeprompt=simrfV2GetLeafWidgetBase('text',...
    'Network parameter type:','ParamtypePrompt',0);
    Paramtypeprompt.RowSpan=[rs,rs];
    Paramtypeprompt.ColSpan=[lprompt,rprompt];

    Paramtype=simrfV2GetLeafWidgetBase('combobox','','Paramtype',...
    this,'Paramtype');

    Paramtype.RowSpan=[rs,rs];
    Paramtype.ColSpan=[lwidget,runit];
    Paramtype.DialogRefresh=1;
    Paramtype.MatlabMethod='simrfV2_set_netpar_defaults';
    Paramtype.MatlabArgs={'%dialog'};


    residues=simrfV2GetLeafWidgetBase('edit','','Residues',...
    this,'Residues');
    residues.RowSpan=[rs,rs];
    residues.ColSpan=[lwidget,runit];

    residuesprompt=simrfV2GetLeafWidgetBase('text','Residues:',...
    'ResiduesPrompt',0);
    residuesprompt.RowSpan=[rs,rs];
    residuesprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;

    sparamprompt=simrfV2GetLeafWidgetBase('text','Network-parameters:',...
    'SparamPrompt',0);
    sparamprompt.RowSpan=[rs,rs];
    sparamprompt.ColSpan=[lprompt,rprompt];

    sparam=simrfV2GetLeafWidgetBase('edit','','Sparam',this,'Sparam');
    sparam.RowSpan=[rs,rs];
    sparam.ColSpan=[lwidget,runit];


    polesprompt=simrfV2GetLeafWidgetBase('text','Poles:','PolesPrompt',0);
    polesprompt.RowSpan=[rs,rs];
    polesprompt.ColSpan=[lprompt,rprompt];

    poles=simrfV2GetLeafWidgetBase('edit','','Poles',this,'Poles');
    poles.RowSpan=[rs,rs];
    poles.ColSpan=[lwidget,runit];


    rs=rs+1;

    sparamfreqprompt=simrfV2GetLeafWidgetBase('text','Frequency:',...
    'SparamFreqPrompt',0);
    sparamfreqprompt.RowSpan=[rs,rs];
    sparamfreqprompt.ColSpan=[lprompt,rprompt];

    sparamfreq=simrfV2GetLeafWidgetBase('edit','','SparamFreq',...
    this,'SparamFreq');
    sparamfreq.RowSpan=[rs,rs];
    sparamfreq.ColSpan=[lwidget,lunit-1];

    sparamfrequnit=simrfV2GetLeafWidgetBase('combobox','',...
    'SparamFreq_unit',this,'SparamFreq_unit');
    sparamfrequnit.Entries=set(this,'SparamFreq_unit')';
    sparamfrequnit.RowSpan=[rs,rs];
    sparamfrequnit.ColSpan=[lunit,runit];


    dfprompt=simrfV2GetLeafWidgetBase('text','Direct feedthrough:',...
    'DFPrompt',0);
    dfprompt.RowSpan=[rs,rs];
    dfprompt.ColSpan=[lprompt,rprompt];

    df=simrfV2GetLeafWidgetBase('edit','','DF',this,'DF');
    df.RowSpan=[rs,rs];
    df.ColSpan=[lwidget,runit];


    rs=rs+1;

    sparamz0prompt=simrfV2GetLeafWidgetBase(...
    'text','Reference impedance (Ohm):','SparamZ0Prompt',0);
    sparamz0prompt.RowSpan=[rs,rs];
    sparamz0prompt.ColSpan=[lprompt,rprompt];

    sparamz0=simrfV2GetLeafWidgetBase('edit','',...
    'SparamZ0',this,'SparamZ0');
    sparamz0.RowSpan=[rs,rs];
    sparamz0.ColSpan=[lwidget,runit];


    rs=rs+1;

    addnoise=simrfV2GetLeafWidgetBase('checkbox','Simulate noise',...
    'AddNoise',this,'AddNoise');
    addnoise.RowSpan=[rs,rs];
    addnoise.ColSpan=[lprompt,rwidget];


    rs=rs+1;

    grounding=simrfV2GetLeafWidgetBase(...
    'checkbox','Ground and hide negative terminals',...
    'InternalGrounding',this,'InternalGrounding');
    grounding.RowSpan=[rs,rs];
    grounding.ColSpan=[lprompt,rwidget];


    rs=rs+1;

    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,rprompt];



    file.Visible=0;
    fileprompt.Visible=0;
    browse.Visible=0;
    isnetworkobj.Visible=0;
    networkobjectname.Visible=0;
    sparam.Visible=0;
    sparamprompt.Visible=0;
    sparamfreq.Visible=0;
    sparamfrequnit.Visible=0;
    sparamfreqprompt.Visible=0;
    sparamz0.Visible=0;
    sparamz0prompt.Visible=0;
    isrationalobj.Visible=0;
    rationalobjectname.Visible=0;
    residues.Visible=0;
    residuesprompt.Visible=0;
    poles.Visible=0;
    polesprompt.Visible=0;
    df.Visible=0;
    dfprompt.Visible=0;
    Paramtype.Visible=0;
    Paramtypeprompt.Visible=0;

    addnoise.Visible=1;

    slBlkVis([...
    idxMaskNames.File,idxMaskNames.isNetworkObj...
    ,idxMaskNames.NetworkObject,idxMaskNames.isRationalObj...
    ,idxMaskNames.RationalObject,idxMaskNames.Sparam...
    ,idxMaskNames.SparamFreq,idxMaskNames.SparamFreq_unit...
    ,idxMaskNames.SparamZ0,idxMaskNames.Residues...
    ,idxMaskNames.Poles,idxMaskNames.DF...
    ,idxMaskNames.Paramtype])={'off'};
    slBlkVis([idxMaskNames.DataSource,idxMaskNames.InternalGrounding])=...
    {'on'};

    switch this.DataSource
    case 'Data file'
        file.Visible=1;
        fileprompt.Visible=1;
        browse.Visible=1;
        slBlkVis(idxMaskNames.File)={'on'};
    case 'Network-parameters'
        isnetworkobj.Visible=1;
        slBlkVis([idxMaskNames.isNetworkObj])={'on'};
        if this.isnetworkobj
            networkobjectname.Visible=1;
            slBlkVis([idxMaskNames.NetworkObject])={'on'};
        else
            Paramtype.Visible=1;
            Paramtypeprompt.Visible=1;
            sparam.Visible=1;
            sparamprompt.Visible=1;
            sparamfreq.Visible=1;
            sparamfrequnit.Visible=1;
            sparamfreqprompt.Visible=1;
            sparamz0.Visible=1;
            sparamz0prompt.Visible=1;
            slBlkVis([...
            idxMaskNames.Sparam,idxMaskNames.SparamFreq...
            ,idxMaskNames.SparamFreq_unit,idxMaskNames.SparamZ0...
            ,idxMaskNames.Paramtype])={'on'};
        end
    case 'Rational model'
        isrationalobj.Visible=1;
        slBlkVis([idxMaskNames.isRationalObj])={'on'};
        if this.isrationalobj
            rationalobjectname.Visible=1;
            slBlkVis([idxMaskNames.RationalObject])={'on'};
        else
            residues.Visible=1;
            residuesprompt.Visible=1;
            poles.Visible=1;
            polesprompt.Visible=1;
            df.Visible=1;
            dfprompt.Visible=1;
        end
        slBlkVis([idxMaskNames.Residues,idxMaskNames.Poles...
        ,idxMaskNames.DF])={'on'};
    end


    uData=get_param(get_param(this,'Handle'),'UserData');
    if isfield(uData,'NumPorts')&&uData.NumPorts>8
        addnoise.Visible=0;
    end


    items={datasource,datasourceprompt,isnetworkobj,networkobjectname,...
    sparam,sparamprompt,sparamfreq,sparamfrequnit,sparamz0,...
    sparamz0prompt,sparamfreqprompt,file,fileprompt,browse,...
    isrationalobj,rationalobjectname,residues,residuesprompt,poles,...
    polesprompt,df,dfprompt,addnoise,grounding,spacerMain,...
    Paramtype,Paramtypeprompt};

    layout.LayoutGrid=[rs,number_grid];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,rs-1),1];

end

