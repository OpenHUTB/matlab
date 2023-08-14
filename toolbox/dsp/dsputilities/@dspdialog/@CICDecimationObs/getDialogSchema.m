function dlgStruct=getDialogSchema(this,~)











    MFILT_MODE=1;
    blkh=this.Block.Handle;
    mask_enables=get_param(blkh,'MaskEnables');
    old_mask_enables=mask_enables;

    [filtobjEditBox,decimationFactorEditBox,...
    differentialDelayEditBox,numSectionsEditBox,filterInternalsPopup,BPSEditBox,...
    FLPSEditBox,outputWordLengthEditBox,outputFracLengthEditBox,rateOptionsPopup]=deal(2,4,5,6,7,8,9,10,11,14);


    filterSourcePane=dspGetContainerWidgetBase('panel','','filterSourcePane');

    FilterSource=dspGetLeafWidgetBase('radiobutton',...
    'Coefficient source',...
    'filtFrom',...
    this,'FilterSource');

    FilterSource.Entries={'Dialog parameters',...
    'Filter object'};
    FilterSource.DialogRefresh=1;

    filterSourcePane.Items={FilterSource};
    filterSourcePane.RowSpan=[2,2];
    filterSourcePane.ColSpan=[1,1];


    paramsPane=dspGetContainerWidgetBase('panel','Parameters','paramsPanel');
    paramsPane.RowSpan=[3,3];
    mask_enables{rateOptionsPopup}='on';


    RateOptions=dspGetLeafWidgetBase('combobox',...
    'Rate Options:',...
    'RateOptions',...
    this,'RateOptions');
    RateOptions.DialogRefresh=1;
    RateOptions.Entries=set(this,'RateOptions')';

    if this.FilterSource==MFILT_MODE

        mask_enables{filtobjEditBox}='on';
        mask_enables{decimationFactorEditBox}='off';
        mask_enables{differentialDelayEditBox}='off';
        mask_enables{numSectionsEditBox}='off';
        mask_enables{filterInternalsPopup}='off';
        mask_enables{BPSEditBox}='off';
        mask_enables{FLPSEditBox}='off';
        mask_enables{outputWordLengthEditBox}='off';
        mask_enables{outputFracLengthEditBox}='off';


        mfiltObjectName=dspGetLeafWidgetBase('edit',...
        'Filter object variable:',...
        'filtobj',...
        this,'mfiltObjectName');
        mfiltObjectName.DialogRefresh=1;
        paramsPane.Items={mfiltObjectName};

    else

        mask_enables{filtobjEditBox}='off';
        mask_enables{decimationFactorEditBox}='on';
        mask_enables{differentialDelayEditBox}='on';
        mask_enables{numSectionsEditBox}='on';
        mask_enables{filterInternalsPopup}='on';
        mask_enables{BPSEditBox}='on';
        mask_enables{FLPSEditBox}='on';
        mask_enables{outputWordLengthEditBox}='on';
        mask_enables{outputFracLengthEditBox}='on';


        DecimationFactor=dspGetLeafWidgetBase('edit','Decimation factor (R):',...
        'R',this,'DecimationFactor');


        DifferentialDelay=dspGetLeafWidgetBase('edit','Differential delay (M):',...
        'M',this,'DifferentialDelay');


        NumberOfSections=dspGetLeafWidgetBase('edit','Number of sections (N):',...
        'N',this,'NumberOfSections');


        FilterInternals=dspGetLeafWidgetBase('combobox',...
        'Data type specification mode:',...
        'filterInternals',...
        this,'FilterInternals');
        FilterInternals.Entries=set(this,'FilterInternals')';
        FilterInternals.DialogRefresh=1;


        SectionWordLengths=dspGetLeafWidgetBase('edit',...
        'Section word lengths:',...
        'BPS',this,'SectionWordLengths');


        SectionFracLengths=dspGetLeafWidgetBase('edit',...
        'Section fraction lengths:',...
        'FLPS',this,'SectionFracLengths');


        OutputWordLength=dspGetLeafWidgetBase('edit',...
        'Output word length:',...
        'outputWordLength',this,'OutputWordLength');


        OutputFracLength=dspGetLeafWidgetBase('edit',...
        'Output fraction length:',...
        'outputFracLength',this,'OutputFracLength');

        SectionWordLengths.Visible=1;
        SectionFracLengths.Visible=1;
        OutputWordLength.Visible=1;
        OutputFracLength.Visible=1;

        if strcmpi(this.FilterInternals,'Full precision')
            SectionWordLengths.Visible=0;
            SectionFracLengths.Visible=0;
            OutputWordLength.Visible=0;
            OutputFracLength.Visible=0;

        elseif strcmpi(this.FilterInternals,'Minimum section word lengths')
            SectionWordLengths.Visible=0;
            SectionFracLengths.Visible=0;
            OutputFracLength.Visible=0;

        elseif strcmpi(this.FilterInternals,'Specify word lengths')
            SectionFracLengths.Visible=0;
            OutputFracLength.Visible=0;
        end

        paramsPane.Items={DecimationFactor,...
        DifferentialDelay,...
        NumberOfSections,...
        FilterInternals,...
        SectionWordLengths,...
        SectionFracLengths,...
        OutputWordLength,...
        OutputFracLength,...
        RateOptions};

    end


    mainPane=dspGetContainerWidgetBase('group','Parameters','mainPane');
    mainPane.RowSpan=[1,1];

    fvToolButton=dspGetLeafWidgetBase('pushbutton',...
    'View Filter Response',...
    'fvToolButton',0);
    fvToolButton.ToolTip=['Launches FVTool to inspect the frequency '...
    ,'response of the specified filter.'];
    fvToolButton.Alignment=4;
    fvToolButton.ColSpan=[1,1];
    fvToolButton.MatlabMethod='dspLinkFVTool2Mask';
    fvToolButton.MatlabArgs={this.Block.Handle,'create'};


    openDialogs=this.getOpenDialogs;
    if~isempty(openDialogs)
        fvToolButton.Enabled=~(openDialogs{1}.hasUnappliedChanges);
    else
        fvToolButton.Enabled=true;
    end

    buttonPanel=dspGetContainerWidgetBase('panel','Buttons','buttonPanel');
    buttonPanel.LayoutGrid=[1,3];
    buttonPanel.Items={fvToolButton};

    mainPane.Items={paramsPane,buttonPanel};

    dlgStruct=getBaseSchemaStruct(this,...
    mainPane,...
    this.Block.MaskDescription,...
    filterSourcePane);
    if(~isequal(mask_enables,old_mask_enables))
        set_param(blkh,'MaskEnables',mask_enables);
    end
