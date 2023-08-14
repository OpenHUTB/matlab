function blockInfo=getBlockInfo(this,hC)







    blockInfo=struct();

    hBlock=hC.SimulinkHandle;
    rto=get_param(hBlock,'RuntimeObject');

    for ii=1:rto.NumRuntimePrms
        rto_names{ii}=rto.RuntimePrm(ii).Name;%#ok<AGROW>
    end


    blockInfo.inMode=[strcmpi(get_param(hBlock,'AccIncSrc'),'Input port');
    strcmpi(get_param(hBlock,'PhaseOffsetSrc'),'Input port')];


    wform=lower(get_param(hBlock,'Formula'));

    blockInfo.outMode=[strcmp(wform,'sine')||strcmp(wform,'sine and cosine');
    strcmp(wform,'cosine')||strcmp(wform,'sine and cosine');
    strcmp(wform,'complex exponential');
    strcmpi(get_param(hBlock,'HasOutputPhaseError'),'on')];


    mwsvar=get_param(hBlock,'MaskWSVariables');


    blockInfo.phaseIncrementSrc=get_param(hBlock,'AccIncSrc');
    if~strcmpi(blockInfo.phaseIncrementSrc,'Input port')


        accinc_rtoidx=find(strcmp('INC',rto_names));
        blockInfo.accinc=rto.RuntimePrm(accinc_rtoidx).Data;%#ok<FNDSB>
    else
        blockInfo.accinc=[];
    end

    blockInfo.PhaseOffsetSource=get_param(hBlock,'PhaseOffsetSrc');

    if~strcmpi(blockInfo.PhaseOffsetSource,'Input port')

        poffset_val_rtoidx=find(strcmp('OFFSET',rto_names));
        blockInfo.phaseOffset=rto.RuntimePrm(poffset_val_rtoidx).Data;
    else
        blockInfo.phaseOffset=[];

    end



    HasDither_wsvaridx=find(strcmp('HasDither',{mwsvar.Name}));
    blockInfo.Dither=mwsvar(HasDither_wsvaridx).Value==1;
    if blockInfo.Dither

        pnpoly_rtoidx=find(strcmp('PolyBitPattern',rto_names));
        blockInfo.polybitpattern=dec2bin(rto.RuntimePrm(pnpoly_rtoidx).Data);

    else
        blockInfo.polybitpattern=[];
    end

    blockInfo.DitherBits=this.hdlslResolve('DitherWL',hBlock);


    HasPhaseQ_wsvaridx=find(strcmp('HasPhaseQuantizer',{mwsvar.Name}));
    blockInfo.PhaseQuantization=(mwsvar(HasPhaseQ_wsvaridx).Value==1);


    HasOutputPhaseError_wsvaridx=find(strcmp('HasOutputPhaseError',{mwsvar.Name}));
    blockInfo.PhaseQuantizationErrorOutputPort=(mwsvar(HasOutputPhaseError_wsvaridx).Value==1);



    blockInfo.trig_func=get_param(hBlock,'Formula');


    blockInfo.quantWL=this.hdlslResolve('TableDepth',hBlock);


    blockInfo.outWL=this.hdlslResolve('OutputWL',hBlock);
    blockInfo.outFL=this.hdlslResolve('OutputFL',hBlock);
    blockInfo.output_sltype=hdlgetsltypefromsizes(blockInfo.outWL,blockInfo.outFL,1);


    accumWL=this.hdlslResolve('AccumWL',hBlock);
    blockInfo.accumDType=pir_sfixpt_t(accumWL,0);

    blockInfo.SimulinkRate=hC.PirOutputSignals(1).SimulinkRate;


