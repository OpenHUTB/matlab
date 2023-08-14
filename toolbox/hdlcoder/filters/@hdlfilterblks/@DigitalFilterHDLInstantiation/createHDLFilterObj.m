function hF=createHDLFilterObj(this,hC)









    inSignals=hC.getInputSignals('data');
    inType=inSignals(1).Type.getLeafType;
    if inType.isFloatType
        if inType.isDoubleType
            arithmetic='double';
        else
            arithmetic='single';
        end
        [inputWL,inputFL,inputsgn]=deal(0,0,0);
    else
        arithmetic='fixed';
        inputWL=inType.WordLength;
        inputFL=-inType.FractionLength;
        inputsgn=inType.Signed;
    end

    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if isSysObj
        filterFromFilterObject=false;
        inComplex=hdlsignaliscomplex(inSignals(1));
        sysObjHandle=hC.getSysObjImpl;
    else
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        filterFromFilterObject=...
        ~any(strcmp(block.FilterSource,{'Specify via dialog','Input port(s)'}));
        inComplexSig=block.CompiledPortComplexSignals.Inport;
        inComplex=inComplexSig(1);
    end

    if~filterFromFilterObject

        hF=this.dfiltblktohdlfilterobj(hC,'arithmetic',arithmetic,'inputformat',[inputWL,inputFL,inputsgn]);
    else


        filterobj=dfiltblktoobj(bfp,'arithmetic',arithmetic,'inputformat',[inputWL,inputFL]);

        hF=createhdlfilter(filterobj);






        if isa(filterobj,'dfilt.dfsymfir')||isa(filterobj,'dfilt.dfasymfir')
            hF.tapsumsltype=hF.inputsltype;
        end
    end

    hF.InputComplex=inComplex;
    hF.numChannel=inSignals(1).Type.getDimensions;
    hF.coeffPort=length(inSignals)>1;


    if hF.coeffPort&&isSysObj&&...
        isa(sysObjHandle,'dsp.BiquadFilter')
        hF.scalePort=sysObjHandle.ScaleValuesInputPort;
    end


