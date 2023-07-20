function lookuptable=semiconductorSubcircuit2lookup(subcircuitFile,subcircuitName,varargin)





























































































































    netlistsObj=ee.internal.spice.lookuptable.generateSemiconductorNetlist(subcircuitFile,subcircuitName);


    parseObj=inputParser;




    lookuptable=struct();


    defaultSPICEPath="C:\Program Files\SIMetrix850\bin64\Sim.exe";



    validBoolean=@(x)(x==0)||(x==1);
    validstringorchar=@(x)(isstring(x)||ischar(x));
    validScalarPosNum=@(x)isnumeric(x)&&isscalar(x)&&(x>0);
    validScalarNonNegNum=@(x)isnumeric(x)&&isscalar(x)&&(x>=0);
    validVector=@(x)isnumeric(x)&&isvector(x)&&(length(x)>1);
    validVectorPosNum=@(x)isnumeric(x)&&isvector(x)&&all(x>=0);


    addRequired(parseObj,"subcircuitFile",validstringorchar);
    addRequired(parseObj,"subcircuitName",validstringorchar);
    addParameter(parseObj,"SPICETool",netlistsObj.SPICETool,validstringorchar);
    addParameter(parseObj,"SPICEPath",defaultSPICEPath,validstringorchar);
    addParameter(parseObj,"outputPath",netlistsObj.netlistPath,validstringorchar);
    addParameter(parseObj,"terminals",netlistsObj.terminals,validVectorPosNum);
    addParameter(parseObj,"flagIdsVgs",netlistsObj.flagIdsVgs,validBoolean);
    addParameter(parseObj,"flagIdsVds",netlistsObj.flagIdsVds,validBoolean);
    addParameter(parseObj,"flagCapacitance",netlistsObj.flagCapacitance,validBoolean);
    addParameter(parseObj,"flagDiodeIV",netlistsObj.flagDiodeIV,validBoolean);
    addParameter(parseObj,"flagTailTransient",netlistsObj.flagTailTransient,validBoolean);
    addParameter(parseObj,"VgsRangeIdsVgs",netlistsObj.VgsRangeIdsVgs,validVector);
    addParameter(parseObj,"VdsStepsIdsVgs",netlistsObj.VdsStepsIdsVgs,validVector);
    addParameter(parseObj,"VdsRangeIdsVds",netlistsObj.VdsRangeIdsVds,validVector);
    addParameter(parseObj,"VgsStepsIdsVds",netlistsObj.VgsStepsIdsVds,validVector);
    addParameter(parseObj,"VgsCapacitance",netlistsObj.VgsCapacitance,validVector);
    addParameter(parseObj,"VdsCapacitance",netlistsObj.VdsCapacitance,validVector);
    addParameter(parseObj,"frequencyCapacitance",netlistsObj.frequencyCapacitance,validScalarPosNum);
    addParameter(parseObj,"acVoltageCapacitance",netlistsObj.acVoltageCapacitance,validScalarPosNum);
    addParameter(parseObj,"VdsDiodeIV",netlistsObj.VdsDiodeIV,validVector);
    addParameter(parseObj,"VceTail",netlistsObj.VceTail,validScalarPosNum);
    addParameter(parseObj,"pulseVgeTail",netlistsObj.pulseVgeTail,validScalarPosNum);
    addParameter(parseObj,"pulsePeriodTail",netlistsObj.pulsePeriodTail,validScalarPosNum);
    addParameter(parseObj,"T",netlistsObj.T,validVectorPosNum);
    addParameter(parseObj,"reltol",netlistsObj.reltol,validScalarPosNum);
    addParameter(parseObj,"abstol",netlistsObj.abstol,validScalarPosNum);
    addParameter(parseObj,"vntol",netlistsObj.vntol,validScalarPosNum);
    addParameter(parseObj,"gmin",netlistsObj.gmin,validScalarNonNegNum);
    addParameter(parseObj,"cshunt",netlistsObj.cshunt,validScalarPosNum);
    addParameter(parseObj,"IVsimulationTime",netlistsObj.IVsimulationTime,validScalarPosNum);
    addParameter(parseObj,"IVsimulationStepSize",netlistsObj.IVsimulationStepSize,validScalarPosNum);
    parse(parseObj,subcircuitFile,subcircuitName,varargin{:});


    if~(parseObj.Results.flagIdsVgs||parseObj.Results.flagIdsVds||...
        parseObj.Results.flagCapacitance||parseObj.Results.flagDiodeIV||...
        parseObj.Results.flagTailTransient)

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:AtLeastOneFlag');
    end

    if(parseObj.Results.flagIdsVgs)&&parseObj.Results.flagIdsVds

        pm_warning('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:BothEnabledUseIdsVds');
    end


    if isempty(parseObj.Results.outputPath)


        tempDir=tempname;
        mkdir(tempDir);
        dirname=convertCharsToStrings(tempDir);
        netlistsObj.netlistPath=dirname;
    else
        netlistsObj.netlistPath=parseObj.Results.outputPath;
    end


    netlistsObj.SPICETool=parseObj.Results.SPICETool;
    netlistsObj.terminals=parseObj.Results.terminals;
    netlistsObj.flagIdsVgs=parseObj.Results.flagIdsVgs;
    netlistsObj.flagIdsVds=parseObj.Results.flagIdsVds;
    netlistsObj.flagCapacitance=parseObj.Results.flagCapacitance;
    netlistsObj.flagDiodeIV=parseObj.Results.flagDiodeIV;
    netlistsObj.flagTailTransient=parseObj.Results.flagTailTransient;
    netlistsObj.VgsRangeIdsVgs=parseObj.Results.VgsRangeIdsVgs;
    netlistsObj.VdsStepsIdsVgs=parseObj.Results.VdsStepsIdsVgs;
    netlistsObj.VdsRangeIdsVds=parseObj.Results.VdsRangeIdsVds;
    netlistsObj.VgsStepsIdsVds=parseObj.Results.VgsStepsIdsVds;
    netlistsObj.VgsCapacitance=parseObj.Results.VgsCapacitance;
    netlistsObj.VdsCapacitance=parseObj.Results.VdsCapacitance;
    netlistsObj.frequencyCapacitance=parseObj.Results.frequencyCapacitance;
    netlistsObj.acVoltageCapacitance=parseObj.Results.acVoltageCapacitance;
    netlistsObj.VdsDiodeIV=parseObj.Results.VdsDiodeIV;
    netlistsObj.VceTail=parseObj.Results.VceTail;
    netlistsObj.pulseVgeTail=parseObj.Results.pulseVgeTail;
    netlistsObj.pulsePeriodTail=parseObj.Results.pulsePeriodTail;
    netlistsObj.T=parseObj.Results.T;
    netlistsObj.reltol=parseObj.Results.reltol;
    netlistsObj.abstol=parseObj.Results.abstol;
    netlistsObj.vntol=parseObj.Results.vntol;
    netlistsObj.gmin=parseObj.Results.gmin;
    netlistsObj.cshunt=parseObj.Results.cshunt;
    netlistsObj.IVsimulationTime=parseObj.Results.IVsimulationTime;
    netlistsObj.IVsimulationStepSize=parseObj.Results.IVsimulationStepSize;


    netlistsObj=netlistsObj.generateNetlists;


    fullPathNetlists=netlistsObj.netlists;


    netlistOut=ee.internal.spice.runSIMetrix(parseObj.Results.SPICEPath,fullPathNetlists);


    if netlistsObj.flagIdsVds
        [VgsVec,VdsVec,TVec,IdsMat]=ee.internal.spice.lookuptable.IdsVds(netlistOut,subcircuitName);
        lookuptable.channel=struct();
        lookuptable.channel.VgsVec=VgsVec;
        lookuptable.channel.VdsVec=VdsVec;
        lookuptable.channel.TVec=TVec;
        lookuptable.channel.IdsMat=IdsMat;
    elseif netlistsObj.flagIdsVgs

        [VgsVec,VdsVec,TVec,IdsMat]=ee.internal.spice.lookuptable.IdsVgs(netlistOut,subcircuitName);
        lookuptable.channel=struct();
        lookuptable.channel.VgsVec=VgsVec;
        lookuptable.channel.VdsVec=VdsVec;
        lookuptable.channel.TVec=TVec;
        lookuptable.channel.IdsMat=IdsMat;
    end


    if netlistsObj.flagCapacitance
        [VgsVec,VdsVec,CgsMat,CgdMat,CdsVec]=ee.internal.spice.lookuptable.capacitance(netlistOut,subcircuitName,netlistsObj.frequencyCapacitance);
        lookuptable.capacitance=struct();
        lookuptable.capacitance.VgsVec=VgsVec;
        lookuptable.capacitance.VdsVec=VdsVec;
        lookuptable.capacitance.CgsMat=CgsMat;
        lookuptable.capacitance.CgdMat=CgdMat;
        lookuptable.capacitance.CdsVec=CdsVec;
    end


    if netlistsObj.flagDiodeIV
        [VVec,TVec,IMat]=ee.internal.spice.lookuptable.diodeIV(netlistOut,subcircuitName);
        lookuptable.diode=struct();
        lookuptable.diode.VVec=VVec;
        lookuptable.diode.TVec=TVec;
        lookuptable.diode.IMat=IMat;
    end


    if netlistsObj.flagTailTransient
        TT=ee.internal.spice.lookuptable.currentTail(netlistOut,subcircuitName,netlistsObj.pulsePeriodTail);
        lookuptable.igbtTail.TT=TT;
    end


    if exist('dirname','var')
        if exist(dirname,"dir")
            rmdir(dirname,"s");
        end
    end

end