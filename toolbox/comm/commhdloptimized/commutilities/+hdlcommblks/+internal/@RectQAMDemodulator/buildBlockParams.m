function prm=buildBlockParams(this,hC,hN)





    prm=struct;

    bfp=hC.SimulinkHandle;
    rto=get_param(bfp,'RunTimeObject');

    prm.hC=hC;
    prm.hN=hN;


    rtop=struct;


    prm.isCosInitPhase=false;
    for ii=1:(rto.NumRuntimePrms)
        if~isempty(rto.RuntimePrm(ii))
            rtop.(rto.RuntimePrm(ii).Name)=rto.RuntimePrm(ii).Data;
        end
        if strcmpi(rto.RuntimePrm(ii).Name,'cosInitPhase')
            prm.isCosInitPhase=true;
        end
    end


    prm.M=this.hdlslResolve('M',bfp);
    prm.Phase=mod(this.hdlslResolve('Ph',bfp),2*pi);


    switch lower(get_param(bfp,'Dec'))
    case 'binary'
        prm.mapping=[];
    case 'gray'
        [~,prm.mapping]=comm.internal.utilities.bin2gray([0:(prm.M-1)],'qam',prm.M);
    case 'user-defined'
        prm.mapping=rtop.mapping;
    end


    try
        prm.sqrtMminus1=rtop.sqrtMminus1;
        prm.twoSqrtMminus1=rtop.twoSqrtMminus1;
        prm.oneSumType=rtop.oneSumType;
    catch me %#ok<NASGU>

    end



    prm.isHardDec=strcmpi(get_param(bfp,'DecType'),'Hard decision');

    prm.isNormMethodMinDist=strcmpi(get_param(bfp,'PowType'),'Min. distance between symbols');

    prm.minDist=this.hdlslResolve('MinDist',bfp);
