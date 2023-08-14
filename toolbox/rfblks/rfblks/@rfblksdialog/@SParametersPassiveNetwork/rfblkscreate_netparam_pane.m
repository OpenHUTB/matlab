function[items,layout]=rfblkscreate_netparam_pane(this,varargin)





    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;



    netparamData=rfblksGetLeafWidgetBase('edit','','NetParamData',...
    this,'NetParamData');
    netparamData.RowSpan=[1,1];
    netparamData.ColSpan=[lwidget,rwidget];

    tempname=[this.Block.MaskType(1),'-Parameters:'];
    netparamDataprompt=rfblksGetLeafWidgetBase('text',tempname,...
    'NetParamDataPrompt',0);
    netparamDataprompt.RowSpan=[1,1];
    netparamDataprompt.ColSpan=[lprompt,rprompt];


    netparamFreq=rfblksGetLeafWidgetBase('edit','','NetParamFreq',...
    this,'NetParamFreq');
    netparamFreq.RowSpan=[2,2];
    netparamFreq.ColSpan=[lwidget,rwidget];

    netparamFreqprompt=rfblksGetLeafWidgetBase('text','Frequency (Hz):',...
    'NetParamFreqPrompt',0);
    netparamFreqprompt.RowSpan=[2,2];
    netparamFreqprompt.ColSpan=[lprompt,rprompt];


    z0=rfblksGetLeafWidgetBase('edit','','Z0',this,'Z0');
    z0.RowSpan=[3,3];
    z0.ColSpan=[lwidget,rwidget];

    z0prompt=rfblksGetLeafWidgetBase('text','Reference impedance (ohms):',...
    'Z0Prompt',0);
    z0prompt.RowSpan=[3,3];
    z0prompt.ColSpan=[lprompt,rprompt];

    if strcmp(strtok(this.Block.MaskType),'S-Parameters')
        z0.Visible=1;
        z0prompt.Visible=1;
    else
        z0.Visible=0;
        z0prompt.Visible=0;
    end


    interpMethod=rfblksGetLeafWidgetBase('combobox','',...
    'InterpMethod',this,'InterpMethod');
    interpMethod.Entries=set(this,'InterpMethod')';
    interpMethod.RowSpan=[4,4];
    interpMethod.ColSpan=[lwidget,rwidget];

    interpMethodprompt=rfblksGetLeafWidgetBase('text','Interpolation method:',...
    'InterpMethodPrompt',0);
    interpMethodprompt.RowSpan=[4,4];
    interpMethodprompt.ColSpan=[lprompt,rprompt];

    spacerMain=rfblksGetLeafWidgetBase('text','','',0);
    spacerMain.RowSpan=[5,5];
    spacerMain.ColSpan=[lprompt,rprompt];


    items={netparamData,netparamDataprompt,netparamFreq,...
    netparamFreqprompt,z0,z0prompt,interpMethod,interpMethodprompt,...
    spacerMain};

    layout.LayoutGrid=[5,number_grid];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,4),1];


