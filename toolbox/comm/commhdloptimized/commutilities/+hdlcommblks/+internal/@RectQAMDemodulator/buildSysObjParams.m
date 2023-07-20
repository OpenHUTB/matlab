function prm=buildSysObjParams(this,hC,hN,sysObjHandle)%#ok<INUSL>





    prm=struct;
    s=sysObjHandle.getAdaptorRunTimeData();
    RTPs=s.RTPs;

    prm.hC=hC;
    prm.hN=hN;


    rtop=struct;


    prm.isCosInitPhase=false;
    RTPFields=fields(RTPs);
    for ii=1:numel(RTPFields)
        rtop.(RTPFields{ii})=RTPs.(RTPFields{ii});
        if strcmpi(RTPFields{ii},'cosInitPhase')
            prm.isCosInitPhase=true;
        end
    end


    prm.M=sysObjHandle.ModulationOrder;
    prm.Phase=mod(sysObjHandle.PhaseOffset,2*pi);


    switch lower(sysObjHandle.SymbolMapping)
    case 'binary'
        prm.mapping=[];
    case 'gray'
        [~,prm.mapping]=comm.internal.utilities.bin2gray(0:(prm.M-1),'qam',prm.M);
    case 'custom'
        prm.mapping=rtop.mapping;
    end


    try
        prm.sqrtMminus1=rtop.sqrtMminus1;
        prm.twoSqrtMminus1=rtop.twoSqrtMminus1;
        prm.oneSumType=rtop.oneSumType;
    catch me %#ok<NASGU>

    end



    if(sysObjHandle.BitOutput)
        prm.isHardDec=strcmpi(sysObjHandle.DecisionMethod,'Hard decision');
    else
        prm.isHardDec=true;
    end

    prm.isNormMethodMinDist=strcmpi(sysObjHandle.NormalizationMethod,...
    'Minimum distance between symbols');

    prm.minDist=sysObjHandle.MinimumDistance;
