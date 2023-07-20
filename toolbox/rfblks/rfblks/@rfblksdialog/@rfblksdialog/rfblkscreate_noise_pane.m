function[items,layout]=rfblkscreate_noise_pane(this,varargin)




    ros=varargin{1};
    noisedata=varargin{2};
    nfdata=varargin{3};
    from_data_source=varargin{4};


    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;


    noisesource=rfblksGetLeafWidgetBase('combobox','','NoiseDefinedBy',...
    this,'NoiseDefinedBy');
    noisesource.Entries=set(this,'NoiseDefinedBy')';
    noisesource.RowSpan=[1+ros,1+ros];
    noisesource.ColSpan=[lwidget,rwidget];
    noisesource.DialogRefresh=1;

    noisesourceprompt=rfblksGetLeafWidgetBase('text','Noise type:',...
    'NoiseDefinedByPrompt',0);
    noisesourceprompt.RowSpan=[1+ros,1+ros];
    noisesourceprompt.ColSpan=[lprompt,rprompt];


    nf=rfblksGetLeafWidgetBase('edit','','NF',this,'NF');
    nf.RowSpan=[2+ros,2+ros];
    nf.ColSpan=[lwidget+1,rwidget];

    nfprompt=rfblksGetLeafWidgetBase('text','Noise figure (dB):','NFPrompt',...
    0);
    nfprompt.RowSpan=[2+ros,2+ros];
    nfprompt.ColSpan=[lprompt+1,rprompt];


    fmin=rfblksGetLeafWidgetBase('edit','','FMIN',this,'FMIN');
    fmin.RowSpan=[3+ros,3+ros];
    fmin.ColSpan=[lwidget+1,rwidget];

    fminprompt=rfblksGetLeafWidgetBase('text','Minimum noise figure (dB):',...
    'FMINPrompt',0);
    fminprompt.RowSpan=[3+ros,3+ros];
    fminprompt.ColSpan=[lprompt+1,rprompt];


    gammaopt=rfblksGetLeafWidgetBase('edit','','GammaOpt',this,'GammaOpt');
    gammaopt.RowSpan=[4+ros,4+ros];
    gammaopt.ColSpan=[lwidget+1,rwidget];

    gammaoptprompt=rfblksGetLeafWidgetBase('text','Optimal reflection coefficient:',...
    'GammaOptPrompt',0);
    gammaoptprompt.RowSpan=[4+ros,4+ros];
    gammaoptprompt.ColSpan=[lprompt+1,rprompt];


    rn=rfblksGetLeafWidgetBase('edit','','RN',this,'RN');
    rn.RowSpan=[5+ros,5+ros];
    rn.ColSpan=[lwidget+1,rwidget];

    rnprompt=rfblksGetLeafWidgetBase('text','Equivalent normalized noise resistance:',...
    'RNPrompt',0);
    rnprompt.RowSpan=[5+ros,5+ros];
    rnprompt.ColSpan=[lprompt+1,rprompt];


    nfactor=rfblksGetLeafWidgetBase('edit','','NFactor',this,'NFactor');
    nfactor.RowSpan=[6+ros,6+ros];
    nfactor.ColSpan=[lwidget+1,rwidget];

    nfactorprompt=rfblksGetLeafWidgetBase('text','Noise factor:','NFactorPrompt',...
    0);
    nfactorprompt.RowSpan=[6+ros,6+ros];
    nfactorprompt.ColSpan=[lprompt+1,rprompt];


    ntemp=rfblksGetLeafWidgetBase('edit','','NTemp',this,'NTemp');
    ntemp.RowSpan=[7+ros,7+ros];
    ntemp.ColSpan=[lwidget+1,rwidget];

    ntempprompt=rfblksGetLeafWidgetBase('text','Noise temperature (K):','NTempPrompt',...
    0);
    ntempprompt.RowSpan=[7+ros,7+ros];
    ntempprompt.ColSpan=[lprompt+1,rprompt];


    noiseDataFreq=rfblksGetLeafWidgetBase('edit','','NoiseDataFreq',this,'NoiseDataFreq');
    noiseDataFreq.RowSpan=[8+ros,8+ros];
    noiseDataFreq.ColSpan=[lwidget+1,rwidget];

    noiseDataFreqprompt=rfblksGetLeafWidgetBase('text','Frequency (Hz):',...
    'NoiseDataFreqPrompt',0);
    noiseDataFreqprompt.RowSpan=[8+ros,8+ros];
    noiseDataFreqprompt.ColSpan=[lprompt+1,rprompt];

    spacerNoise=rfblksGetLeafWidgetBase('text','','',0);
    spacerNoise.RowSpan=[9+ros,9+ros];
    spacerNoise.ColSpan=[lprompt,rprompt];


    if(isa(noisedata,'rfdata.noise')||isa(nfdata,'rfdata.nf'))
        noisesource.Enabled=0;
        nf.Enabled=0;
        fmin.Enabled=0;
        gammaopt.Enabled=0;
        rn.Enabled=0;
        nfactor.Enabled=0;
        ntemp.Enabled=0;
        noiseDataFreq.Enabled=0;
    else
        noisesource.Enabled=1;
        switch this.NoiseDefinedBy
        case 'Noise figure'
            nf.Enabled=1;
            fmin.Enabled=0;
            gammaopt.Enabled=0;
            rn.Enabled=0;
            nfactor.Enabled=0;
            ntemp.Enabled=0;
        case 'Spot noise data'
            nf.Enabled=0;
            fmin.Enabled=1;
            gammaopt.Enabled=1;
            rn.Enabled=1;
            nfactor.Enabled=0;
            ntemp.Enabled=0;
        case 'Noise factor'
            nf.Enabled=0;
            fmin.Enabled=0;
            gammaopt.Enabled=0;
            rn.Enabled=0;
            nfactor.Enabled=1;
            ntemp.Enabled=0;
        case 'Noise temperature'
            nf.Enabled=0;
            fmin.Enabled=0;
            gammaopt.Enabled=0;
            rn.Enabled=0;
            nfactor.Enabled=0;
            ntemp.Enabled=1;
        end
        noiseDataFreq.Enabled=1;
        [noiseDataFreq,nf,fmin,gammaopt,rn,nfactor,ntemp]=restoredefaultnoiseparam(this,...
        noiseDataFreq,nf,fmin,gammaopt,rn,nfactor,ntemp,from_data_source);
    end


    items={noisesource,noisesourceprompt,nf,nfprompt,...
    fmin,fminprompt,gammaopt,gammaoptprompt,rn,rnprompt,...
    nfactor,ntemp,nfactorprompt,ntempprompt,...
    noiseDataFreq,noiseDataFreqprompt,spacerNoise};

    layout.LayoutGrid=[9+ros,number_grid];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,8+ros),1];


    function[noiseDataFreq,nf,fmin,gammaopt,rn,nfactor,ntemp]=restoredefaultnoiseparam(...
        this,noiseDataFreq,nf,fmin,gammaopt,rn,nfactor,ntemp,from_data_source)

        if noiseDataFreq.Enabled&&strcmp(this.noiseDataFreq,from_data_source)
            noiseDataFreq.Value='2.0e9';
            this.noiseDataFreq='2.0e9';
        end
        if strcmp(this.NF,from_data_source)
            nf.Value='0';
            this.NF='0';
        end
        if strcmp(this.FMIN,from_data_source)
            fmin.Value='0';
            this.FMIN='0';
        end
        if strcmp(this.GammaOpt,from_data_source)
            gammaopt.Value='1+0i';
            this.GammaOpt='1+0i';
        end
        if strcmp(this.RN,from_data_source)
            rn.Value='1';
            this.RN='1';
        end
        if strcmp(this.NFactor,from_data_source)
            nfactor.Value='1';
            this.NFactor='1';
        end
        if strcmp(this.NTemp,from_data_source)
            ntemp.Value='0';
            this.NTemp='0';
        end


