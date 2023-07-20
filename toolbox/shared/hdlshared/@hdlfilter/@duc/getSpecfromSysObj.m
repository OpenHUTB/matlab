function getSpecfromSysObj(this,hS,inputnumerictype)








    rcf=hS.getRateChangeFactors;
    toprcf=prod(rcf(:,1));
    this.RateChangeFactor=toprcf;

    inputdata=fi(zeros(5,1),inputnumerictype);
    hS.setup(inputdata);
    hS.reset();


    filtSysObjs=hS.getFilters;
    ddcinternals=hS.getFixedPointParameters;

    ddcinputtype=ddcinternals.InputNumericType;
    filtoutputtype=ddcinternals.FiltersOutputNumericType;

    [filtopsz,filtopbp,filtopsgn]=hdlfilter.getSizesfromNumericType(filtoutputtype);
    filtopsltype=hdlgetsltypefromsizes(filtopsz,filtopbp,filtopsgn);

    this.FiltersCastSLtype=filtopsltype;

    hasFirstFIR=~isempty(filtSysObjs.FirstFilterStage);


    if hasFirstFIR
        hfir1=createhdlfilter(filtSysObjs.FirstFilterStage,ddcinputtype);
        hfir1.OutputSLType=filtopsltype;
        fir2inputtype=filtoutputtype;
    else
        hfir1=[];
        fir2inputtype=ddcinputtype;
    end


    hfir2=createhdlfilter(filtSysObjs.SecondFilterStage,fir2inputtype);


    hCicSysObj=filtSysObjs.CICInterpolator;
    hcicinterp=createhdlfilter(hCicSysObj,filtoutputtype);

    coarsegainoutputtype=ddcinternals.CoarseCICScalingOutputNumericType;

    cicfinegain=ddcinternals.FineCICScaling;

    cicoutputtype=numerictype([],hCicSysObj.OutputWordLength,hCicSysObj.OutputFractionLength);



    hscalar1=hdlfilter.scalar;
    cgainoutputtype=ddcinternals.CoarseCICScalingOutputNumericType;

    [cicoutputsz,cicoutputbp]=hdlfilter.getSizesfromNumericType(cicoutputtype);
    [cgainsz,cgainbp]=hdlfilter.getSizesfromNumericType(cgainoutputtype);

    bitshifts=cgainbp-cicoutputbp;

    hscalar1.InputSLType=hdlgetsltypefromsizes(cicoutputsz,cicoutputbp,1);
    hscalar1.Gain=2^-(bitshifts);
    hscalar1.CoeffSLType=hdlgetsltypefromsizes(2,bitshifts,1);

    hscalar1.OutputSLType=hdlgetsltypefromsizes(cgainsz,cgainbp,1);



    finegainsize=cicfinegain.WordLength;
    finegainbp=cicfinegain.FractionLength;
    fgainsltype=hdlgetsltypefromsizes(finegainsize,finegainbp,1);

    [fginputsz,fginputbp,fginputsgn]=hdlfilter.getSizesfromNumericType(coarsegainoutputtype);
    fgaininputsltype=hdlgetsltypefromsizes(fginputsz,fginputbp,fginputsgn);

    fgainoutputsltype=hdlgetsltypefromsizes(fginputsz+finegainsize,fginputbp+finegainbp,1);

    hscalar2=hdlfilter.scalar;
    hscalar2.set('Gain',cicfinegain.double,...
    'CoeffSLType',fgainsltype,...
    'InputSLType',fgaininputsltype,...
    'OutputSLtype',filtopsltype,...
    'RoundMode',cicfinegain.RoundMode,...
    'OverflowMode',strcmpi(cicfinegain.OverflowMode,'saturate'));

    ddcoutputtype=ddcinternals.OutputNumericType;
    [outputsz,outputbp,outputtsgn]=hdlfilter.getSizesfromNumericType(ddcoutputtype);
    outputsltype=hdlgetsltypefromsizes(outputsz,outputbp,outputtsgn);


    hCascade=hdlfilter.mfiltcascade;
    hCascade.Stage=[hfir1,hfir2,hcicinterp,hscalar1,hscalar2];
    this.Filters=hCascade;

    rcfpads=length(hCascade.stage)-size(rcf,1);

    this.Filters.RateChangeFactors=[rcf;ones(rcfpads,2)];


    if isfield(ddcinternals,'NCOObject')
        hNCO=createhdlfilter(ddcinternals.NCOObject,inputnumerictype);
        this.NCO=hNCO;
    else
        this.NCO=[];
    end



    [inputsz,inputbp,inputsgn]=hdlfilter.getSizesfromNumericType(inputnumerictype);
    this.InputSLtype=hdlgetsltypefromsizes(inputsz,inputbp,inputsgn);
    this.OutputSLType=outputsltype;





