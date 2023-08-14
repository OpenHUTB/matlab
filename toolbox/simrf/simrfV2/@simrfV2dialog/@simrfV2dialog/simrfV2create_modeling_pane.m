function[items,layout,slBlkVis]=simrfV2create_modeling_pane(this,...
    slBlkVis,idxMaskNames,varargin)








    lprompt=1;
    rprompt=8;
    lwidget=rprompt+1;
    rwidget=18;
    lunit=rwidget+1;
    runit=20;
    number_grid=20;


    rs=1;

    sparam_representation_prompt=simrfV2GetLeafWidgetBase(...
    'text','Modeling options:','SparamRepresentationPrompt',0);
    sparam_representation_prompt.RowSpan=[rs,rs];
    sparam_representation_prompt.ColSpan=[lprompt,rprompt];

    sparam_representation=simrfV2GetLeafWidgetBase('combobox','',...
    'SparamRepresentation',this,'SparamRepresentation');
    sparam_representation.RowSpan=[rs,rs];
    sparam_representation.ColSpan=[lwidget,runit];
    sparam_representation.DialogRefresh=1;


    rs=rs+1;

    fitoptprompt=simrfV2GetLeafWidgetBase(...
    'text','Fitting options:','FitOptPrompt',0);
    fitoptprompt.RowSpan=[rs,rs];
    fitoptprompt.ColSpan=[lprompt,rprompt];

    fitopt=simrfV2GetLeafWidgetBase('combobox','',...
    'FitOpt',this,'FitOpt');

    fitopt.RowSpan=[rs,rs];
    fitopt.ColSpan=[lwidget,runit];
    fitopt.DialogRefresh=1;


    autoimp=simrfV2GetLeafWidgetBase('checkbox',...
    'Automatically estimate impulse response duration',...
    'AutoImpulseLength',this,'AutoImpulseLength');
    autoimp.RowSpan=[rs,rs];
    autoimp.ColSpan=[lprompt,runit];
    autoimp.DialogRefresh=1;


    rs=rs+1;

    fittolprompt=simrfV2GetLeafWidgetBase('text',...
    'Relative error desired (dB):','FitTolPrompt',0);
    fittolprompt.RowSpan=[rs,rs];
    fittolprompt.ColSpan=[lprompt,rprompt];

    fittol=simrfV2GetLeafWidgetBase('edit','','FitTol',this,'FitTol');
    fittol.RowSpan=[rs,rs];
    fittol.ColSpan=[lwidget,runit];


    imprespprompt=simrfV2GetLeafWidgetBase('text',...
    'Impulse response duration:','ImpulseLengthprompt',0);
    imprespprompt.RowSpan=[rs,rs];
    imprespprompt.ColSpan=[lprompt,rprompt];

    impresp=simrfV2GetLeafWidgetBase('edit','','ImpulseLength',this,...
    'ImpulseLength');
    impresp.RowSpan=[rs,rs];
    impresp.ColSpan=[lwidget,rwidget];

    imprespunit=simrfV2GetLeafWidgetBase('combobox','',...
    'ImpulseLength_unit',this,'ImpulseLength_unit');
    imprespunit.Entries=set(this,'ImpulseLength_unit')';
    imprespunit.RowSpan=[rs,rs];
    imprespunit.ColSpan=[lunit,runit];


    rs=rs+1;

    maxpolesprompt=simrfV2GetLeafWidgetBase('text',...
    'Maximum number of poles:','MaxPolesPrompt',0);
    maxpolesprompt.RowSpan=[rs,rs];
    maxpolesprompt.ColSpan=[lprompt,rprompt];

    maxpoles=simrfV2GetLeafWidgetBase('edit','','MaxPoles',this,...
    'MaxPoles');
    maxpoles.RowSpan=[rs,rs];
    maxpoles.ColSpan=[lwidget,runit];


    magModeling=simrfV2GetLeafWidgetBase('checkbox',...
    'Use only S-parameter magnitude with appropriate delay',...
    'MagModeling',this,'MagModeling');
    magModeling.RowSpan=[rs,rs];
    magModeling.ColSpan=[lprompt,runit];



    rs=rs+1;
    spacerAboveResult=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerAboveResult.RowSpan=[rs,rs];
    spacerAboveResult.ColSpan=[lprompt,rprompt];
    spacerAboveResult.Visible=1;


    rs=rs+1;

    resultprompt=simrfV2GetLeafWidgetBase(...
    'text','Rational fitting results:','',0);
    resultprompt.RowSpan=[rs,rs];
    resultprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;

    Nfitsprompt=simrfV2GetLeafWidgetBase(...
    'text','Number of independent fits:','NFitsPrompt',0);
    Nfitsprompt.RowSpan=[rs,rs];
    Nfitsprompt.ColSpan=[lprompt,rprompt];

    Nfits=simrfV2GetLeafWidgetBase('text','N/A','NFits',0);
    Nfits.RowSpan=[rs,rs];
    Nfits.ColSpan=[lwidget,runit];


    rs=rs+1;

    maxNpolesprompt=simrfV2GetLeafWidgetBase(...
    'text','Number of required poles:','MaxNPolesPrompt',0);
    maxNpolesprompt.RowSpan=[rs,rs];
    maxNpolesprompt.ColSpan=[lprompt,rprompt];

    maxNpoles=simrfV2GetLeafWidgetBase('text','N/A','MaxNPoles',0);
    maxNpoles.RowSpan=[rs,rs];
    maxNpoles.ColSpan=[lwidget,runit];


    rs=rs+1;

    acterrprompt=simrfV2GetLeafWidgetBase(...
    'text','Relative error achieved (dB):','ActErrPrompt',0);
    acterrprompt.RowSpan=[rs,rs];
    acterrprompt.ColSpan=[lprompt,rprompt];

    acterr=simrfV2GetLeafWidgetBase('text','N/A','ActErr',0);
    acterr.RowSpan=[rs,rs];
    acterr.ColSpan=[lwidget,lwidget+4];

    warnimg=simrfV2GetLeafWidgetBase('image','','WarningImage',0);
    warnimg.FilePath=fullfile(matlabroot,'toolbox','simrf',...
    'simrfV2masks','warning.png');
    warnimg.RowSpan=[rs,rs];
    warnimg.ColSpan=[lwidget+5,lwidget+2];


    rs=rs+1;

    spacerExtra=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerExtra.RowSpan=[rs,rs];
    spacerExtra.ColSpan=[lprompt,runit];
    rs=rs+1;

    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,runit];




    rs=rs+1;
    resultpromptreplacingspace=simrfV2GetLeafWidgetBase('text',' ','',0);
    resultpromptreplacingspace.RowSpan=[rs,rs+3];
    resultpromptreplacingspace.ColSpan=[lprompt,rprompt];
    rs=rs+3;




    fitopt.Visible=0;
    fitoptprompt.Visible=0;
    Nfits.Visible=0;
    Nfitsprompt.Visible=0;
    fittol.Visible=0;
    fittolprompt.Visible=0;
    maxpoles.Visible=0;
    maxpolesprompt.Visible=0;
    maxNpoles.Visible=0;
    maxNpolesprompt.Visible=0;
    acterr.Visible=0;
    acterrprompt.Visible=0;
    resultprompt.Visible=0;
    resultpromptreplacingspace.Visible=1;
    warnimg.Visible=0;
    autoimp.Visible=0;
    slBlkVis(idxMaskNames.AutoImpulseLength)={'off'};
    imprespprompt.Visible=0;
    impresp.Visible=0;
    slBlkVis(idxMaskNames.ImpulseLength)={'off'};
    imprespunit.Visible=0;
    slBlkVis(idxMaskNames.ImpulseLength_unit)={'off'};
    magModeling.Visible=0;
    slBlkVis(idxMaskNames.MagModeling)={'off'};
    slBlkVis([idxMaskNames.FitOpt,idxMaskNames.FitTol])={'off'};
    slBlkVis([idxMaskNames.MaxPoles,idxMaskNames.MaxPoles])={'off'};

    sparam_representation_prompt.Visible=1;
    sparam_representation.Visible=1;
    slBlkVis(idxMaskNames.SparamRepresentation)={'on'};
    if strcmpi(this.SparamRepresentation,'Time domain (rationalfit)')
        fitopt.Visible=1;
        fitoptprompt.Visible=1;
        Nfits.Visible=1;
        Nfitsprompt.Visible=1;
        fittol.Visible=1;
        fittolprompt.Visible=1;
        maxpoles.Visible=1;
        maxpolesprompt.Visible=1;
        maxNpoles.Visible=1;
        maxNpolesprompt.Visible=1;
        acterr.Visible=1;
        acterrprompt.Visible=1;
        resultprompt.Visible=1;
        resultpromptreplacingspace.Visible=0;
        spacerExtra.Visible=0;
        slBlkVis([idxMaskNames.FitOpt,idxMaskNames.FitTol])={'on'};
        slBlkVis([idxMaskNames.MaxPoles,idxMaskNames.MaxPoles])={'on'};
    else
        autoimp.Visible=1;
        slBlkVis(idxMaskNames.AutoImpulseLength)={'on'};
        if~this.AutoImpulseLength
            imprespprompt.Visible=1;
            impresp.Visible=1;
            slBlkVis(idxMaskNames.ImpulseLength)={'on'};
            imprespunit.Visible=1;
            slBlkVis(idxMaskNames.ImpulseLength_unit)={'on'};
        end
        if((nargin>3)&&(varargin{1}))
            magModeling.Visible=1;
            slBlkVis(idxMaskNames.MagModeling)={'on'};
        end
    end

    if strcmpi(this.SparamRepresentation,'Time domain (rationalfit)')
        [nport,nfits,npoles,single_sparam,achieved_error]=...
        get_fit_result(this);

        if single_sparam
            Nfits.Name='1';
            maxNpoles.Name='0';
            acterr.Name='-inf';

        elseif~single_sparam&&(isnan(nport)||isnan(nfits)||isnan(npoles))
            Nfits.Name='N/A';
            maxNpoles.Name='N/A';
            acterr.Name='N/A';
        else
            Nfits.Name=num2str(nfits);
            maxNpoles.Name=num2str(npoles);
            acterr.Name=num2str(achieved_error,'%4.2f');
            sparam_representation.DialogRefresh=1;
        end

        reqFitTol=str2double(this.FitTol);
        if~isnan(reqFitTol)&&achieved_error>reqFitTol
            warnimg.Visible=1;
        end
    end

    if((nargin>4)&&(varargin{2}))
        spacerExtra.Visible=1;
    end


    items={fitopt,fitoptprompt,maxpoles,maxpolesprompt,...
    maxNpoles,maxNpolesprompt,...
    Nfits,Nfitsprompt,fittol,fittolprompt,acterr,acterrprompt,...
    spacerAboveResult,resultprompt,resultpromptreplacingspace,...
    warnimg,sparam_representation_prompt,sparam_representation,...
    autoimp,imprespprompt,impresp,imprespunit,magModeling,...
    spacerExtra};

    layout.LayoutGrid=[rs,number_grid];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,9),1,1,1,1];

end

function[nport,nfits,npoles,single_sparam,achieved_error]=...
    get_fit_result(this)

    nport=NaN;
    nfits=NaN;
    npoles=NaN;
    achieved_error=NaN;
    single_sparam=false;
    if~isfield(this.Block.UserData,'RationalModel')
        return;
    end

    if isempty(this.Block.UserData.RationalModel.C)
        single_sparam=true;
        return;
    end

    nport=this.Block.UserData.NumPorts;

    switch this.FitOpt
    case 'Share poles by columns'
        nfits=nport;
    case 'Share all poles'
        nfits=1;
    case 'Fit individually'
        nfits=nport^2;
    end

    if isfield(this.Block.UserData,'RationalModel')&&...
        ~isempty(this.Block.UserData.RationalModel.A)
        npoles=max(cellfun(@length,this.Block.UserData.RationalModel.A));
    end
    if isempty(this.Block.UserData.FitErrorAchieved)
        if isempty(this.Block.UserData.timestamp)&&...
            this.Block.UserData.hashcode==0
            achieved_error=-inf;
        end
    else
        achieved_error=this.Block.UserData.FitErrorAchieved;
    end

end

