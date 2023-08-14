function blockInfo=getBlockInfo(this,hC)








    blockInfo=struct();

    if isa(hC,'hdlcoder.sysobj_comp')


        hSysObj=hC.getSysObjImpl;


        blockInfo.InterpolationFactor=hSysObj.InterpolationFactor;
        blockInfo.DecimationFactor=hSysObj.DecimationFactor;
        blockInfo.Numerator=hSysObj.Numerator;
        blockInfo.ReadyPort=hSysObj.ReadyPort;
        blockInfo.RequestPort=hSysObj.RequestPort;
        blockInfo.RoundingMethod=hSysObj.RoundingMethod;
        blockInfo.OverflowAction=hSysObj.OverflowAction;
        blockInfo.CoefficientsDataType=hSysObj.CoefficientsDataType;
        blockInfo.OutputDataType=hSysObj.OutputDataType;

    else


        hBlock=hC.SimulinkHandle;



        blockInfo.Mode=get_param(hBlock,'Mode');
        blockInfo.RateChange=this.hdlslResolve('RateChange',hBlock);
        blockInfo.Numerator=this.hdlslResolve('Numerator',hBlock);
        blockInfo.FilterStructure=get_param(hBlock,'FilterStructure');
        blockInfo.NumberOfCycles=this.hdlslResolve('NumberOfCycles',hBlock);
        blockInfo.ResetInputPort=strcmpi(get_param(hBlock,'ResetInputPort'),'on');
        blockInfo.HDLGlobalReset=get_param(hBlock,'HDLGlobalReset');
        blockInfo.RoundingMethod=get_param(hBlock,'RoundingMode');


        if strcmpi(get_param(hBlock,'OverflowMode'),'off')
            blockInfo.OverflowAction='Wrap';
        else
            blockInfo.OverflowAction='Saturate';
        end




        if strcmp(get_param(hBlock,'CoefficientsDataTypeStr'),'Inherit: Same word length as input')
            blockInfo.CoefficientsDataType='Same word length as input';
        else

            coeffsDTResolved=this.hdlslResolve('CoefficientsDataTypeStr',hBlock);
            if ischar(coeffsDTResolved)&&strcmp(coeffsDTResolved,'Inherit: Same word length as input')
                blockInfo.CoefficientsDataType='Same word length as input';
            else
                blockInfo.CoefficientsDataType=numerictype(coeffsDTResolved);
            end
        end

        fractionaldelayFixdt=this.hdlslResolve('FractionalDelayDataTypeStr',hBlock);
        blockInfo.FractionalDelayDataType=numerictype2pirtype(numerictype(fractionaldelayFixdt));


        switch get_param(hBlock,'OutputDataTypeStr')
        case 'Inherit: Inherit via internal rule'
            blockInfo.OutputDataType='Full precision';
        case 'Inherit: Same as first input'
            blockInfo.OutputDataType='Same word length as input';
        otherwise
            outputFixdt=this.hdlslResolve('OutputDataTypeStr',hBlock);
            blockInfo.OutputDataType=numerictype2pirtype(numerictype(outputFixdt));
        end


        switch get_param(hBlock,'MultiplicandDataTypeStr')
        case 'Inherit: Inherit via internal rule'
            blockInfo.MultiplicandDataType=blockInfo.FractionalDelayDataType;
        otherwise
            outputFixdt=this.hdlslResolve('OutputDataTypeStr',hBlock);
            blockInfo.OutputDataType=numerictype2pirtype(numerictype(outputFixdt));
        end




    end

    inputDT=hC.PirInputSignals(1).Type.BaseType;
    inputNT=fi(0,inputDT.Signed,inputDT.WordLength,inputDT.FractionLength*-1);
    inputWL=hC.PirInputSignals(1).Type.BaseType.BaseType.WordLength;


    if isnumerictype(blockInfo.CoefficientsDataType)
        coeffsNumerictype=blockInfo.CoefficientsDataType;
    else
        coeffsNumerictype=numerictype([],inputWL);
    end

    blockInfo.NumeratorQuantized=fi(blockInfo.Numerator,coeffsNumerictype);
    blockInfo.FilterOrder=length(blockInfo.Numerator);

    pFilterArray=cell(length(blockInfo.Numerator),1);
    oldWord=0;oldFraction=0;
    for ii=1:1:length(blockInfo.Numerator)

        pFilterArray{ii}=dsp.HDLFIRFilter('Numerator',blockInfo.Numerator(:,ii)',...
        'FilterStructure',blockInfo.FilterStructure,...
        'RoundingMethod',blockInfo.RoundingMethod,...
        'OverflowAction',blockInfo.OverflowAction,...
        'CoefficientsDataType',blockInfo.CoefficientsDataType,...
        'OutputDataType','Full precision');


        setup(pFilterArray{ii},cast(0,'like',inputNT),true);
        [firOutput{ii},~]=output(pFilterArray{ii},cast(0,'like',inputNT),true);


    end

    for jj=1:1:blockInfo.FilterOrder
        word=firOutput{jj}.WordLength;
        fraction=firOutput{jj}.FractionLength;
        if word>oldWord
            oldWord=word;
        end
        if fraction>oldFraction
            oldFraction=fraction;
        end
        FIRFilterType{jj}=firOutput{jj};

        blockInfo.FIRFilterType{jj}=numerictype2pirtype(FIRFilterType{jj});
    end


    FIROutputype=numerictype(inputNT.Signed,oldWord,oldFraction);
    blockInfo.FIROutputype=numerictype2pirtype(FIROutputype);

    blockInfo.inMode=[true;...
    strcmpi(get_param(hBlock,'ResetInputPort'),'on')];


    blockInfo.XILINX_MAXOUTPUT_WORDLENGTH=48;
    blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH=44;
    blockInfo.CompiledInputSize=getVecSize(hC.PirInputSignal(1));
end






function pirt=numerictype2pirtype(nt)

    pirt=pir_fixpt_t(nt.SignednessBool,nt.WordLength,-nt.FractionLength);
end


function vecSize=getVecSize(dataIn)
    dInType=pirgetdatatypeinfo(dataIn.Type);
    vecSize=dInType.dims;
end





