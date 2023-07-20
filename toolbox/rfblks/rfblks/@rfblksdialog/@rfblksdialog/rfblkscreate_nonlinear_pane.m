function[items,layout]=rfblkscreate_nonlinear_pane(this,varargin)




    ros=varargin{1};
    p2ddata=varargin{2};
    powerdata=varargin{3};
    ip3data=varargin{4};
    OneDBC=varargin{5};
    PS=varargin{6};
    GCS=varargin{7};
    from_data_source=varargin{8};


    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;



    iP3Type=rfblksGetLeafWidgetBase('combobox','','IP3Type',this,'IP3Type');
    iP3Type.Entries=set(this,'IP3Type')';
    iP3Type.RowSpan=[1+ros,1+ros];
    iP3Type.ColSpan=[lwidget,rwidget];
    iP3Type.DialogRefresh=1;

    iP3Typeprompt=rfblksGetLeafWidgetBase('text','IP3 type:',...
    'IP3TypePrompt',0);
    iP3Typeprompt.RowSpan=[1+ros,1+ros];
    iP3Typeprompt.ColSpan=[lprompt,rprompt];


    oIP3=rfblksGetLeafWidgetBase('edit','','OIP3',this,'OIP3');
    oIP3.RowSpan=[2+ros,2+ros];
    oIP3.ColSpan=[lwidget+1,rwidget];
    oIP3.Enabled=0;
    oIP3.Visible=1;

    oIP3prompt=rfblksGetLeafWidgetBase('text','IP3 (dBm):','OIP3Prompt',...
    0);
    oIP3prompt.RowSpan=[2+ros,2+ros];
    oIP3prompt.ColSpan=[lprompt+1,rprompt];


    iIP3=rfblksGetLeafWidgetBase('edit','','IIP3',this,'IIP3');
    iIP3.RowSpan=[2+ros,2+ros];
    iIP3.ColSpan=[lwidget+1,rwidget];
    iIP3.Enabled=0;
    iIP3.Visible=0;

    iIP3prompt=rfblksGetLeafWidgetBase('text','IP3 (dBm):','IIP3Prompt',0);
    iIP3prompt.RowSpan=[2+ros,2+ros];
    iIP3prompt.ColSpan=[lprompt+1,rprompt];
    iIP3prompt.Visible=0;


    p1dB=rfblksGetLeafWidgetBase('edit','','P1dB',this,'P1dB');
    p1dB.RowSpan=[3+ros,3+ros];
    p1dB.ColSpan=[lwidget,rwidget];

    p1dBprompt=rfblksGetLeafWidgetBase('text','1dB gain compression power (dBm):',...
    'P1dBPrompt',0);
    p1dBprompt.RowSpan=[3+ros,3+ros];
    p1dBprompt.ColSpan=[lprompt,rprompt];


    pSat=rfblksGetLeafWidgetBase('edit','','PSat',this,'PSat');
    pSat.RowSpan=[4+ros,4+ros];
    pSat.ColSpan=[lwidget,rwidget];

    pSatprompt=rfblksGetLeafWidgetBase('text','Output saturation power (dBm):',...
    'PSatPrompt',0);
    pSatprompt.RowSpan=[4+ros,4+ros];
    pSatprompt.ColSpan=[lprompt,rprompt];


    GCSat=rfblksGetLeafWidgetBase('edit','','GCSat',this,'GCSat');
    GCSat.RowSpan=[5+ros,5+ros];
    GCSat.ColSpan=[lwidget,rwidget];
    GCSat.Visible=1;

    GCSatprompt=rfblksGetLeafWidgetBase('text',...
    'Gain compression at saturation (dB):','GCSatPrompt',0);
    GCSatprompt.RowSpan=[5+ros,5+ros];
    GCSatprompt.ColSpan=[lprompt,rprompt];
    GCSatprompt.Visible=1;


    nonLinearDataFreq=rfblksGetLeafWidgetBase('edit','','NonlinearDataFreq',this,'NonlinearDataFreq');
    nonLinearDataFreq.RowSpan=[6+ros,6+ros];
    nonLinearDataFreq.ColSpan=[lwidget,rwidget];

    nonLinearDataFreqprompt=rfblksGetLeafWidgetBase('text','Frequency (Hz):',...
    'NonlinearDataFreqPrompt',0);
    nonLinearDataFreqprompt.RowSpan=[6+ros,6+ros];
    nonLinearDataFreqprompt.ColSpan=[lprompt,rprompt];

    spacerNonlinear=rfblksGetLeafWidgetBase('text','','',0);
    spacerNonlinear.RowSpan=[7+ros,7+ros];
    spacerNonlinear.ColSpan=[lprompt,rprompt];


    if isa(p2ddata,'rfdata.p2d')||isa(powerdata,'rfdata.power')
        iP3Type.Enabled=0;
        iIP3.Enabled=0;
        oIP3.Enabled=0;
        p1dB.Enabled=0;
        pSat.Enabled=0;
        GCSat.Enabled=0;
        nonLinearDataFreq.Enabled=0;
    else
        iP3Type.Enabled=1;
        switch this.IP3Type
        case 'IIP3'
            iIP3.Enabled=1;
            iIP3.Visible=1;
            oIP3.Enabled=0;
            oIP3.Visible=0;
        case 'OIP3'
            iIP3.Enabled=0;
            iIP3.Visible=0;
            oIP3.Enabled=1;
            oIP3.Visible=1;
        end
        p1dB.Enabled=1;
        pSat.Enabled=1;
        GCSat.Enabled=1;
        nonLinearDataFreq.Enabled=1;

        if isa(ip3data,'rfdata.ip3')
            iP3Type.Enabled=0;
            iIP3.Enabled=0;
            oIP3.Enabled=0;
        end

        if~isempty(OneDBC)
            p1dB.Enabled=0;
        end

        if~isempty(PS)
            pSat.Enabled=0;
        end

        if~isempty(GCS)
            GCSat.Enabled=0;
        end

        if~iP3Type.Enabled&&~p1dB.Enabled&&~pSat.Enabled
            nonLinearDataFreq.Enabled=0;
        end
        [nonLinearDataFreq,iIP3,oIP3,p1dB,pSat,GCSat]=restoredefaultpowerparam(this,...
        nonLinearDataFreq,iIP3,oIP3,p1dB,pSat,GCSat,from_data_source);
    end


    items={iP3Type,iP3Typeprompt,iIP3,iIP3prompt,oIP3,oIP3prompt,p1dB,...
    p1dBprompt,pSat,pSatprompt,GCSat,GCSatprompt,...
    nonLinearDataFreq,nonLinearDataFreqprompt,spacerNonlinear};

    layout.LayoutGrid=[7+ros,number_grid];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,6+ros),1];


    function[nonLinearDataFreq,iIP3,oIP3,p1dB,pSat,GCSat]=restoredefaultpowerparam(this,nonLinearDataFreq,iIP3,oIP3,p1dB,pSat,GCSat,from_data_source)

        if nonLinearDataFreq.Enabled&&strcmp(this.NonlinearDataFreq,from_data_source)
            nonLinearDataFreq.Value='2.0e9';
            this.NonlinearDataFreq='2.0e9';
        end
        if iIP3.Enabled&&strcmp(this.IIP3,from_data_source)
            iIP3.Value='inf';
            this.IIP3='inf';
        end
        if oIP3.Enabled&&strcmp(this.OIP3,from_data_source)
            oIP3.Value='inf';
            this.OIP3='inf';
        end
        if p1dB.Enabled&&strcmp(this.P1dB,from_data_source)
            p1dB.Value='inf';
            this.P1dB='inf';
        end
        if pSat.Enabled&&strcmp(this.PSat,from_data_source)
            pSat.Value='inf';
            this.PSat='inf';
        end
        if GCSat.Enabled&&strcmp(this.GCSat,from_data_source)
            GCSat.Value='0';
            this.GCSat='0';
        end
