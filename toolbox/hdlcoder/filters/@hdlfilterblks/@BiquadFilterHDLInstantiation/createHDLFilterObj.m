function hf=createHDLFilterObj(this,hC)






    isSysObj=isa(hC,'hdlcoder.sysobj_comp');





    inSignals=hC.getInputSignals('data');
    inType=inSignals(1).Type.BaseType;


    if inType.isDoubleType()
        options.arithmetic='double';
        options.inputformat=[0,0];
        options.fixedMode=false;
    elseif inType.isSingleType()&&targetcodegen.targetCodeGenerationUtils.isNFPMode()
        error(message('hdlcommon:nativefloatingpoint:Nfp_unsupported_block',hC.getBlockPath()));
    else
        options.arithmetic='fixed';
        options.inputformat=[inType.WordLength,-inType.FractionLength];
        options.fixedMode=true;
    end





    if isSysObj
        inComplex=hdlsignaliscomplex(inSignals(1));
        inst=hC.getSysObjImpl;
    else
        bfp=hC.SimulinkHandle;
        inst=get_param(bfp,'Object');
        inComplexSig=inst.CompiledPortComplexSignals.Inport;
        inComplex=inComplexSig(1);
    end





    if~isSysObj

        if~isa(inst,'Simulink.SFunction')
            error(message('hdlcoder:validate:InvalidBlockInput'));
        end

        switch inst.FilterSource
        case 'Filter object'

            hf=getHDLFiltObjFromBlockFiltObj(this,inst,hC,options);
        otherwise

            hf=getHDLFiltObjFromBlock(this,inst,hC,options);
        end
    else

        hd=clone(inst);
        hf=getHDLFiltObjFromSysObj(this,inst,hC,hd,options);
    end

    hf.InputComplex=inComplex;
    hf.numChannel=inSignals(1).Type.getDimensions;
    hf.coeffPort=length(inSignals)>1;



    if isSysObj
        if hf.coeffPort
            hf.scalePort=inst.ScaleValuesInputPort;
        end
    else
        hf.scalePort=strcmpi(inst.ScaleValueMode,'Specify via input port (g)');
    end

end



function hf=getHDLFiltObjFromBlock(this,inst,hC,options)






    hf=whichhdlfilter(this,inst);


    if options.fixedMode
        bfp=hC.SimulinkHandle;
        hf.RoundMode=translateRoundingMethod(get_param(bfp,'roundingMode'));
        hf.OverflowMode=translateOverflowAction(get_param(bfp,'overflowMode'));
    else
        hf.RoundMode='floor';
        hf.OverflowMode=false;
    end


    hf=updateFixedPointInfo(this,hf,hC,options.arithmetic,options.inputformat);

end



function hf=getHDLFiltObjFromBlockFiltObj(this,inst,hC,options)


    filtObjName=inst.FilterObject;
    if~isempty(filtObjName)
        ud=inst.UserData;
        if isfield(ud,'filter')
            if isa(ud.filter,'dsp.BiquadFilter')
                hd=clone(ud.filter);
            else
                hd=copy(ud.filter);
            end
        else
            error(message('hdlcoder:validate:undefinedDFILT',filtObjName));
        end
    else
        error(message('hdlcoder:validate:emptyDFILT'));
    end

    if~isa(ud.filter,'dsp.BiquadFilter')

        hf=createhdlfilter(hd);
    else

        hf=getHDLFiltObjFromSysObj(this,inst,hC,hd,options);
    end

end



function hf=getHDLFiltObjFromSysObj(this,inst,hC,hd,options)






    hf=whichhdlfilter(this,inst);


    if options.fixedMode

        hf.RoundMode=translateRoundingMethod(hd.RoundingMethod);
        hf.OverflowMode=translateOverflowAction(hd.OverflowAction);
    else
        hf.RoundMode='floor';
        hf.OverflowMode=false;
    end


    hf=updateFixedPointInfo(this,hf,hC,options.arithmetic,options.inputformat);

end



function hdlRoundMode=translateRoundingMethod(slRoundMode)

    switch lower(slRoundMode)
    case 'ceiling';hdlRoundMode='ceil';
    case 'convergent';hdlRoundMode='convergent';
    case 'floor';hdlRoundMode='floor';
    case 'nearest';hdlRoundMode='nearest';
    case 'round';hdlRoundMode='round';
    case 'simplest';hdlRoundMode='floor';
    otherwise;hdlRoundMode='fix';
    end
end



function hdlOverflowMode=translateOverflowAction(slOverflowAction)

    if(strncmpi(slOverflowAction,'off',3)||strncmpi(slOverflowAction,'wrap',4))
        hdlOverflowMode=false;
    else
        hdlOverflowMode=true;
    end
end



function hf=updateFixedPointInfo(this,hf,hC,arith,inputformat)




    [~,hf.inputsltype]=hdlgettypesfromsizes(inputformat(1),inputformat(2),true);


    hf=updateCoeffInfo(this,hf,hC,arith);
    hf=updateProdInfo(this,hf,hC,arith);
    hf=updateAccumInfo(this,hf,hC,arith);
    hf=updateSectionInfo(this,hf,hC,arith);
    hf=updateStateInfo(this,hf,hC,arith);
    hf=updateMultiplicandInfo(this,hf,hC,arith);
    hf=updateOutputInfo(this,hf,hC,arith);

end
