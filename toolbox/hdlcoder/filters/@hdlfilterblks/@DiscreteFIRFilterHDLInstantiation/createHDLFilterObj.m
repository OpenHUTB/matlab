function hF=createHDLFilterObj(this,hC)







    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if isSysObj
        sysObjHandle=hC.getSysObjImpl;

        inputWL=hC.PIRInputSignals(1).Type.getLeafType.WordLength;
        inputsgn=hC.PIRInputSignals(1).Type.getLeafType.Signed;
        inputFL=-1*hC.PIRInputSignals(1).Type.getLeafType.FractionLength;
    else

        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');

        cpdt=get_param(bfp,'CompiledPortDataTypes');
        in_sltype=char(cpdt.Inport(1));
        [inputWL,inputFL,inputsgn]=hdlgetsizesfromtype(in_sltype);
    end



    if hC.PIRInputSignals(1).Type.getLeafType.isDoubleType
        arithmetic='double';
    elseif hC.PIRInputSignals(1).Type.getLeafType.isSingleType
        arithmetic='single';
    else
        arithmetic='fixed';
    end


    hF=this.dfiltblktohdlfilterobj(hC,'arithmetic',arithmetic,'inputformat',[inputWL,inputFL,inputsgn]);


    inSignals=hC.getInputSignals('data');
    for ii=1:numel(inSignals)
        inComplex(ii)=hdlsignaliscomplex(inSignals(ii));%#ok<AGROW>
    end
...
...
...
...

    hF.InputComplex=inComplex;
    hF.numChannel=inSignals(1).Type.getDimensions;
    if isSysObj
        hF.coeffPort=strcmp(sysObjHandle.NumeratorSource,'Input port');
    else
        hF.coeffPort=strcmp(block.CoefSource,'Input port');
    end

