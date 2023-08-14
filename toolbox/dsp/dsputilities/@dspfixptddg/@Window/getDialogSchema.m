function dlgStruct=getDialogSchema(this,~)











    winmode=dspGetLeafWidgetBase('combobox','Operation:','winmode',...
    this,'winmode');
    winmode.Entries=set(this,'winmode')';
    winmode.DialogRefresh=1;


    wintype=dspGetLeafWidgetBase('combobox','Window type:','wintype',...
    this,'wintype');
    wintype.Entries=set(this,'wintype')';
    wintype.DialogRefresh=1;

    isSimModeNormal=strcmp(get_param(bdroot(gcs),'SimulationMode'),'normal');
    if isSimModeNormal
        wintype.Tunable=1;
    end


    sampmode=dspGetLeafWidgetBase('combobox','Sample mode: ','sampmode',...
    this,'sampmode');
    sampmode.Entries=set(this,'sampmode')';
    sampmode.DialogRefresh=1;


    samptime=dspGetLeafWidgetBase('edit','Sample time:','samptime',...
    this,'samptime');


    N=dspGetLeafWidgetBase('edit','Window length:','N',this,'N');


    Rs=dspGetLeafWidgetBase('edit','Stopband attenuation in dB:','Rs',...
    this,'Rs');
    if isSimModeNormal
        Rs.Tunable=1;
    end


    beta=dspGetLeafWidgetBase('edit','Beta:','beta',this,'beta');
    if isSimModeNormal
        beta.Tunable=1;
    end


    numSidelobes=dspGetLeafWidgetBase('edit','Number of sidelobes:',...
    'numSidelobes',this,'numSidelobes');
    if isSimModeNormal
        numSidelobes.Tunable=1;
    end


    sidelobeLevel=dspGetLeafWidgetBase('edit','Maximum sidelobe level relative to mainlobe (dB):',...
    'sidelobeLevel',this,'sidelobeLevel');
    if isSimModeNormal
        sidelobeLevel.Tunable=1;
    end


    winsamp=dspGetLeafWidgetBase('combobox','Sampling:','winsamp',...
    this,'winsamp');
    winsamp.Entries=set(this,'winsamp')';
    if isSimModeNormal
        winsamp.Tunable=1;
    end


    UserWindow=dspGetLeafWidgetBase('edit','Window function name:',...
    'UserWindow',this,'UserWindow');
    UserWindow.DialogRefresh=1;


    txt='The window length is automatically passed in as the first argument to the ';
    txt=[txt,this.UserWindow,' function.'];
    FirstArgText=dspGetLeafWidgetBase('text',txt,...
    'FirstArgText',this);

    FirstArgTextSpacer=dspGetLeafWidgetBase('text','   ',...
    'FirstArgTextSpacer',this);
    maxSize=[5,5];
    FirstArgTextSpacer.MaximumSize=maxSize;
    FirstArgTextSpacer2=dspGetLeafWidgetBase('text','   ',...
    'FirstArgTextSpacer2',this);
    FirstArgTextSpacer2.MaximumSize=maxSize;


    prompt='Specify additional arguments to the ';
    prompt=[prompt,this.UserWindow,' function'];
    OptParams=dspGetLeafWidgetBase('checkbox',prompt,...
    'OptParams',this,'OptParams');
    OptParams.DialogRefresh=1;


    prompt='Cell array of additional arguments';
    UserParams=dspGetLeafWidgetBase('edit',prompt,...
    'UserParams',this,'UserParams');



    if strcmp(this.winmode,'Generate window')
        sampmode.Visible=1;
        N.Visible=1;
        setVisibleandEnableBits(this.Block,'N','on');
        if strcmp(this.sampmode,'Discrete')
            samptime.Visible=1;
            setVisibleandEnableBits(this.Block,'samptime','on');
        else
            samptime.Visible=0;
            setVisibleandEnableBits(this.Block,'samptime','off');
        end
    else
        sampmode.Visible=0;
        N.Visible=0;
        setVisibleandEnableBits(this.Block,'N','off');
        samptime.Visible=0;
        setVisibleandEnableBits(this.Block,'samptime','off');
    end

    if strcmp(this.wintype,'Chebyshev')
        Rs.Visible=1;
        setVisibleandEnableBits(this.Block,'Rs','on');
    else
        Rs.Visible=0;
        setVisibleandEnableBits(this.Block,'Rs','off');
    end

    if strcmp(this.wintype,'Kaiser')
        beta.Visible=1;
        setVisibleandEnableBits(this.Block,'beta','on');
    else
        beta.Visible=0;
        setVisibleandEnableBits(this.Block,'beta','off');
    end

    if strcmp(this.wintype,'Taylor')
        numSidelobes.Visible=1;
        sidelobeLevel.Visible=1;
        setVisibleandEnableBits(this.Block,'numSidelobes','on');
        setVisibleandEnableBits(this.Block,'sidelobeLevel','on');
    else
        numSidelobes.Visible=0;
        sidelobeLevel.Visible=0;
        setVisibleandEnableBits(this.Block,'numSidelobes','off');
        setVisibleandEnableBits(this.Block,'sidelobeLevel','off');
    end

    if any(strcmp(this.wintype,{'Blackman','Hamming','Hanning','Hann'}))
        winsamp.Visible=1;
    else
        winsamp.Visible=0;
    end

    if strcmp(this.wintype,'User defined')
        UserWindow.Visible=1;
        setVisibleandEnableBits(this.Block,'UserWindow','on');
        FirstArgText.Visible=1;
        FirstArgTextSpacer.Visible=1;
        FirstArgTextSpacer2.Visible=1;
        OptParams.Visible=1;
        if this.OptParams
            UserParams.Visible=1;
            setVisibleandEnableBits(this.Block,'UserParams','on');
        else
            UserParams.Visible=0;
            setVisibleandEnableBits(this.Block,'UserParams','off');
        end
    else
        UserWindow.Visible=0;
        setVisibleandEnableBits(this.Block,'UserWindow','off');
        FirstArgText.Visible=0;
        FirstArgTextSpacer.Visible=0;
        FirstArgTextSpacer2.Visible=0;
        OptParams.Visible=0;
        UserParams.Visible=0;
    end





    items={...
    winmode,...
    wintype,...
    sampmode,...
    samptime,...
    N,...
    Rs,...
    beta,...
    numSidelobes,...
    sidelobeLevel,...
    winsamp,...
    UserWindow,...
    FirstArgTextSpacer,...
    FirstArgText,...
    FirstArgTextSpacer2,...
    OptParams,...
    UserParams,...
    };

    dlgStruct=this.getRootSchemaStruct(items);

    dlgStruct.PreApplyCallback='dspDDGPreApplyWithFracLengthUpdate';
    dlgStruct.PreApplyArgs={this,'%dialog',...
    {'firstCoeffFracLength'},...
    this.FixptDialog.DataTypeRows(3).BestPrecString};










    dataType=dspGetLeafWidgetBase('combobox','Window data type:','dataType',...
    this,'dataType');
    dataType.Entries=set(this,'dataType')';
    dataType.DialogRefresh=1;


    isSigned=dspGetLeafWidgetBase('checkbox','Signed',...
    'isSigned',this,'isSigned');


    wordLen=dspGetLeafWidgetBase('edit','Word length:','wordLen',...
    this,'wordLen');


    prompt='User-defined data type  (e.g. sfix(16), float(''single'')):';
    udDataType=dspGetLeafWidgetBase('edit',prompt,'udDataType',...
    this,'udDataType');
    udDataType.DialogRefresh=1;


    fracBitsMode=dspGetLeafWidgetBase('combobox',...
    'Set fraction length in output to:',...
    'fracBitsMode',this,'fracBitsMode');
    fracBitsMode.Entries=set(this,'fracBitsMode')';
    fracBitsMode.DialogRefresh=1;


    numFracBits=dspGetLeafWidgetBase('edit','Fraction length:',...
    'numFracBits',this,'numFracBits');


    if any(strcmp(this.dataType,{'double','single','Inherit via back propagation'}))
        isSigned.Visible=0;
        wordLen.Visible=0;
        udDataType.Visible=0;
        fracBitsMode.Visible=0;
        numFracBits.Visible=0;
    elseif strcmp(this.dataType,'Fixed-point')
        isSigned.Visible=1;
        wordLen.Visible=1;
        udDataType.Visible=0;
        fracBitsMode.Visible=1;
        if strcmp(this.fracBitsMode,'Best precision')
            numFracBits.Visible=0;
        else
            numFracBits.Visible=1;
        end
    else
        isSigned.Visible=0;
        wordLen.Visible=0;
        udDataType.Visible=1;
        if dspDataTypeDeterminesFracBits(this.udDataType)
            fracBitsMode.Visible=0;
            numFracBits.Visible=0;
        else
            fracBitsMode.Visible=1;
            if strcmp(this.fracBitsMode,'Best precision')
                numFracBits.Visible=0;
            else
                numFracBits.Visible=1;
            end
        end
    end


    sourceParamPanel=dspGetContainerWidgetBase('panel','','sourceParamPanel');
    sourceParamPanel.Items={dataType,...
    isSigned,...
    wordLen,...
    udDataType,...
    fracBitsMode,...
    numFracBits'};
    sourceParamPanel.ColSpan=[1,1];
    sourceParamPanel.Source=this;



    sourceParamPanel.RowSpan=...
    dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.Items{end}.RowSpan;

    dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.Items{end}.RowSpan=...
    dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.Items{end}.RowSpan+[1,1];

    dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.Items{end+1}=sourceParamPanel;

    dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.LayoutGrid=...
    dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.LayoutGrid+[1,0];

    dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.RowStretch=...
    [0,dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.RowStretch];


    len=length(dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.Items)-1;
    if strcmp(this.winmode,'Generate window')
        for ii=1:len
            dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.Items{ii}.Visible=0;
        end
        dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.Items{end}.Visible=1;
    else
        for ii=1:len
            dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.Items{ii}.Visible=1;
        end
        dlgStruct.Items{1}.Items{2}.Tabs{2}.Items{1}.Items{end}.Visible=0;
    end




    function setVisibleandEnableBits(myBlk,propName,state)




        ind=find(ismember(myBlk.MaskNames,propName)==1);

        myBlk.MaskVisibilities{ind}=state;
        myBlk.MaskEnables{ind}=state;