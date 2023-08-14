function loadFromBlock(this)






    switch this.Block.FilterSource
    case 'Specify via dialog'
        this.FilterSource=0;

        if(strcmp(this.Block.CoeffSource,'Input port(s)')&&...
            ~(strcmp(this.Block.TypePopup,'IIR (poles & zeros)')&&...
            strncmp(this.Block.IIRFiltStruct,'Biquad direct',13)))
            this.FilterSource=1;
        end

    case 'Input port(s)'
        this.FilterSource=1;

    case 'dfilt object'
        this.FilterSource=2;
    end


    this.dfiltObjectName=this.Block.dfiltObjectName;

    this.DialogModeTransferFunction=this.Block.TypePopup;
    this.DialogModeIIRStructure=this.Block.IIRFiltStruct;
    this.DialogModeIIRAllPoleStructure=this.Block.AllPoleFiltStruct;
    this.DialogModeFIRStructure=this.Block.FIRFiltStruct;
    this.NumCoeffs=this.Block.NumCoeffs;
    this.DenCoeffs=this.Block.DenCoeffs;
    this.RefCoeffs=this.Block.LatticeCoeffs;
    this.SOSCoeffs=this.Block.BiQuadCoeffs;
    this.ScaleValues=this.Block.ScaleValues;

    this.PortsModeTransferFunction=this.Block.TypePopup;
    if strncmp(this.Block.IIRFiltStruct,'Biquad direct',13)
        this.PortsModeIIRStructure='Direct form II transposed';
    else
        this.PortsModeIIRStructure=this.Block.IIRFiltStruct;
    end
    this.PortsModeIIRAllPoleStructure=this.Block.AllPoleFiltStruct;
    this.PortsModeFIRStructure=this.Block.FIRFiltStruct;
    this.denIgnore=strcmpi(this.Block.denIgnore,'on');
    this.FiltPerSampPopup=this.Block.FiltPerSampPopup;

    this.ICs=this.Block.IC;
    this.ZeroSideICs=this.Block.ICnum;
    this.PoleSideICs=this.Block.ICden;
    this.InputProcessing=this.Block.InputProcessing;

    this.MaskFixptDialog.loadFromBlock;
