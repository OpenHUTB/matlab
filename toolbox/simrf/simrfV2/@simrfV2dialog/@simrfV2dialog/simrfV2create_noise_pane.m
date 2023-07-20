function[items,layout,slBlkVis]=...
    simrfV2create_noise_pane(this,slBlkVis,idxMaskNames,varargin)





    lsimnoise=1;
    lprompt=2;
    rprompt=5;
    lwidget=rprompt+1;
    rwidget=18;
    lunit=rwidget+1;
    runit=20;
    number_grid=20;



    rs=1;
    addnoise=simrfV2GetLeafWidgetBase('checkbox',...
    'Simulate noise','AddNoise',this,'AddNoise');
    addnoise.RowSpan=[rs,rs];
    addnoise.ColSpan=[lsimnoise,rwidget];
    addnoise.DialogRefresh=1;


    rs=2;
    NFfile=simrfV2GetLeafWidgetBase('text',...
    'Noise specified in Data file','NFfile',0);
    NFfile.RowSpan=[rs,rs];
    NFfile.ColSpan=[lprompt,rwidget];


    rs=2;
    noisetypeprompt=simrfV2GetLeafWidgetBase(...
    'text','Noise type:','NoiseTypePrompt',0);
    noisetypeprompt.RowSpan=[rs,rs];
    noisetypeprompt.ColSpan=[lprompt,rprompt];

    noisetype=simrfV2GetLeafWidgetBase('combobox','',...
    'NoiseType',this,'NoiseType');
    noisetype.RowSpan=[rs,rs];
    noisetype.ColSpan=[lwidget,runit];
    noisetype.DialogRefresh=1;


    rs=rs+1;
    noisedistprompt=simrfV2GetLeafWidgetBase('text',...
    'Noise distribution:','NoiseDistPrompt',0);
    noisedistprompt.RowSpan=[rs,rs];
    noisedistprompt.ColSpan=[lprompt,rprompt];

    noisedist=simrfV2GetLeafWidgetBase('combobox','','NoiseDist',...
    this,'NoiseDist');
    noisedist.Entries=set(this,'NoiseDist')';
    noisedist.RowSpan=[rs,rs];
    noisedist.ColSpan=[lwidget,runit];
    noisedist.DialogRefresh=1;

    rs_noisedata=rs+1;



    rs=rs_noisedata;
    NFprompt=simrfV2GetLeafWidgetBase('text','Noise figure (dB):',...
    'NFprompt',0);
    NFprompt.RowSpan=[rs,rs];
    NFprompt.ColSpan=[lprompt,rprompt];

    NF=simrfV2GetLeafWidgetBase('edit','','NF',this,'NF');
    NF.RowSpan=[rs,rs];
    NF.ColSpan=[lwidget,runit];



    rs=rs_noisedata;
    minNFprompt=simrfV2GetLeafWidgetBase('text',...
    'Minimum noise figure (dB):','MinNFprompt',0);
    minNFprompt.RowSpan=[rs,rs];
    minNFprompt.ColSpan=[lprompt,rprompt];

    minNF=simrfV2GetLeafWidgetBase('edit','','MinNF',this,'MinNF');
    minNF.RowSpan=[rs,rs];
    minNF.ColSpan=[lwidget,runit];


    rs=rs+1;
    Goptprompt=simrfV2GetLeafWidgetBase('text',...
    'Optimal reflection coefficient:','Goptprompt',0);
    Goptprompt.RowSpan=[rs,rs];
    Goptprompt.ColSpan=[lprompt,rprompt];

    Gopt=simrfV2GetLeafWidgetBase('edit','','Gopt',this,'Gopt');
    Gopt.RowSpan=[rs,rs];
    Gopt.ColSpan=[lwidget,runit];


    rs=rs+1;
    RNprompt=simrfV2GetLeafWidgetBase('text',...
    'Equivalent normalized noise resistance:','RNprompt',0);
    RNprompt.RowSpan=[rs,rs];
    RNprompt.ColSpan=[lprompt,rprompt];

    RN=simrfV2GetLeafWidgetBase('edit','','RN',this,'RN');
    RN.RowSpan=[rs,rs];
    RN.ColSpan=[lwidget,runit];


    rs=rs+1;
    freqprompt=simrfV2GetLeafWidgetBase('text','Frequencies:',...
    'CarrierFreqPrompt',0);
    freqprompt.RowSpan=[rs,rs];
    freqprompt.ColSpan=[lprompt,rprompt];

    freq=simrfV2GetLeafWidgetBase('edit','','CarrierFreq',0,...
    'CarrierFreq');
    freq.RowSpan=[rs,rs];
    freq.ColSpan=[lwidget,rwidget];

    frequnit=simrfV2GetLeafWidgetBase('combobox','','CarrierFreq_unit',...
    this,'CarrierFreq_unit');
    frequnit.Entries=set(this,'CarrierFreq_unit')';
    frequnit.RowSpan=[rs,rs];
    frequnit.ColSpan=[lunit,runit];


    rs=rs+1;
    noiseautoimp=simrfV2GetLeafWidgetBase('checkbox',...
    'Automatically estimate impulse response duration',...
    'NoiseAutoImpulseLength',this,'NoiseAutoImpulseLength');
    noiseautoimp.RowSpan=[rs,rs];
    noiseautoimp.ColSpan=[lprompt,rwidget];
    noiseautoimp.DialogRefresh=1;


    rs=rs+1;
    noiseimprespprompt=simrfV2GetLeafWidgetBase('text',...
    'Impulse response duration:','NoiseImpulseLengthprompt',0);
    noiseimprespprompt.RowSpan=[rs,rs];
    noiseimprespprompt.ColSpan=[lprompt,rprompt];

    noiseimpresp=simrfV2GetLeafWidgetBase('edit','',...
    'NoiseImpulseLength',this,'NoiseImpulseLength');
    noiseimpresp.RowSpan=[rs,rs];
    noiseimpresp.ColSpan=[lwidget,rwidget];

    noiseimprespunit=simrfV2GetLeafWidgetBase('combobox','',...
    'NoiseImpulseLength_unit',this,'NoiseImpulseLength_unit');
    noiseimprespunit.Entries=set(this,'NoiseImpulseLength_unit')';
    noiseimprespunit.RowSpan=[rs,rs];
    noiseimprespunit.ColSpan=[lunit,runit];


    rs=rs+1;
    choosenNFStr=sprintf(' \n ');
    if(((nargin>3)&&(varargin{1}))||(~strcmpi(this.NoiseDist,'White')))
        if((nargin>4)&&(varargin{2}))
            NFfileVisible=varargin{1};
            spotNoise=(strcmpi(this.NoiseType,'Spot noise data'));
            SetOpFreqAsMaxS21=varargin{3};
            opFreqStr=varargin{4};
            if(~NFfileVisible)&&(~spotNoise)
                if SetOpFreqAsMaxS21
                    choosenNFStr='Due to nonlinearity, simulating white noise distribution using maximum noise figure specified above.';
                else
                    choosenNFStr=['Due to nonlinearity, simulating white noise distribution using noise figure at ',opFreqStr,'.'];
                end
            elseif(~NFfileVisible)
                if SetOpFreqAsMaxS21
                    choosenNFStr='Due to nonlinearity, simulating white noise distribution based on data above at frequency yielding maximum matched noise figure.';
                else
                    choosenNFStr=['Due to nonlinearity, simulating white noise distribution using noise data above at frequency ',opFreqStr,'.'];
                end
            else
                if SetOpFreqAsMaxS21
                    choosenNFStr='Due to nonlinearity, simulating white noise distribution using data from file at frequency yielding maximum matched noise figure.';
                else
                    choosenNFStr=['Due to nonlinearity, simulating white noise distribution using data from file at frequency ',opFreqStr,'.'];
                end
            end
        end
    end
    choosenNF=simrfV2GetLeafWidgetBase('text',choosenNFStr,'ChoosenNF',0);
    choosenNF.RowSpan=[rs,rs];
    choosenNF.ColSpan=[lprompt,runit];
    choosenNF.WordWrap=true;


    rs=rs+1;
    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,runit];

    maxrows=spacerMain.RowSpan(1);


    NFfile.Visible=0;
    noisetypeprompt.Visible=1;
    slBlkVis(idxMaskNames.NoiseType)={'on'};
    noisetype.Visible=1;
    noisedistprompt.Visible=1;
    slBlkVis(idxMaskNames.NoiseDist)={'on'};
    noisedist.Visible=1;
    slBlkVis(idxMaskNames.NF)={'on'};
    NFprompt.Visible=1;
    NF.Visible=1;
    slBlkVis(idxMaskNames.MinNF)={'off'};
    minNFprompt.Visible=0;
    minNF.Visible=0;
    slBlkVis(idxMaskNames.Gopt)={'off'};
    Goptprompt.Visible=0;
    Gopt.Visible=0;
    slBlkVis(idxMaskNames.RN)={'off'};
    RNprompt.Visible=0;
    RN.Visible=0;
    noiseautoimp.Visible=0;
    slBlkVis(idxMaskNames.NoiseAutoImpulseLength)={'off'};
    noiseimprespprompt.Visible=0;
    slBlkVis(idxMaskNames.NoiseImpulseLength)={'off'};
    noiseimpresp.Visible=0;
    noiseimprespunit.Visible=0;
    slBlkVis(idxMaskNames.NoiseImpulseLength_unit)={'off'};
    choosenNF.Visible=0;
    if(this.AddNoise)
        if((nargin>3)&&(varargin{1}))
            NFfile.Visible=1;
            noisetypeprompt.Visible=0;
            slBlkVis(idxMaskNames.NoiseType)={'off'};
            noisetype.Visible=0;
            noisedistprompt.Visible=0;
            slBlkVis(idxMaskNames.NoiseDist)={'off'};
            noisedist.Visible=0;
            NFprompt.Visible=0;
            NF.Visible=0;
            freq.Visible=0;
            slBlkVis(idxMaskNames.CarrierFreq)={'off'};
            freqprompt.Visible=0;
            frequnit.Visible=0;
            slBlkVis(idxMaskNames.CarrierFreq_unit)={'off'};
            if((nargin>4)&&(varargin{2}))
                NFfile.Visible=0;
                choosenNF.Visible=1;
            else
                noiseautoimp.Visible=1;
                slBlkVis(idxMaskNames.NoiseAutoImpulseLength)={'on'};
                if~this.NoiseAutoImpulseLength
                    noiseimprespprompt.Visible=1;
                    noiseimpresp.Visible=1;
                    slBlkVis(idxMaskNames.NoiseImpulseLength)={'on'};
                    noiseimprespunit.Visible=1;
                    slBlkVis(idxMaskNames.NoiseImpulseLength_unit)={'on'};
                end
            end
        else
            slBlkVis(idxMaskNames.NoiseType)={'on'};
            if(strcmpi(this.NoiseType,'Spot noise data'))
                slBlkVis(idxMaskNames.NF)={'off'};
                NFprompt.Visible=0;
                NF.Visible=0;
                slBlkVis(idxMaskNames.MinNF)={'on'};
                minNFprompt.Visible=1;
                minNF.Visible=1;
                slBlkVis(idxMaskNames.Gopt)={'on'};
                Goptprompt.Visible=1;
                Gopt.Visible=1;
                slBlkVis(idxMaskNames.RN)={'on'};
                RNprompt.Visible=1;
                RN.Visible=1;
            end
            if((nargin>4)&&(varargin{2}))
                choosenNF.Visible=1;
            end
            switch this.NoiseDist
            case 'White'
                freq.Visible=0;
                slBlkVis(idxMaskNames.CarrierFreq)={'off'};
                freqprompt.Visible=0;
                frequnit.Visible=0;
                slBlkVis(idxMaskNames.CarrierFreq_unit)={'off'};
            case{'Piece-wise linear'}
                freq.Visible=1;
                slBlkVis(idxMaskNames.CarrierFreq)={'on'};
                freqprompt.Visible=1;
                frequnit.Visible=1;
                slBlkVis(idxMaskNames.CarrierFreq_unit)={'on'};
            case{'Colored'}
                freq.Visible=1;
                slBlkVis(idxMaskNames.CarrierFreq)={'on'};
                freqprompt.Visible=1;
                frequnit.Visible=1;
                slBlkVis(idxMaskNames.CarrierFreq_unit)={'on'};
                if~((nargin>4)&&(varargin{2}))
                    noiseautoimp.Visible=1;
                    slBlkVis(idxMaskNames.NoiseAutoImpulseLength)={'on'};
                    if~this.NoiseAutoImpulseLength
                        noiseimprespprompt.Visible=1;
                        slBlkVis(idxMaskNames.NoiseImpulseLength)={'on'};
                        noiseimpresp.Visible=1;
                        noiseimprespunit.Visible=1;
                        slBlkVis(idxMaskNames.NoiseImpulseLength_unit)=...
                        {'on'};
                    end
                end
            end
        end
    else
        noisetypeprompt.Visible=0;
        slBlkVis(idxMaskNames.NoiseType)={'off'};
        noisetype.Visible=0;
        noisedistprompt.Visible=0;
        slBlkVis(idxMaskNames.NoiseDist)={'off'};
        noisedist.Visible=0;
        slBlkVis(idxMaskNames.NF)={'off'};
        NFprompt.Visible=0;
        NF.Visible=0;
        freq.Visible=0;
        slBlkVis(idxMaskNames.CarrierFreq)={'off'};
        freqprompt.Visible=0;
        frequnit.Visible=0;
        slBlkVis(idxMaskNames.CarrierFreq_unit)={'off'};
    end


    items={addnoise,NFfile,noisetypeprompt,noisetype,...
    noisedistprompt,noisedist,NFprompt,NF,minNFprompt,minNF,...
    Goptprompt,Gopt,RNprompt,RN,freqprompt,freq,frequnit,...
    noiseautoimp,noiseimprespprompt,noiseimpresp,noiseimprespunit,...
    choosenNF,spacerMain};

    layout.LayoutGrid=[maxrows,number_grid];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,maxrows-1),1];

end

