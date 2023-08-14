function dlgStruct=getDialogSchema(this,~)



    blkh=this.Block.Handle;
    mask_enables=get_param(blkh,'MaskEnables');
    old_mask_enables=mask_enables;
    [~,iAccInc,~,iPhaseOffset,~,~,iDitherWL,...
    ~,~,iTableDepth,iHasOutputPhaseError,...
    ~,~,iOutputWL,iOutputFL,~,iSampleTime,iSamplesPerFrame]...
    =deal(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18);






    tabbedPane=dspGetContainerWidgetBase('tab','','tabPane');
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];






    AccIncSrc=dspGetLeafWidgetBase('combobox','Phase increment source:','AccIncSrc',this,'AccIncSrc');
    AccIncSrc.Entries=set(this,'AccIncSrc')';
    AccIncSrc.DialogRefresh=1;


    AccInc=dspGetLeafWidgetBase('edit','Phase increment:','AccInc',this,'AccInc');
    if strcmp(this.AccIncSrc,'Specify via dialog')
        AccInc.Visible=1;AccInc.Enabled=1;mask_enables{iAccInc}='on';
    else
        AccInc.Visible=0;AccInc.Enabled=0;mask_enables{iAccInc}='off';
    end
    if strcmp(get_param(bdroot(blkh),'Name'),'dspsrcs4')
        old_mask_enables{iAccInc}='on';
    end


    PhaseOffsetSrc=dspGetLeafWidgetBase('combobox','Phase offset source:','PhaseOffsetSrc',this,'PhaseOffsetSrc');
    PhaseOffsetSrc.Entries=set(this,'PhaseOffsetSrc')';
    PhaseOffsetSrc.DialogRefresh=1;


    PhaseOffset=dspGetLeafWidgetBase('edit','Phase offset:','PhaseOffset',this,'PhaseOffset');
    if strcmp(this.PhaseOffsetSrc,'Specify via dialog')
        PhaseOffset.Visible=1;PhaseOffset.Enabled=1;mask_enables{iPhaseOffset}='on';
    else
        PhaseOffset.Visible=0;PhaseOffset.Enabled=0;mask_enables{iPhaseOffset}='off';
    end


    HasDither=dspGetLeafWidgetBase('checkbox','Add internal dither','HasDither',this,'HasDither');
    HasDither.DialogRefresh=1;

    DitherWL=dspGetLeafWidgetBase('edit','Number of dither bits:','DitherWL',this,'DitherWL');


    if this.HasDither
        DitherWL.Visible=1;DitherWL.Enabled=1;mask_enables{iDitherWL}='on';

    else
        DitherWL.Visible=0;DitherWL.Enabled=0;mask_enables{iDitherWL}='off';

    end


    HasPhaseQuantizer=dspGetLeafWidgetBase('checkbox','Quantize phase',...
    'HasPhaseQuantizer',this,'HasPhaseQuantizer');
    HasPhaseQuantizer.DialogRefresh=1;
    quantBits=dspGetLeafWidgetBase('edit','Number of quantized accumulator bits:',...
    'TableDepth',this,'TableDepth');
    quantBits.DialogRefresh=1;

    HasOutputPhaseError=dspGetLeafWidgetBase('checkbox','Show phase quantization error port',...
    'HasOutputPhaseError',this,'HasOutputPhaseError');
    if this.HasPhaseQuantizer
        quantBits.Visible=1;quantBits.Enabled=1;mask_enables{iTableDepth}='on';
        HasOutputPhaseError.Visible=1;HasOutputPhaseError.Enabled=1;mask_enables{iHasOutputPhaseError}='on';
    else
        quantBits.Visible=0;quantBits.Enabled=0;mask_enables{iTableDepth}='off';
        HasOutputPhaseError.Visible=0;HasOutputPhaseError.Enabled=0;mask_enables{iHasOutputPhaseError}='off';
    end

    items={AccIncSrc,AccInc,PhaseOffsetSrc,PhaseOffset,HasDither,...
    DitherWL,HasPhaseQuantizer,quantBits,HasOutputPhaseError};

    phaseAdderPane=dspGetContainerWidgetBase('group','Phase adder parameters','phaseAdderPane');
    phaseAdderPane.Items=items;


    Formula=dspGetLeafWidgetBase('combobox','Output signal:','Formula',this,'Formula');
    Formula.Entries=set(this,'Formula')';


    SampleTime=dspGetLeafWidgetBase('edit','Sample time:','SampleTime',...
    this,'SampleTime');
    SampleTime.DialogRefresh=1;
    SamplesPerFrame=dspGetLeafWidgetBase('edit','Samples per frame:',...
    'SamplesPerFrame',this,'SamplesPerFrame');

    if(strcmpi(this.AccIncSrc,'Input port')||...
        strcmp(this.PhaseOffsetSrc,'Input port'))
        SampleTime.Visible=0;SampleTime.Enabled=0;mask_enables{iSampleTime}='off';
    else
        SampleTime.Visible=1;SampleTime.Enabled=1;mask_enables{iSampleTime}='on';
    end
    if strcmp(get_param(bdroot(blkh),'Name'),'dspsrcs4')
        old_mask_enables{iSampleTime}='on';
    end
    if(strcmpi(this.PhaseOffsetSrc,'Input port'))
        SamplesPerFrame.Visible=0;SamplesPerFrame.Enabled=0;mask_enables{iSamplesPerFrame}='off';
    else
        SamplesPerFrame.Visible=1;SamplesPerFrame.Enabled=1;mask_enables{iSamplesPerFrame}='on';
    end

    items={Formula,SampleTime,SamplesPerFrame};

    outputPane=dspGetContainerWidgetBase('group','Output parameters','outputPane');
    outputPane.Items=items;


    roundingModeLabel.Type='text';
    roundingModeLabel.Name='Rounding mode:';
    roundingModeLabel.Tag='roundingModeLabel';
    roundingModeLabel.RowSpan=[1,1];
    roundingModeLabel.ColSpan=[1,1];

    roundingModeValue.Type='text';
    roundingModeValue.Name='Floor';
    roundingModeValue.Tag='roundingModeValue';
    roundingModeValue.RowSpan=[1,1];
    roundingModeValue.ColSpan=[2,2];

    overflowModeLabel.Type='text';
    overflowModeLabel.Name='Overflow mode:';
    overflowModeLabel.Tag='overflowModeLabel';
    overflowModeLabel.RowSpan=[1,1];
    overflowModeLabel.ColSpan=[3,3];

    overflowModeValue.Type='text';
    overflowModeValue.Name='Wrap';
    overflowModeValue.Tag='overflowModeValue';
    overflowModeValue.RowSpan=[1,1];
    overflowModeValue.ColSpan=[4,4];

    fpaOperationalPane=dspGetContainerWidgetBase('group',...
    'Fixed-point operational parameters','fpaOperationalPane');
    fpaOperationalPane.Items={roundingModeLabel,roundingModeValue,...
    overflowModeLabel,overflowModeValue};
    fpaOperationalPane.LayoutGrid=[1,4];
    fpaOperationalPane.RowSpan=[1,1];
    fpaOperationalPane.ColSpan=[1,1];



    modeTitle=dspGetLeafWidgetBase('text','Data Type','modeTitle',0);
    modeTitle.RowSpan=[1,1];
    modeTitle.ColSpan=[2,2];
    modeTitle.Alignment=5;
    signedTitle=dspGetLeafWidgetBase('text','Signed','signedTitle',0);
    signedTitle.RowSpan=[1,1];
    signedTitle.ColSpan=[3,3];
    signedTitle.Alignment=5;
    wlTitle=dspGetLeafWidgetBase('text',' Word length','wlTitle',0);
    wlTitle.RowSpan=[1,1];
    wlTitle.ColSpan=[4,4];
    wlTitle.Alignment=5;
    flTitle=dspGetLeafWidgetBase('text','Fraction length','flTitle',0);
    flTitle.RowSpan=[1,1];
    flTitle.ColSpan=[5,5];
    flTitle.Alignment=5;

    accumTitle=dspGetLeafWidgetBase('text','Accumulator','accumTitle',0);
    accumTitle.RowSpan=[2,2];
    accumTitle.ColSpan=[1,1];
    accumTitle.Alignment=5;
    accumMode=dspGetLeafWidgetBase('text','Binary point scaling','accumMode',0);
    accumMode.RowSpan=[2,2];
    accumMode.ColSpan=[2,2];
    accumMode.Alignment=5;
    accumSign=dspGetLeafWidgetBase('text','yes','accumSign',0);
    accumSign.RowSpan=[2,2];
    accumSign.ColSpan=[3,3];
    accumSign.Alignment=5;
    accumWL=dspGetLeafWidgetBase('edit','','AccumWL',this,'AccumWL');
    accumWL.DialogRefresh=1;
    accumWL.RowSpan=[2,2];
    accumWL.ColSpan=[4,4];
    accumFL=dspGetLeafWidgetBase('text','0','AccumFL',0);
    accumFL.RowSpan=[2,2];
    accumFL.ColSpan=[5,5];
    accumFL.Alignment=5;

    outputTitle=dspGetLeafWidgetBase('text','Output','outputTitle',0);
    outputTitle.RowSpan=[3,3];
    outputTitle.ColSpan=[1,1];
    outputTitle.Alignment=5;
    outputMode=dspGetLeafWidgetBase('combobox','','DataType',this,'DataType');
    outputMode.Entries=set(this,'DataType')';
    outputMode.DialogRefresh=1;
    outputMode.RowSpan=[3,3];
    outputMode.ColSpan=[2,2];
    outputSign=dspGetLeafWidgetBase('text','yes','outputSign',0);
    outputSign.RowSpan=[3,3];
    outputSign.ColSpan=[3,3];
    outputSign.Alignment=5;
    outputWL=dspGetLeafWidgetBase('edit','','OutputWL',this,'OutputWL');
    outputWL.DialogRefresh=1;
    outputWL.RowSpan=[3,3];
    outputWL.ColSpan=[4,4];
    outputFL=dspGetLeafWidgetBase('edit','','OutputFL',this,'OutputFL');
    outputFL.RowSpan=[3,3];
    outputFL.ColSpan=[5,5];
    if(strcmpi(this.DataType,'double')||strcmpi(this.DataType,'single'))
        outputWL.Visible=0;outputWL.Enabled=0;mask_enables{iOutputWL}='off';
        outputFL.Visible=0;outputFL.Enabled=0;mask_enables{iOutputFL}='off';
    else
        outputWL.Visible=1;outputWL.Enabled=1;mask_enables{iOutputWL}='on';
        outputFL.Visible=1;outputFL.Enabled=1;mask_enables{iOutputFL}='on';
    end

    fpaDataTypePane=dspGetContainerWidgetBase('group','Data types','fpaDataTypePane');
    fpaDataTypePane.Items={modeTitle,signedTitle,wlTitle,flTitle,...
    accumTitle,accumMode,accumSign,accumWL,accumFL,...
    outputTitle,outputMode,outputSign,outputWL,outputFL};
    fpaDataTypePane.LayoutGrid=[4,5];
    fpaDataTypePane.RowStretch=[0,0,0,1];


    try
        tableAddrWLVal=eval(this.TableDepth);
        accWLVal=eval(this.AccumWL);
        Ts=eval(this.SampleTime);
        if strcmpi(this.DataType,'double')
            tableWidthVal=64;
        elseif strcmpi(this.DataType,'single')
            tableWidthVal=32;
        else
            tableWidthVal=eval(this.OutputWL);
        end

        fdeltaVal=2^(-accWLVal)/Ts;
        if fdeltaVal<1e-6
            fdeltaVal=fdeltaVal*1e9;
            fLabel=' nHz';
        elseif fdeltaVal<1e-3
            fdeltaVal=fdeltaVal*1e6;
            fLabel=' uHz';
        elseif fdeltaVal<1
            fdeltaVal=fdeltaVal*1e3;
            fLabel=' mHz';
        else
            fLabel=' Hz';
        end
        fdelta=num2str(fdeltaVal);
        fdelta=[fdelta,fLabel];


        if(this.HasDither)
            SFDR=num2str(6*tableAddrWLVal+12);
        else
            SFDR=num2str(6*tableAddrWLVal);
        end

        if this.HasPhaseQuantizer
            numDataPoint=num2str(2^(tableAddrWLVal-2)+1);
            memSize=num2str(round((2^(tableAddrWLVal-2)+1)*tableWidthVal/8));
        else
            numDataPoint=num2str(2^(accWLVal-2)+1);
            memSize=num2str(round((2^(accWLVal-2)+1)*tableWidthVal/8));
        end

    catch

        fdelta=['1/(2^',this.AccumWL,')/',this.SampleTime,' Hz'];

        if(this.HasDither)
            SFDR=[this.TableDepth,'*6+12'];
        else
            SFDR=[this.TableDepth,'*6'];
        end

        if this.HasPhaseQuantizer
            tableLengthStr=this.TableDepth;
        else
            tableLengthStr=this.AccumWL;
        end
        numDataPoint=['2^(',tableLengthStr,'-2)+1'];
        memSize=['(2^(',tableLengthStr,'-2)+1) * Output word length / 8'];
    end
    SFDR=[SFDR,' dBc'];
    memSize=[memSize,' bytes'];

    numDataPointLabel.Type='text';
    numDataPointLabel.Name='Number of data points for lookup table:';
    numDataPointLabel.Tag='numDataPointLabel';
    numDataPointLabel.RowSpan=[1,1];
    numDataPointLabel.ColSpan=[1,1];
    numDataPointValue.Type='text';
    numDataPointValue.Name=numDataPoint;
    numDataPointValue.Tag='numDataPointValue';
    numDataPointValue.RowSpan=[1,1];
    numDataPointValue.ColSpan=[2,2];

    memSizeLabel.Type='text';
    memSizeLabel.Name='Quarter wave sine lookup table size:';
    memSizeLabel.Tag='memSizeLabel';
    memSizeLabel.RowSpan=[2,2];
    memSizeLabel.ColSpan=[1,1];
    memSizeValue.Type='text';
    memSizeValue.Name=memSize;
    memSizeValue.Tag='memSizeValue';
    memSizeValue.RowSpan=[2,2];
    memSizeValue.ColSpan=[2,2];

    sfdrLabel.Type='text';
    sfdrLabel.Name='Theoretical spurious free dynamic range:';
    sfdrLabel.Tag='sfdrLabel';
    sfdrLabel.RowSpan=[3,3];
    sfdrLabel.ColSpan=[1,1];
    sfdrValue.Type='text';
    sfdrValue.Name=SFDR;
    sfdrValue.Tag='sfdrValue';
    sfdrValue.RowSpan=[3,3];
    sfdrValue.ColSpan=[2,2];
    if this.HasPhaseQuantizer
        fdeltaLabelRowNumber=4;
        sfdrLabel.Visible=1;sfdrLabel.Enabled=1;
        sfdrValue.Visible=1;sfdrValue.Enabled=1;
    else
        fdeltaLabelRowNumber=3;
        sfdrLabel.Visible=0;sfdrLabel.Enabled=0;
        sfdrValue.Visible=0;sfdrValue.Enabled=0;
    end

    fdeltaLabel.Type='text';
    fdeltaLabel.Name='Frequency resolution:';
    fdeltaLabel.Tag='fdeltaLabel';
    fdeltaLabel.RowSpan=[fdeltaLabelRowNumber,fdeltaLabelRowNumber];
    fdeltaLabel.ColSpan=[1,1];
    fdeltaValue.Type='text';
    fdeltaValue.Name=fdelta;
    fdeltaValue.Tag='fdeltaValue';
    fdeltaValue.RowSpan=[fdeltaLabelRowNumber,fdeltaLabelRowNumber];
    fdeltaValue.ColSpan=[2,2];
    if(strcmpi(this.AccIncSrc,'Input port')||...
        strcmp(this.PhaseOffsetSrc,'Input port'))
        fdeltaLabel.Visible=0;fdeltaLabel.Enabled=0;
        fdeltaValue.Visible=0;fdeltaValue.Enabled=0;
    else
        fdeltaLabel.Visible=1;fdeltaLabel.Enabled=1;
        fdeltaValue.Visible=1;fdeltaValue.Enabled=1;
    end

    analysisPane=dspGetContainerWidgetBase('group','NCO characterization','analysisPane');
    analysisPane.Items={numDataPointLabel,numDataPointValue,...
    memSizeLabel,memSizeValue,...
    sfdrLabel,sfdrValue,...
    fdeltaLabel,fdeltaValue};

    analysisPane.LayoutGrid=[1,2];
    analysisPane.RowSpan=[1,1];
    analysisPane.ColSpan=[1,1];
    analysisPane.ColStretch=[0,1];




    phaseAdderPane.RowSpan=[1,1];
    phaseAdderPane.ColSpan=[1,1];
    outputPane.RowSpan=[2,2];
    outputPane.ColSpan=[1,1];
    generalTab.Name='Main';
    generalTab.Items={phaseAdderPane,outputPane};
    generalTab.LayoutGrid=[3,1];
    generalTab.RowStretch=[0,0,1];

    fpaOperationalPane.RowSpan=[1,1];
    fpaOperationalPane.ColSpan=[1,1];
    fpaDataTypePane.RowSpan=[2,2];
    fpaDataTypePane.ColSpan=[1,1];
    dataTypeTab.Name='Data Types';
    dataTypeTab.Items={fpaOperationalPane,fpaDataTypePane};
    dataTypeTab.LayoutGrid=[3,1];
    dataTypeTab.RowStretch=[0,0,1];

    analysisPane.RowSpan=[1,1];
    analysisPane.ColSpan=[1,1];
    analysisTab.Name='NCO Characterization';
    analysisTab.Items={analysisPane};
    analysisTab.LayoutGrid=[2,1];
    analysisTab.RowStretch=[0,1];

    tabbedPane.Tabs={generalTab,dataTypeTab,analysisTab};

    dlgStruct=getBaseSchemaStruct(this,tabbedPane);
    if(~isequal(mask_enables,old_mask_enables))
        set_param(blkh,'MaskEnables',mask_enables);
    end

