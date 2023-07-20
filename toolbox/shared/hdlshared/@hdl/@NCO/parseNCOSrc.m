function parseNCOSrc(this,srcobj)





    switch class(srcobj)
    case 'dsp.NCO'
        block_name='NCO_SystemObject';
        PhaseIncrementSource=srcobj.PhaseIncrementSource;
        PhaseOffsetSource=srcobj.PhaseOffsetSource;
        if~strcmpi(PhaseIncrementSource,'Input port')


            accinc=srcobj.PhaseIncrement;
        else
            accinc=[];
        end

        Dither=srcobj.Dither;
        poffset_val=srcobj.PhaseOffset;
        PhaseQuantization=srcobj.PhaseQuantization;
        quantWL=srcobj.NumQuantizerAccumulatorBits;
        PhaseQuantizationErrorOutputPort=srcobj.PhaseQuantizationErrorOutputPort;
        trig_func=srcobj.Waveform;
        accum_sltype=getAccumInfofromSysObj(srcobj);
        output_sltype=getOutputInfofromSysObj(srcobj);
        inputsigs=[];
        outputs=[];
        clk=hdlgetcurrentclock;
        clken=hdlgetcurrentclockenable;
        reset=hdlgetcurrentreset;
        if srcobj.PNGeneratorLength~=19


            error(message('HDLShared:directemit:InvalidPNGeneratorLength'));
        else
            Generator_Polynomial=[19,18,17,14,0];
            polybitpattern=dec2bin(sum(2.^(Generator_Polynomial)));
        end



        tpvalues={'Dither',Dither};
        if Dither
            DitherBits=srcobj.NumDitherBits;
            tpvalues=[tpvalues,{'NumDitherBits',DitherBits}];
        end
        this.init(tpvalues{:});
    case 'hdlcoder.black_box_comp'
        bfp=srcobj.SimulinkHandle;
        rto=get_param(bfp,'RuntimeObject');

        for ii=1:rto.NumRuntimePrms,
            rto_names{ii}=rto.RuntimePrm(ii).Name;%#ok<AGROW>
        end

        block_name=hdllegalname(get_param(bfp,'Name'));


        inputs=srcobj.SLInputPorts;
        outputports=srcobj.SLOutputPorts;
        outputsigs=[];
        for osigs=1:length(outputports)
            outputsigs=[outputsigs,outputports(osigs).Signal];%#ok<AGROW>
        end
        outputs=outputsigs;

        [clk,clken,reset]=hdlgetclockbundle(srcobj.Owner,srcobj,outputs(1),1,1,0);


        insig_idx=1;

        mwsvar=get_param(bfp,'MaskWSVariables');









        PhaseIncrementSource=get_param(bfp,'AccIncSrc');
        if~strcmpi(PhaseIncrementSource,'Input port')


            accinc_rtoidx=strmatch('INC',rto_names,'exact');
            accinc=rto.RuntimePrm(accinc_rtoidx).Data;
            inc_insig=[];
        else
            accinc=[];
            inc_insig=inputs(insig_idx).Signal;
            insig_idx=insig_idx+1;
        end


        PhaseOffsetSource=get_param(bfp,'PhaseOffsetSrc');

        if~strcmpi(PhaseOffsetSource,'Input port')

            poffset_val_rtoidx=strmatch('OFFSET',rto_names,'exact');
            poffset_val=rto.RuntimePrm(poffset_val_rtoidx).Data;
            poffset_insig=[];
        else
            poffset_val=[];
            poffset_insig=inputs(insig_idx).Signal;

        end

        inputsigs=[inc_insig,poffset_insig];


        HasDither_wsvaridx=strmatch('HasDither',{mwsvar.Name},'exact');
        Dither=mwsvar(HasDither_wsvaridx).Value==1;
        if Dither

            pnpoly_rtoidx=strmatch('PolyBitPattern',rto_names,'exact');
            polybitpattern=dec2bin(rto.RuntimePrm(pnpoly_rtoidx).Data);

        else
            polybitpattern=[];
        end

        DitherBits=hdlslResolve('DitherWL',bfp);


        HasPhaseQ_wsvaridx=strmatch('HasPhaseQuantizer',{mwsvar.Name},'exact');
        PhaseQuantization=(mwsvar(HasPhaseQ_wsvaridx).Value==1);


        HasOutputPhaseError_wsvaridx=strmatch('HasOutputPhaseError',{mwsvar.Name},'exact');
        PhaseQuantizationErrorOutputPort=(mwsvar(HasOutputPhaseError_wsvaridx).Value==1);



        trig_func=get_param(bfp,'Formula');


        quantWL=hdlslResolve('TableDepth',bfp);


        outputWL=hdlslResolve('OutputWL',bfp);
        outputFL=hdlslResolve('OutputFL',bfp);
        output_sltype=hdlgetsltypefromsizes(outputWL,outputFL,1);


        accumWL=hdlslResolve('AccumWL',bfp);
        accum_sltype=hdlgetsltypefromsizes(accumWL,0,1);

        tpvalues={'Dither',Dither,'NumDitherBits',DitherBits};
        this.init(tpvalues{:});
    otherwise
        error(message('HDLShared:directemit:InvalidNCOSource'));
    end

    pvvalues={'Description','Numerically Controlled Oscillator',...
    'processName',block_name,...
    'PhaseIncrementSource',PhaseIncrementSource,...
    'PhaseIncrement',accinc,...
    'PhaseOffsetSource',PhaseOffsetSource,...
    'PhaseOffset',poffset_val,...
    'PhaseQuantization',PhaseQuantization,...
    'NumQuantizerAccumulatorBits',quantWL,...
    'PhaseQuantizationErrorOutputPort',PhaseQuantizationErrorOutputPort...
    ,'Waveform',trig_func,...
    'SamplesPerFrame',1,...
    'RoundMode','Floor',...
    'OverflowMode','Wrap',...
    'AccumulatorSLType',accum_sltype,...
    'OutputSLType',output_sltype,...
    'inputs',inputsigs,...
    'outputs',outputs,...
    'clock',clk,...
    'clockenable',clken,...
    'reset',reset,...
    'PolyBitPattern',polybitpattern};

    this.init(pvvalues{:});


    function asltype=getAccumInfofromSysObj(hS)

        asize=0;
        abp=0;
        if strcmpi(hS.AccumulatorDataType,'Custom')
            antype=hS.CustomAccumulatorDataType;
            [asize,abp]=hdlfilter.getSizesfromNumericType(antype);


        end
        asltype=hdlgetsltypefromsizes(asize,abp,1);

        function osltype=getOutputInfofromSysObj(hS)


            osize=0;
            obp=0;
            if strcmpi(hS.OutputDataType,'Custom')
                ontype=hS.CustomOutputDataType;
                [osize,obp]=hdlfilter.getSizesfromNumericType(ontype);


            end
            osltype=hdlgetsltypefromsizes(osize,obp,1);

