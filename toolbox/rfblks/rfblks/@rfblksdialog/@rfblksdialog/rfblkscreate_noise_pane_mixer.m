function[items,layout]=rfblkscreate_noise_pane_mixer(this,varargin)





    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;

    [items,layout]=rfblkscreate_noise_pane(this,varargin{:});

    freqOffset=rfblksGetLeafWidgetBase('edit','','FreqOffset',this,...
    'FreqOffset');
    freqOffset.RowSpan=[1,1];
    freqOffset.ColSpan=[lwidget,rwidget];

    freqOffsetprompt=rfblksGetLeafWidgetBase('text',...
    'Phase noise frequency offset (Hz):',...
    'FreqOffsetPrompt',0);
    freqOffsetprompt.RowSpan=[1,1];
    freqOffsetprompt.ColSpan=[lprompt,rprompt];


    phaseNoiseLevel=rfblksGetLeafWidgetBase('edit',...
    '','PhaseNoiseLevel',this,'PhaseNoiseLevel');
    phaseNoiseLevel.RowSpan=[2,2];
    phaseNoiseLevel.ColSpan=[lwidget,rwidget];

    phaseNoiseLevelprompt=rfblksGetLeafWidgetBase('text',...
    'Phase noise level (dBc/Hz):',...
    'PhaseNoiseLevelPrompt',0);
    phaseNoiseLevelprompt.RowSpan=[2,2];
    phaseNoiseLevelprompt.ColSpan=[lprompt,rprompt];

    items={items{:},freqOffset,freqOffsetprompt,...
    phaseNoiseLevel,phaseNoiseLevelprompt};


