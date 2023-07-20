function[items,layout]=rfblkscreate_netparam_pane_mixer(this,varargin)





    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;

    [tempitems,layout]=rfblkscreate_netparam_pane(this,varargin{:});
    [netparamData,netparamDataprompt,netparamFreq,...
    netparamFreqprompt,z0,z0prompt,interpMethod,interpMethodprompt,...
    spacerMain]=deal(tempitems{:});


    mixerType=rfblksGetLeafWidgetBase('combobox','',...
    'MixerType',this,'MixerType');
    mixerType.Entries=set(this,'MixerType')';
    mixerType.RowSpan=[5,5];
    mixerType.ColSpan=[lwidget,rwidget];

    mixerTypeprompt=rfblksGetLeafWidgetBase('text','Mixer type:',...
    'MixerTypePrompt',0);
    mixerTypeprompt.RowSpan=[5,5];
    mixerTypeprompt.ColSpan=[lprompt,rprompt];


    flo=rfblksGetLeafWidgetBase('edit','','FLO',this,'FLO');
    flo.RowSpan=[6,6];
    flo.ColSpan=[lwidget,rwidget];

    floprompt=rfblksGetLeafWidgetBase('text','LO frequency (Hz):',...
    'FLOPrompt',0);
    floprompt.RowSpan=[6,6];
    floprompt.ColSpan=[lprompt,rprompt];

    spacerMain.RowSpan=[7,7];


    items={netparamData,netparamDataprompt,netparamFreq,...
    netparamFreqprompt,z0,z0prompt,interpMethod,interpMethodprompt,...
    mixerType,mixerTypeprompt,flo,floprompt,spacerMain};

    layout.LayoutGrid=[7,number_grid];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,6),1];


