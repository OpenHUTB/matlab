function getSpecfromSysObj(this,hS,inputnumerictype)








    rcf=hS.getRateChangeFactors;
    toprcf=prod(rcf(:,2));
    this.RateChangeFactor=toprcf;


    inputdata=fi(zeros(toprcf,1),inputnumerictype);
    hS.setup(inputdata);
    hS.reset();


    filtSysObjs=hS.getFilters;
    ddcinternals=hS.getFixedPointParameters;

    filtersinputtype=ddcinternals.FiltersInputNumericType;
    coarsegainoutputtype=ddcinternals.CoarseCICScalingOutputNumericType;

    cicfinegain=ddcinternals.FineCICScaling;


    hCicSysObj=filtSysObjs.CICDecimator;
    hcicdecim=createhdlfilter(hCicSysObj,filtersinputtype);

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
    'OutputSLtype',fgainoutputsltype,...
    'RoundMode',cicfinegain.RoundMode,...
    'OverflowMode',strcmpi(cicfinegain.OverflowMode,'saturate'));


    hfir1=createhdlfilter(filtSysObjs.SecondFilterStage,filtersinputtype);

    hasSecondFIR=~isempty(filtSysObjs.ThirdFilterStage);
    ddcoutputtype=ddcinternals.OutputNumericType;
    [outputsz,outputbp,outputtsgn]=hdlfilter.getSizesfromNumericType(ddcoutputtype);
    outputsltype=hdlgetsltypefromsizes(outputsz,outputbp,outputtsgn);


    if hasSecondFIR
        hfir2=createhdlfilter(filtSysObjs.ThirdFilterStage,filtersinputtype);
        hfir2.OutputSLType=outputsltype;
    else
        hfir2=[];
        hfir1.OutputSltype=outputsltype;
    end


    hCascade=hdlfilter.mfiltcascade;
    hCascade.Stage=[hcicdecim,hscalar1,hscalar2,hfir1,hfir2];
    this.Filters=hCascade;
    this.Filters.RateChangeFactors=rcf;


    if isfield(ddcinternals,'NCOObject')
        hNCO=createhdlfilter(ddcinternals.NCOObject,inputnumerictype);
        this.NCO=hNCO;
    else
        this.NCO=[];
    end




    [inputsz,inputbp,inputsgn]=hdlfilter.getSizesfromNumericType(inputnumerictype);
    this.InputSLtype=hdlgetsltypefromsizes(inputsz,inputbp,inputsgn);
    this.OutputSLType=outputsltype;
    [finputsz,finputbp,finputsgn]=hdlfilter.getSizesfromNumericType(filtersinputtype);
    this.FiltersCastSLtype=hdlgetsltypefromsizes(finputsz,finputbp,finputsgn);




