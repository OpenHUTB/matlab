function dlgStruct=getDialogSchema(this,~)







    [TAPSUM,MULTIPLICAND,STAGEIO,COEFFS,~,~,STATE,~]=deal(1,2,3,4,5,6,7,8);

    [PARAMS_ON_DIALOG,~,DFILT_MODE]=deal(0,1,2);






    FilterSource=dspGetLeafWidgetBase('radiobutton',...
    'Coefficient source',...
    'FilterSource',...
    this,'FilterSource');

    FilterSource.Entries={'Dialog parameters',...
    'Input port(s)',...
    'Discrete-time filter object (DFILT)'};
    FilterSource.DialogRefresh=1;




    CoeffSource=dspGetLeafWidgetBase('combobox','Coefficient source:',...
    'CoeffSource',this,'CoeffSource');
    CoeffSource.Entries=set(this,'CoeffSource')';
    CoeffSource.Visible=0;







    paramsPanel=dspGetContainerWidgetBase('panel','Parameters','paramsPanel');


    inputProcessing=dspGetLeafWidgetBase('combobox',...
    'Input processing:',...
    'InputProcessing',...
    this,...
    'InputProcessing');
    inputProcessing.Entries=set(this,'InputProcessing')';
    inputProcessing.Enabled=1;
    inputProcessing.Visible=1;
    inputProcessing.DialogRefresh=1;

    if this.FilterSource==DFILT_MODE
        this.CoeffSource='Specify via dialog';

        dfiltPrompt='Filter:';
        dfiltObjectName=dspGetLeafWidgetBase('edit',...
        dfiltPrompt,...
        'dfiltObjectName',...
        this,'dfiltObjectName');
        dfiltObjectName.DialogRefresh=1;

        paramsPanel.Items={dfiltObjectName,CoeffSource,inputProcessing};


        hasFVToolButton=true;
        FVToolButtonEnabled=false;


        dfiltFixedMode=false;
        hd=[];
        if isfield(this.Block.UserData,'filter')
            hd=this.Block.UserData.filter;
            if~isempty(hd)
                FVToolButtonEnabled=true;
                dfiltFixedMode=strcmpi(hd.arithmetic,'fixed');
            end
        end

        MWDSP_CENTER=5;
        roundingModeLabel=dspGetLeafWidgetBase('text','Rounding mode:',...
        'roundingModeLabel',0);
        roundingModeLabel.RowSpan=[1,1];
        roundingModeLabel.ColSpan=[1,1];
        roundingModeLabel.Alignment=MWDSP_CENTER;

        if dfiltFixedMode
            roundingModeStr=dspGetSPRoundMode(hd.RoundMode);
            overflowModeStr=hd.OverflowMode;
            overflowModeStr=[upper(overflowModeStr(1)),overflowModeStr(2:end)];
        else
            roundingModeStr='Floor';
            overflowModeStr='Wrap';
        end
        roundingModeText=dspGetLeafWidgetBase('text',roundingModeStr,...
        'roundingModeText',0);
        roundingModeText.RowSpan=[1,1];
        roundingModeText.ColSpan=[2,2];
        roundingModeText.Alignment=MWDSP_CENTER;

        overflowModeLabel=dspGetLeafWidgetBase('text','Overflow mode:',...
        'overflowModeLabel',0);
        overflowModeLabel.RowSpan=[1,1];
        overflowModeLabel.ColSpan=[4,4];
        overflowModeLabel.Alignment=MWDSP_CENTER;

        overflowModeText=dspGetLeafWidgetBase('text',overflowModeStr,...
        'overflowModeText',0);
        overflowModeText.RowSpan=[1,1];
        overflowModeText.ColSpan=[5,5];
        overflowModeText.Alignment=MWDSP_CENTER;

        fpaOperationalPane=dspGetContainerWidgetBase('group',...
        'Fixed-point operational parameters',...
        'fpaOperationalPane');
        fpaOperationalPane.Items={roundingModeLabel,roundingModeText,...
        overflowModeLabel,overflowModeText};
        fpaOperationalPane.LayoutGrid=[1,5];
        fpaOperationalPane.RowSpan=[2,2];
        fpaOperationalPane.ColSpan=[1,1];


        modeTitle=dspGetLeafWidgetBase('text','Data Type','modeTitle',0);
        modeTitle.RowSpan=[1,1];
        modeTitle.ColSpan=[2,2];
        modeTitle.Alignment=MWDSP_CENTER;

        fpaDataTypePane=dspGetContainerWidgetBase('group',...
        'Fixed-point data types',...
        'fpaDataTypePane');
        dtRows={};
        rowNum=2;
        if dfiltFixedMode
            signedTitle=dspGetLeafWidgetBase('text','Signed','signedTitle',0);
            signedTitle.RowSpan=[1,1];
            signedTitle.ColSpan=[3,3];
            signedTitle.Alignment=MWDSP_CENTER;

            wlTitle=dspGetLeafWidgetBase('text',' Word length','wlTitle',0);
            wlTitle.RowSpan=[1,1];
            wlTitle.ColSpan=[4,4];
            wlTitle.Alignment=MWDSP_CENTER;

            flTitle=dspGetLeafWidgetBase('text','Fraction length','flTitle',0);
            flTitle.RowSpan=[1,1];
            flTitle.ColSpan=[5,6];
            flTitle.Alignment=MWDSP_CENTER;

            fpaDataTypePane.Items={modeTitle,signedTitle,wlTitle,flTitle};

            [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Input','input',...
            num2str(hd.InputWordLength),...
            num2str(hd.InputFracLength));
            if isFilterIIR(hd)

                if isFilterSOS(hd)
                    [dtRows,rowNum]=getSOSCoeffDataTypeRowItem(dtRows,rowNum,hd);
                else
                    [dtRows,rowNum]=getDualFracLengthDataTypeRowItem(dtRows,rowNum,'Coefficients','coeff',...
                    num2str(hd.CoeffWordLength),...
                    'Numerator:',...
                    num2str(hd.NumFracLength),...
                    'Denominator:',...
                    num2str(hd.DenFracLength));
                end

                [dtRows,rowNum]=getDualFracLengthDataTypeRowItem(dtRows,rowNum,'Product output','prod',...
                num2str(hd.ProductWordLength),...
                'Numerator product:',...
                num2str(hd.NumProdFracLength),...
                'Denominator product:',...
                num2str(hd.DenProdFracLength));


                [dtRows,rowNum]=getDualFracLengthDataTypeRowItem(dtRows,rowNum,'Accumulator','accum',...
                num2str(hd.AccumWordLength),...
                'Numerator accum:',...
                num2str(hd.NumAccumFracLength),...
                'Denominator accum:',...
                num2str(hd.DenAccumFracLength));

                switch class(hd)
                case 'dfilt.df1t'
                    [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Multiplicand',...
                    'multiplicand',...
                    num2str(hd.MultiplicandWordLength),...
                    num2str(hd.MultiplicandFracLength));

                    [dtRows,rowNum]=getDualFracLengthDataTypeRowItem(dtRows,rowNum,'State',...
                    'state',...
                    num2str(hd.StateWordLength),...
                    'Numerator state:',...
                    num2str(hd.NumStateFracLength),...
                    'Denominator state:',...
                    num2str(hd.DenStateFracLength));

                case{'dfilt.df2','dfilt.df2t'}
                    [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'State',...
                    'state',...
                    num2str(hd.StateWordLength),...
                    num2str(hd.StateFracLength));

                case 'dfilt.df1sos'
                    [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Section input',...
                    'sectionInput',...
                    num2str(hd.NumStateWordLength),...
                    num2str(hd.NumStateFracLength));

                    [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Section output',...
                    'sectionOutput',...
                    num2str(hd.DenStateWordLength),...
                    num2str(hd.DenStateFracLength));

                case 'dfilt.df1tsos'
                    [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Section input',...
                    'sectionInput',...
                    num2str(hd.SectionInputWordLength),...
                    num2str(hd.SectionInputFracLength));

                    [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Section output',...
                    'sectionOutput',...
                    num2str(hd.SectionOutputWordLength),...
                    num2str(hd.SectionOutputFracLength));

                    [dtRows,rowNum]=getDualFracLengthDataTypeRowItem(dtRows,rowNum,'State',...
                    'state',...
                    num2str(hd.StateWordLength),...
                    'Numerator state:',...
                    num2str(hd.NumStateFracLength),...
                    'Denominator state:',...
                    num2str(hd.DenStateFracLength));

                    [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Multiplicand',...
                    'multiplicand',...
                    num2str(hd.MultiplicandWordLength),...
                    num2str(hd.MultiplicandFracLength));

                case{'dfilt.df2sos','dfilt.df2tsos'}
                    [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Section input',...
                    'sectionInput',...
                    num2str(hd.SectionInputWordLength),...
                    num2str(hd.SectionInputFracLength));

                    [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Section output',...
                    'sectionOutput',...
                    num2str(hd.SectionOutputWordLength),...
                    num2str(hd.SectionOutputFracLength));

                    [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'State',...
                    'state',...
                    num2str(hd.StateWordLength),...
                    num2str(hd.StateFracLength));

                end


                [dtRows,~]=getDataTypeRowItem(...
                dtRows,rowNum,'Output','output',...
                num2str(hd.OutputWordLength),...
                num2str(hd.OutputFracLength));

            else

                if isFilterFIR(hd)
                    fracLengthStr=num2str(hd.NumFracLength);
                else
                    fracLengthStr=num2str(hd.LatticeFracLength);
                end
                [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Coefficients','coeff',...
                num2str(hd.CoeffWordLength),...
                fracLengthStr);


                [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Product output','prod',...
                num2str(hd.ProductWordLength),...
                num2str(hd.ProductFracLength));


                [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Accumulator','accum',...
                num2str(hd.AccumWordLength),...
                num2str(hd.AccumFracLength));

                switch class(hd)
                case 'dfilt.dffirt'
                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'State','state',...
                    'Same as accumulator');

                case{'dfilt.dfsymfir','dfilt.dfasymfir'}
                    [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'Tap sum','tapSum',...
                    num2str(hd.AccumWordLength),...
                    num2str(hd.AccumFracLength));

                case{'dfilt.latticear','dfilt.latticemamin'}
                    [dtRows,rowNum]=getDataTypeRowItem(dtRows,rowNum,'State',...
                    'state',...
                    num2str(hd.StateWordLength),...
                    num2str(hd.StateFracLength));

                end


                [dtRows,~]=getDataTypeRowItem(...
                dtRows,rowNum,'Output','output',...
                num2str(hd.OutputWordLength),...
                num2str(hd.OutputFracLength));
            end
        else
            fpaDataTypePane.Items={modeTitle};


            [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'Coefficients','coeff',...
            'Same word length as input');

            [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'Product output','prod',...
            'Same as input');

            [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'Accumulator','accum',...
            'Same as product output');
            if~isempty(hd)
                switch class(hd)
                case 'dfilt.df1t'
                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'Multiplicand','multiplicand',...
                    'Same as output');

                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'State','state',...
                    'Same as accumulator');

                case{'dfilt.df2','dfilt.df2t'}
                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'State','state',...
                    'Same as accumulator');

                case 'dfilt.df1sos'
                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'Section input','sectionInput',...
                    'Same as input');

                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'Section output','sectionOutput',...
                    'Same as output');

                case 'dfilt.df1tsos'
                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'Section input','sectionInput',...
                    'Same as input');

                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'Section output','sectionOutput',...
                    'Same as output');

                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'State','state',...
                    'Same as accumulator');

                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'Multiplicand','multiplicand',...
                    'Same as output');

                case{'dfilt.df2sos','dfilt.df2tsos'}
                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'Section input','sectionInput',...
                    'Same as input');

                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'Section output','sectionOutput',...
                    'Same as output');

                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'State','state',...
                    'Same as accumulator');

                case 'dfilt.dffirt'
                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'State','state',...
                    'Same as accumulator');

                case{'dfilt.dfsymfir','dfilt.dfasymfir'}
                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'Tap sum','tapSum',...
                    'Same as input');

                case{'dfilt.latticear','dfilt.latticemamin'}
                    [dtRows,rowNum]=getDefaultDataTypeRowItem(dtRows,rowNum,'State','state',...
                    'Same as accumulator');

                end
            end


            [dtRows,~]=getDefaultDataTypeRowItem(...
            dtRows,rowNum,'Output','output','Same as accumulator');
        end

        for ind=1:length(dtRows)
            fpaDataTypePane.Items=cat(2,fpaDataTypePane.Items,dtRows{ind});
        end
        fpaDataTypePane.LayoutGrid=[1+length(dtRows),6];
        colStretch=zeros(1,6);
        colStretch(5:6)=1;
        fpaDataTypePane.ColStretch=colStretch;
        fpaDataTypePane.RowSpan=[3,3];
        fpaDataTypePane.ColSpan=[1,1];

        discStr=getSPCUDTFltPtTrumpsDisclaimerStr(1);
        discText=dspGetLeafWidgetBase('text',...
        discStr,...
        'discText',...
        0);
        discText.WordWrap=1;

        discPane=dspGetContainerWidgetBase('panel',...
        '',...
        'discPane');
        discPane.Items={discText};
        discPane.RowSpan=[1,1];
        discPane.ColSpan=[1,1];

        emptyPanel=dspGetContainerWidgetBase('panel',...
        '',...
        'emptyPanel');

        emptyPanel.RowSpan=[2,2];
        emptyPanel.ColSpan=[1,1];

        dataTypeTab.Items={discPane,...
        emptyPanel,...
        fpaOperationalPane,...
        fpaDataTypePane};
    else


        ICs=dspGetLeafWidgetBase('edit','Initial conditions:',...
        'IC',this,'ICs');

        ZeroSideICs=dspGetLeafWidgetBase('edit',...
        'Initial conditions on zeros side:',...
        'ICnum',this,'ZeroSideICs');

        PoleSideICs=dspGetLeafWidgetBase('edit',...
        'Initial conditions on poles side:',...
        'ICden',this,'PoleSideICs');

        if this.FilterSource==PARAMS_ON_DIALOG

            this.CoeffSource='Specify via dialog';


            hasFVToolButton=true;
            FVToolButtonEnabled=false;

            if isfield(this.Block.UserData,'filterConstructor')
                FVToolButtonEnabled=true;
            end

            this.MaskFixptDialog.DataTypeRows(COEFFS).Visible=1;

            DialogModeTransferFunction=dspGetLeafWidgetBase('combobox',...
            'Transfer function type:',...
            'TypePopup',this,...
            'DialogModeTransferFunction');
            DialogModeTransferFunction.Entries=set(this,'DialogModeTransferFunction')';
            DialogModeTransferFunction.DialogRefresh=1;


            DialogModeIIRStructure=dspGetLeafWidgetBase('combobox','Filter structure:',...
            'IIRFiltStruct',this,...
            'DialogModeIIRStructure');
            DialogModeIIRStructure.Entries=set(this,'DialogModeIIRStructure')';
            DialogModeIIRStructure.DialogRefresh=1;


            DialogModeIIRAllPoleStructure=dspGetLeafWidgetBase('combobox','Filter structure:',...
            'AllPoleFiltStruct',this,...
            'DialogModeIIRAllPoleStructure');
            DialogModeIIRAllPoleStructure.Entries=set(this,'DialogModeIIRAllPoleStructure')';
            DialogModeIIRAllPoleStructure.DialogRefresh=1;


            DialogModeFIRStructure=dspGetLeafWidgetBase('combobox','Filter structure:',...
            'FIRFiltStruct',this,...
            'DialogModeFIRStructure');
            DialogModeFIRStructure.Entries=set(this,'DialogModeFIRStructure')';
            DialogModeFIRStructure.DialogRefresh=1;


            NumCoeffs=dspGetLeafWidgetBase('edit','Numerator coefficients:',...
            'NumCoeffs',this,'NumCoeffs');
            NumCoeffs.Tunable=1;

            DenCoeffs=dspGetLeafWidgetBase('edit','Denominator coefficients:',...
            'DenCoeffs',this,'DenCoeffs');
            DenCoeffs.Tunable=1;

            RefCoeffs=dspGetLeafWidgetBase('edit','Reflection coefficients:',...
            'LatticeCoeffs',this,'RefCoeffs');
            RefCoeffs.Tunable=1;

            SOSCoeffs=dspGetLeafWidgetBase('edit','SOS Matrix (Mx6):',...
            'BiQuadCoeffs',this,'SOSCoeffs');
            SOSCoeffs.Tunable=1;

            ScaleValues=dspGetLeafWidgetBase('edit','Scale values:',...
            'ScaleValues',this,'ScaleValues');
            ScaleValues.Tunable=1;

            if strcmp(this.DialogModeTransferFunction,'IIR (poles & zeros)')

                DialogModeIIRStructure.Visible=1;
                DialogModeIIRAllPoleStructure.Visible=0;
                DialogModeFIRStructure.Visible=0;

                RefCoeffs.Visible=0;


                this.MaskFixptDialog.DataTypeRows(TAPSUM).Visible=0;

                if strncmp(this.DialogModeIIRStructure,'Biquad direct',13)
                    SOSCoeffs.Visible=1;
                    ScaleValues.Visible=1;
                    NumCoeffs.Visible=0;
                    DenCoeffs.Visible=0;


                    this.MaskFixptDialog.DataTypeRows(STAGEIO).Visible=1;
                else
                    SOSCoeffs.Visible=0;
                    ScaleValues.Visible=0;

                    NumCoeffs.Visible=1;
                    DenCoeffs.Visible=1;


                    this.MaskFixptDialog.DataTypeRows(STAGEIO).Visible=0;
                end

                if(strcmp(this.DialogModeIIRStructure,'Direct form I')||...
                    strcmp(this.DialogModeIIRStructure,'Biquad direct form I (SOS)'))

                    this.MaskFixptDialog.DataTypeRows(STATE).Visible=0;
                else
                    this.MaskFixptDialog.DataTypeRows(STATE).Visible=1;
                end

                if(strcmp(this.DialogModeIIRStructure,'Direct form I transposed')||...
                    strcmp(this.DialogModeIIRStructure,'Biquad direct form I transposed (SOS)'))

                    this.MaskFixptDialog.DataTypeRows(MULTIPLICAND).Visible=1;
                else
                    this.MaskFixptDialog.DataTypeRows(MULTIPLICAND).Visible=0;
                end

                if(strcmp(this.DialogModeIIRStructure,'Direct form I')||...
                    strcmp(this.DialogModeIIRStructure,'Direct form I transposed')||...
                    strcmp(this.DialogModeIIRStructure,'Biquad direct form I (SOS)')||...
                    strcmp(this.DialogModeIIRStructure,'Biquad direct form I transposed (SOS)'))
                    ICs.Visible=0;
                    ZeroSideICs.Visible=1;
                    PoleSideICs.Visible=1;
                else
                    ICs.Visible=1;
                    ZeroSideICs.Visible=0;
                    PoleSideICs.Visible=0;
                end

            else
                DialogModeIIRStructure.Visible=0;

                ICs.Visible=1;
                ZeroSideICs.Visible=0;
                PoleSideICs.Visible=0;

                SOSCoeffs.Visible=0;
                ScaleValues.Visible=0;


                this.MaskFixptDialog.DataTypeRows(STAGEIO).Visible=0;

                this.MaskFixptDialog.DataTypeRows(MULTIPLICAND).Visible=0;

                if strcmp(this.DialogModeTransferFunction,'IIR (all poles)')

                    DialogModeFIRStructure.Visible=0;
                    DialogModeIIRAllPoleStructure.Visible=1;


                    this.MaskFixptDialog.DataTypeRows(TAPSUM).Visible=0;

                    NumCoeffs.Visible=0;

                    if strcmp(this.DialogModeIIRAllPoleStructure,'Lattice AR')
                        RefCoeffs.Visible=1;
                        DenCoeffs.Visible=0;
                    else
                        RefCoeffs.Visible=0;
                        DenCoeffs.Visible=1;
                    end

                    if strcmp(this.DialogModeIIRAllPoleStructure,'Direct form')

                        this.MaskFixptDialog.DataTypeRows(STATE).Visible=0;
                    else
                        this.MaskFixptDialog.DataTypeRows(STATE).Visible=1;
                    end

                else

                    DialogModeFIRStructure.Visible=1;
                    DialogModeIIRAllPoleStructure.Visible=0;

                    DenCoeffs.Visible=0;

                    if strcmp(this.DialogModeFIRStructure,'Lattice MA')
                        RefCoeffs.Visible=1;
                        NumCoeffs.Visible=0;
                    else
                        RefCoeffs.Visible=0;
                        NumCoeffs.Visible=1;
                    end

                    if(strcmp(this.DialogModeFIRStructure,'Direct form')||...
                        strcmp(this.DialogModeFIRStructure,'Direct form symmetric')||...
                        strcmp(this.DialogModeFIRStructure,'Direct form antisymmetric'))

                        this.MaskFixptDialog.DataTypeRows(STATE).Visible=0;
                    else
                        this.MaskFixptDialog.DataTypeRows(STATE).Visible=1;
                    end

                    if(strcmp(this.DialogModeFIRStructure,'Direct form symmetric')||...
                        strcmp(this.DialogModeFIRStructure,'Direct form antisymmetric'))

                        this.MaskFixptDialog.DataTypeRows(TAPSUM).Visible=1;
                    else
                        this.MaskFixptDialog.DataTypeRows(TAPSUM).Visible=0;
                    end
                end
            end
            paramsPanel.Items={DialogModeTransferFunction,...
            DialogModeIIRStructure,...
            DialogModeIIRAllPoleStructure,...
            DialogModeFIRStructure,...
            NumCoeffs,...
            DenCoeffs,...
            RefCoeffs,...
            SOSCoeffs,...
            ScaleValues,...
            inputProcessing,...
            ICs,...
            ZeroSideICs,...
            PoleSideICs,...
            CoeffSource};

        else

            this.CoeffSource='Input port(s)';


            hasFVToolButton=false;

            this.MaskFixptDialog.DataTypeRows(COEFFS).Visible=0;

            this.MaskFixptDialog.DataTypeRows(STAGEIO).Visible=0;


            PortsModeTransferFunction=dspGetLeafWidgetBase('combobox',...
            'Transfer function type:',...
            'TypePopup',...
            this,'PortsModeTransferFunction');
            PortsModeTransferFunction.Entries=set(this,'PortsModeTransferFunction')';
            PortsModeTransferFunction.DialogRefresh=1;


            PortsModeIIRStructure=dspGetLeafWidgetBase('combobox','Filter structure:',...
            'IIRFiltStruct',this,...
            'PortsModeIIRStructure');
            PortsModeIIRStructure.Entries=set(this,'PortsModeIIRStructure')';
            PortsModeIIRStructure.DialogRefresh=1;


            PortsModeIIRAllPoleStructure=dspGetLeafWidgetBase('combobox','Filter structure:',...
            'AllPoleFiltStruct',this,...
            'PortsModeIIRAllPoleStructure');
            PortsModeIIRAllPoleStructure.Entries=set(this,'PortsModeIIRAllPoleStructure')';
            PortsModeIIRAllPoleStructure.DialogRefresh=1;


            PortsModeFIRStructure=dspGetLeafWidgetBase('combobox','Filter structure:',...
            'FIRFiltStruct',this,...
            'PortsModeFIRStructure');
            PortsModeFIRStructure.Entries=set(this,'PortsModeFIRStructure')';
            PortsModeFIRStructure.DialogRefresh=1;


            prompt='First denominator coefficient = 1, remove a0 term in the structure';
            denIgnore=dspGetLeafWidgetBase('checkbox',...
            prompt,...
            'denIgnore',this,'denIgnore');

            FiltPerSampPopup=dspGetLeafWidgetBase('combobox',...
            'Coefficient update rate:',...
            'FiltPerSampPopup',this,...
            'FiltPerSampPopup');
            FiltPerSampPopup.Entries=set(this,'FiltPerSampPopup')';
            FiltPerSampPopup.Visible=strcmpi(this.inputProcessing,...
            'Columns as channels (frame based)');

            if strcmp(this.PortsModeTransferFunction,'IIR (poles & zeros)')

                PortsModeIIRStructure.Visible=1;
                PortsModeIIRAllPoleStructure.Visible=0;
                PortsModeFIRStructure.Visible=0;


                this.MaskFixptDialog.DataTypeRows(TAPSUM).Visible=0;

                denIgnore.Visible=1;

                if strcmp(this.PortsModeIIRStructure,'Direct form I')

                    this.MaskFixptDialog.DataTypeRows(STATE).Visible=0;
                else
                    this.MaskFixptDialog.DataTypeRows(STATE).Visible=1;
                end

                if strcmp(this.PortsModeIIRStructure,'Direct form I transposed')

                    this.MaskFixptDialog.DataTypeRows(MULTIPLICAND).Visible=1;
                else
                    this.MaskFixptDialog.DataTypeRows(MULTIPLICAND).Visible=0;
                end

                if(strcmp(this.PortsModeIIRStructure,'Direct form I')||...
                    strcmp(this.PortsModeIIRStructure,'Direct form I transposed'))
                    ICs.Visible=0;
                    ZeroSideICs.Visible=1;
                    PoleSideICs.Visible=1;
                else
                    ICs.Visible=1;
                    ZeroSideICs.Visible=0;
                    PoleSideICs.Visible=0;
                end

            else
                PortsModeIIRStructure.Visible=0;

                ICs.Visible=1;
                ZeroSideICs.Visible=0;
                PoleSideICs.Visible=0;


                this.MaskFixptDialog.DataTypeRows(MULTIPLICAND).Visible=0;

                if strcmp(this.PortsModeTransferFunction,'IIR (all poles)')

                    PortsModeFIRStructure.Visible=0;
                    PortsModeIIRAllPoleStructure.Visible=1;


                    this.MaskFixptDialog.DataTypeRows(TAPSUM).Visible=0;

                    if strcmp(this.PortsModeIIRAllPoleStructure,'Lattice AR')
                        denIgnore.Visible=0;
                    else
                        denIgnore.Visible=1;
                    end

                    if strcmp(this.PortsModeIIRAllPoleStructure,'Direct form')

                        this.MaskFixptDialog.DataTypeRows(STATE).Visible=0;
                    else
                        this.MaskFixptDialog.DataTypeRows(STATE).Visible=1;
                    end

                else

                    PortsModeFIRStructure.Visible=1;
                    PortsModeIIRAllPoleStructure.Visible=0;

                    denIgnore.Visible=0;

                    if(strcmp(this.PortsModeFIRStructure,'Direct form')||...
                        strcmp(this.PortsModeFIRStructure,'Direct form symmetric')||...
                        strcmp(this.PortsModeFIRStructure,'Direct form antisymmetric'))

                        this.MaskFixptDialog.DataTypeRows(STATE).Visible=0;
                    else
                        this.MaskFixptDialog.DataTypeRows(STATE).Visible=1;
                    end

                    if(strcmp(this.PortsModeFIRStructure,'Direct form symmetric')||...
                        strcmp(this.PortsModeFIRStructure,'Direct form antisymmetric'))

                        this.MaskFixptDialog.DataTypeRows(TAPSUM).Visible=1;

                        FiltPerSampPopup.Visible=0;
                    else
                        this.MaskFixptDialog.DataTypeRows(TAPSUM).Visible=0;
                        FiltPerSampPopup.Visible=strcmpi(this.inputProcessing,...
                        'Columns as channels (Frame-based)');
                    end
                end
            end
            paramsPanel.Items={PortsModeTransferFunction,...
            PortsModeIIRStructure,...
            PortsModeIIRAllPoleStructure,...
            PortsModeFIRStructure,...
            denIgnore,...
            inputProcessing,...
            FiltPerSampPopup,...
            ICs,...
            ZeroSideICs,...
            PoleSideICs,...
            CoeffSource};

        end

        dataTypeTab.Items={this.MaskFixptDialog.getDialogSchemaStruct};
    end

    dataTypeTab.Name='Data Types';




    mainPane=dspGetContainerWidgetBase('group','Parameters','mainPane');
    mainPane.RowSpan=[1,1];

    if hasFVToolButton

        fvToolButton=dspGetLeafWidgetBase('pushbutton',...
        'View Filter Response',...
        'fvToolButton',0);
        fvToolButton.ToolTip=['Launches FVTool to inspect the frequency '...
        ,'response of the specified filter.'];
        fvToolButton.Alignment=4;
        fvToolButton.ColSpan=[1,1];
        fvToolButton.MatlabMethod='dspLinkFVTool2Mask';
        fvToolButton.MatlabArgs={this.Block.Handle,'create'};

        fvToolButton.Enabled=FVToolButtonEnabled;

        openDialogs=this.getOpenDialogs;
        if~isempty(openDialogs)
            if openDialogs{1}.hasUnappliedChanges
                fvToolButton.Enabled=0;
            end
        end

        buttonPanel=dspGetContainerWidgetBase('panel','Buttons','buttonPanel');
        buttonPanel.LayoutGrid=[1,3];
        buttonPanel.Items={fvToolButton};

        mainPane.Items={paramsPanel,buttonPanel};
    else
        mainPane.Items={paramsPanel};
    end

    generalTab.Name='Main';
    generalTab.Items={mainPane};

    numGeneralTabItems=length(generalTab.Items);
    generalTab.LayoutGrid=[1+numGeneralTabItems,1];
    generalTab.RowStretch=[zeros(1,numGeneralTabItems),1];

    numDataTypeTabItems=length(dataTypeTab.Items);
    dataTypeTab.LayoutGrid=[1+numDataTypeTabItems,1];
    dataTypeTab.RowStretch=[zeros(1,numDataTypeTabItems),1];


    tabbedPane=dspGetContainerWidgetBase('tab','','tabPane');
    tabbedPane.RowSpan=[3,3];
    tabbedPane.ColSpan=[1,1];

    tabbedPane.Tabs={generalTab,dataTypeTab};


    filterSourcePane=dspGetContainerWidgetBase('panel','','filterSourcePane');
    filterSourcePane.Items={FilterSource};
    filterSourcePane.RowSpan=[2,2];
    filterSourcePane.ColSpan=[1,1];

    dlgStruct=getBaseSchemaStruct(this,...
    tabbedPane,...
    this.Block.MaskDescription,...
    filterSourcePane);


    function[dtRows,row]=getDualFracLengthDataTypeRowItem(dtRows,row,name,prefix,...
        WLText,...
        FL1Label,FL1Text,...
        FL2Label,FL2Text)
        dtIdxRow=length(dtRows)+1;
        [NAME,MODE,SIGN,WL,FLBL,FTXT]=deal(1,2,3,4,5,6);
        MWDSP_TOP_LEFT=1;
        MWDSP_CENTER_LEFT=4;
        MWDSP_CENTER=5;


        widgets{NAME}=dspGetLeafWidgetBase('text',name,name,0);
        widgets{NAME}.ColSpan=[NAME,NAME];
        widgets{NAME}.Alignment=MWDSP_CENTER;


        widgets{MODE}=dspGetLeafWidgetBase('text','Binary point scaling',[prefix,'ModeDual'],...
        0);
        widgets{MODE}.ColSpan=[MODE,MODE];
        widgets{MODE}.Alignment=MWDSP_CENTER;


        widgets{SIGN}=dspGetLeafWidgetBase('text','yes',...
        [prefix,'Signed'],...
        0);
        widgets{SIGN}.ColSpan=[SIGN,SIGN];
        widgets{SIGN}.Alignment=MWDSP_CENTER;


        widgets{WL}=dspGetLeafWidgetBase('text',WLText,...
        [prefix,'WordLength'],...
        0);
        widgets{WL}.ColSpan=[WL,WL];
        widgets{WL}.Alignment=MWDSP_CENTER;


        fl1widgets{1}=dspGetLeafWidgetBase('text',FL1Label,...
        [prefix,'FracLength1Label'],0);
        fl1widgets{1}.RowSpan=[row,row];
        fl1widgets{1}.ColSpan=[FLBL,FLBL];
        fl1widgets{1}.Alignment=MWDSP_CENTER_LEFT;

        fl1widgets{2}=dspGetLeafWidgetBase('text',FL1Text,...
        [prefix,'FracLength1Text'],0);
        fl1widgets{2}.RowSpan=[row,row];
        fl1widgets{2}.ColSpan=[FTXT,FTXT];
        fl1widgets{2}.Alignment=MWDSP_CENTER_LEFT;

        fl2widgets{1}=dspGetLeafWidgetBase('text',FL2Label,...
        [prefix,'FracLength2Label'],0);
        fl2widgets{1}.RowSpan=[row+1,row+1];
        fl2widgets{1}.ColSpan=[FLBL,FLBL];
        fl2widgets{1}.Alignment=MWDSP_TOP_LEFT;

        fl2widgets{2}=dspGetLeafWidgetBase('text',FL2Text,...
        [prefix,'FracLength2Text'],0);
        fl2widgets{2}.RowSpan=[row+1,row+1];
        fl2widgets{2}.ColSpan=[FTXT,FTXT];
        fl2widgets{2}.Alignment=MWDSP_TOP_LEFT;

        for i=1:length(widgets)
            widgets{i}.RowSpan=[row,row];
        end

        dtRows{dtIdxRow}=widgets;
        dtRows{dtIdxRow+1}=fl1widgets;
        dtRows{dtIdxRow+2}=fl2widgets;
        row=row+2;




        function[dtRows,row]=getSOSCoeffDataTypeRowItem(dtRows,row,hd)

            dtIdxRow=length(dtRows)+1;

            coeffWLStr=num2str(hd.CoeffWordLength);
            numFLStr=num2str(hd.NumFracLength);
            denFLStr=num2str(hd.DenFracLength);
            svFLStr=num2str(hd.ScaleValueFracLength);

            [NAME,MODE,SIGN,WL,FLBL,FTXT]=deal(1,2,3,4,5,6);
            MWDSP_TOP_LEFT=1;
            MWDSP_CENTER_LEFT=4;
            MWDSP_CENTER=5;


            widgets{NAME}=dspGetLeafWidgetBase('text','Coefficients','Coefficients',0);
            widgets{NAME}.ColSpan=[NAME,NAME];
            widgets{NAME}.Alignment=MWDSP_CENTER;


            widgets{MODE}=dspGetLeafWidgetBase('text','Binary point scaling','coeffMode',...
            0);
            widgets{MODE}.ColSpan=[MODE,MODE];
            widgets{MODE}.Alignment=MWDSP_CENTER;


            widgets{SIGN}=dspGetLeafWidgetBase('text','yes',...
            'coeffSigned',...
            0);
            widgets{SIGN}.ColSpan=[SIGN,SIGN];
            widgets{SIGN}.Alignment=MWDSP_CENTER;


            widgets{WL}=dspGetLeafWidgetBase('text',coeffWLStr,...
            'coeffWordLength',...
            0);
            widgets{WL}.ColSpan=[WL,WL];
            widgets{WL}.Alignment=MWDSP_CENTER;


            fl1widgets{1}=dspGetLeafWidgetBase('text','Numerator:',...
            'numFracLengthLabel',0);
            fl1widgets{1}.RowSpan=[row,row];
            fl1widgets{1}.ColSpan=[FLBL,FLBL];
            fl1widgets{1}.Alignment=MWDSP_CENTER_LEFT;

            fl1widgets{2}=dspGetLeafWidgetBase('text',numFLStr,...
            'numFracLengthText',0);
            fl1widgets{2}.RowSpan=[row,row];
            fl1widgets{2}.ColSpan=[FTXT,FTXT];
            fl1widgets{2}.Alignment=MWDSP_CENTER_LEFT;

            fl2widgets{1}=dspGetLeafWidgetBase('text','Denominator:',...
            'denFracLengthLabel',0);
            fl2widgets{1}.RowSpan=[row+1,row+1];
            fl2widgets{1}.ColSpan=[FLBL,FLBL];
            fl2widgets{1}.Alignment=MWDSP_TOP_LEFT;

            fl2widgets{2}=dspGetLeafWidgetBase('text',denFLStr,...
            'denFracLengthText',0);
            fl2widgets{2}.RowSpan=[row+1,row+1];
            fl2widgets{2}.ColSpan=[FTXT,FTXT];
            fl2widgets{2}.Alignment=MWDSP_TOP_LEFT;

            fl3widgets{1}=dspGetLeafWidgetBase('text','Scale values:',...
            'scaleValueFracLengthLabel',0);
            fl3widgets{1}.RowSpan=[row+2,row+2];
            fl3widgets{1}.ColSpan=[FLBL,FLBL];
            fl3widgets{1}.Alignment=MWDSP_TOP_LEFT;

            fl3widgets{2}=dspGetLeafWidgetBase('text',svFLStr,...
            'scaleValueFracLengthText',0);
            fl3widgets{2}.RowSpan=[row+2,row+2];
            fl3widgets{2}.ColSpan=[FTXT,FTXT];
            fl3widgets{2}.Alignment=MWDSP_TOP_LEFT;

            for i=1:length(widgets)
                widgets{i}.RowSpan=[row,row];
            end

            dtRows{dtIdxRow}=widgets;
            dtRows{dtIdxRow+1}=fl1widgets;
            dtRows{dtIdxRow+2}=fl2widgets;
            dtRows{dtIdxRow+3}=fl3widgets;
            row=row+3;


            function[dtRows,row]=getDataTypeRowItem(dtRows,row,name,prefix,...
                WLText,...
                FLText)
                dtIdx=length(dtRows)+1;
                [NAME,MODE,SIGN,WL,FL]=deal(1,2,3,4,5);
                MWDSP_CENTER=5;


                widgets{NAME}=dspGetLeafWidgetBase('text',name,name,0);
                widgets{NAME}.ColSpan=[1,1];
                widgets{NAME}.Alignment=MWDSP_CENTER;


                widgets{MODE}=dspGetLeafWidgetBase('text','Binary point scaling',[prefix,'Mode'],...
                0);
                widgets{MODE}.ColSpan=[2,2];
                widgets{MODE}.Alignment=MWDSP_CENTER;


                widgets{SIGN}=dspGetLeafWidgetBase('text','yes',...
                [prefix,'Signed'],...
                0);
                widgets{SIGN}.ColSpan=[3,3];
                widgets{SIGN}.Alignment=MWDSP_CENTER;


                widgets{WL}=dspGetLeafWidgetBase('text',WLText,...
                [prefix,'WordLength'],...
                0);
                widgets{WL}.ColSpan=[4,4];
                widgets{WL}.Alignment=MWDSP_CENTER;


                widgets{FL}=dspGetLeafWidgetBase('text',FLText,...
                [prefix,'FracLength'],...
                0);
                widgets{FL}.ColSpan=[5,6];
                widgets{FL}.Alignment=MWDSP_CENTER;

                for i=1:length(widgets)
                    widgets{i}.RowSpan=[row,row];
                end

                dtRows{dtIdx}=widgets;
                row=row+1;


                function[dtRows,row]=getDefaultDataTypeRowItem(dtRows,row,name,prefix,mode)
                    dtIdx=length(dtRows)+1;
                    [NAME,MODE]=deal(1,2);
                    MWDSP_CENTER=5;


                    widgets{NAME}=dspGetLeafWidgetBase('text',name,name,0);
                    widgets{NAME}.ColSpan=[1,1];
                    widgets{NAME}.Alignment=MWDSP_CENTER;


                    widgets{MODE}=dspGetLeafWidgetBase('text',mode,[prefix,'ModeDefault'],...
                    0);
                    widgets{MODE}.ColSpan=[2,2];
                    widgets{MODE}.Alignment=MWDSP_CENTER;

                    for i=1:length(widgets)
                        widgets{i}.RowSpan=[row,row];
                    end

                    dtRows{dtIdx}=widgets;
                    row=row+1;


                    function isIIR=isFilterIIR(hd)
                        isIIR=isFilterBasicIIR(hd)||isFilterSOS(hd);


                        function isBasicIIR=isFilterBasicIIR(hd)
                            isBasicIIR=(isa(hd,'dfilt.df1')||...
                            isa(hd,'dfilt.df1t')||...
                            isa(hd,'dfilt.df2')||...
                            isa(hd,'dfilt.df2t'));


                            function isSOS=isFilterSOS(hd)
                                isSOS=(isa(hd,'dfilt.df1sos')||...
                                isa(hd,'dfilt.df1tsos')||...
                                isa(hd,'dfilt.df2sos')||...
                                isa(hd,'dfilt.df2tsos'));


                                function isFIR=isFilterFIR(hd)
                                    isFIR=(isa(hd,'dfilt.dffir')||...
                                    isa(hd,'dfilt.dffirt')||...
                                    isa(hd,'dfilt.dfsymfir')||...
                                    isa(hd,'dfilt.dfasymfir'));




