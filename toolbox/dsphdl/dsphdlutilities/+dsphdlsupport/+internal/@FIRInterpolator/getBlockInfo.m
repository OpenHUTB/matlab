function blockInfo=getBlockInfo(this,hC)






    blockInfo.XILINX_MAXOUTPUT_WORDLENGTH=48;
    blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH=44;
    blockInfo.DELAYLINELIMIT2MAP2RAM=64;
    if isa(hC,'hdlcoder.sysobj_comp')
        hSysObj=hC.getSysObjImpl;
        blockInfo.NumCycles=hSysObj.NumCycles;
        FilterStructure=hSysObj.FilterStructure;
        Numerator=hSysObj.Numerator;
        blockInfo.InterpolationFactor=hSysObj.InterpolationFactor;


        if blockInfo.NumCycles>1&&strcmpi(FilterStructure,'Direct form systolic')
            blockInfo.FilterStructure='Partly serial systolic';

            if blockInfo.NumCycles>1&&strcmpi(FilterStructure,'Direct form systolic')
                blockInfo.FilterStructure='Partly serial systolic';

                if isinf(blockInfo.NumCycles)
                    blockInfo.NumCycles=ceil((numel(Numerator)/blockInfo.InterpolationFactor))*blockInfo.InterpolationFactor;

                end
            else
                blockInfo.FilterStructure=FilterStructure;
                blockInfo.NumCycles=1;
            end

        else
            blockInfo.FilterStructure=FilterStructure;
            blockInfo.NumCycles=1;
        end

        blockInfo.Numerator=reshapeFilterCoef(this,Numerator,blockInfo.InterpolationFactor);
        blockInfo.RoundingMethod=hSysObj.RoundingMethod;
        blockInfo.OverflowAction=hSysObj.OverflowAction;
        blockInfo.CoefficientsDataType=hSysObj.CoefficientsDataType;
        blockInfo.OutputDataType=hSysObj.OutputDataType;
        blockInfo.CompiledInputDT=resolveDT(hC,'SysObj');
        blockInfo.inMode=[true;...
        hSysObj.ResetInputPort];
        blockInfo.HDLGlobalReset=hSysObj.HDLGlobalReset;
        blockInfo.ResetInputPort=hSysObj.ResetInputPort;
        blockInfo.InterpolationMode=true;
        blockInfo.CoefficientsDataType=hSysObj.CoefficientsDataType;
        blockInfo.OutputDataType=hSysObj.OutputDataType;

        inputWL=hC.PirInputSignals(1).Type.BaseType.BaseType.WordLength;


        if isnumerictype(blockInfo.CoefficientsDataType)
            coeffsNumerictype=blockInfo.CoefficientsDataType;
        else
            coeffsNumerictype=numerictype([],inputWL);
        end

        blockInfo.NumeratorQuantized=fi(Numerator,coeffsNumerictype,'OverflowAction','Saturate','RoundingMethod','Nearest');





    else

        hBlock=hC.Simulinkhandle;
        blockInfo.NumCycles=this.hdlslResolve('NumCycles',hBlock);

        FilterStructure=get_param(hBlock,'FilterStructure');
        Numerator=this.hdlslResolve('Numerator',hBlock);
        blockInfo.InterpolationFactor=this.hdlslResolve('InterpolationFactor',hBlock);


        if blockInfo.NumCycles>1&&strcmpi(FilterStructure,'Direct form systolic')
            blockInfo.FilterStructure='Partly serial systolic';

            if isinf(blockInfo.NumCycles)
                blockInfo.NumCycles=ceil((numel(Numerator)/blockInfo.InterpolationFactor))*blockInfo.InterpolationFactor;

            end
        else
            blockInfo.FilterStructure=FilterStructure;
            blockInfo.NumCycles=1;
        end


        blockInfo.Numerator=reshapeFilterCoef(this,Numerator,blockInfo.InterpolationFactor);

        blockInfo.inMode=[true;...
        strcmpi(get_param(hBlock,'ResetInputPort'),'on')];
        blockInfo.HDLGlobalReset=strcmpi(get_param(hBlock,'HDLGlobalReset'),'on');
        blockInfo.ResetInputPort=strcmpi(get_param(hBlock,'ResetInputPort'),'on');

        blockInfo.RoundingMethod=get_param(hBlock,'roundingMode');
        blockInfo.OverflowAction=resolveOverFlow(get_param(hBlock,'OverflowMode'));
        blockInfo.CompiledPortDT=get_param(hBlock,'CompiledPortDataTypes');
        blockInfo.CompiledInputDT=resolveDT(blockInfo.CompiledPortDT.Inport{1},'block');
        blockInfo.CompiledOutputDT=resolveDT(blockInfo.CompiledPortDT.Outport{1},'block');
        blockInfo.InterpolationMode=true;

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
        switch get_param(hBlock,'OutputDataTypeStr')
        case 'Inherit: Inherit via internal rule'
            blockInfo.OutputDataType='Full precision';
        case 'Inherit: Same word length as input'
            blockInfo.OutputDataType=blockInfo.CompiledOutputDT;
        otherwise

            outputDTResolved=this.hdlslResolve('OutputDataTypeStr',hBlock);
            if ischar(outputDTResolved)&&strcmp(outputDTResolved,'Inherit: Inherit via internal rule')
                blockInfo.OutputDataType='Full precision';
            elseif ischar(outputDTResolved)&&strcmp(outputDTResolved,'Inherit: Same word length as input')
                blockInfo.OutputDataType='Same word length as input';
            else
                blockInfo.OutputDataType=numerictype(outputDTResolved);
            end
        end
        inputWL=hC.PirInputSignals(1).Type.BaseType.BaseType.WordLength;


        if isnumerictype(blockInfo.CoefficientsDataType)
            coeffsNumerictype=blockInfo.CoefficientsDataType;
        else
            if any(Numerator(:)<0)
                coeffsNumerictype=numerictype(fi(Numerator,1,inputWL));
            else
                coeffsNumerictype=numerictype(fi(Numerator,0,inputWL));
            end
        end

        blockInfo.NumeratorQuantized=fi(Numerator,coeffsNumerictype,'OverflowAction','Saturate','RoundingMethod','Nearest');

    end

    blockInfo.SymmetryOptimization=false;
    numMults=ceil(numel(blockInfo.Numerator)/blockInfo.NumCycles);
    numMuxInputs=ceil((numel(blockInfo.Numerator)/blockInfo.InterpolationFactor)/numMults);
    subLength=size(blockInfo.Numerator,2);
    blockInfo.pSubLength=subLength;
    tableSubSize=ceil(subLength/numMults);
    blockInfo.Interleaving=(blockInfo.NumCycles>blockInfo.InterpolationFactor)&&(numMults<blockInfo.InterpolationFactor)&&tableSubSize>=2;
    blockInfo.NumeratorQuantized=fi(blockInfo.Numerator,coeffsNumerictype,'OverflowAction','Saturate','RoundingMethod','Nearest');
    blockInfo.FilterOrder=blockInfo.InterpolationFactor;

    pFilterArray=cell(blockInfo.InterpolationFactor,1);
    oldMSB=0;oldFraction=0;


    typeInfo=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    InputVectorSize=typeInfo.dims;
    IsFilterComplex=logical(typeInfo.iscomplex);
    blockInfo.InputVectorSize=InputVectorSize;

    if isfield(struct(hC.PirInputSignals(1).Type),'Dimensions')
        inputDT=hC.PirInputSignals(1).Type.BaseType.BaseType;
        inputNT=fi(0,inputDT.Signed,inputDT.WordLength,inputDT.FractionLength*-1);

    else
        inputDT=hC.PirInputSignals(1).Type.BaseType;
        inputNT=fi(0,inputDT.Signed,inputDT.WordLength,inputDT.FractionLength*-1);
    end

    for ii=1:1:blockInfo.InterpolationFactor
        if blockInfo.NumCycles>1
            pFilterArray{ii}=dsphdl.FIRFilter('Numerator',blockInfo.Numerator(ii,:),...
            'FilterStructure','Partly serial systolic',...
            'NumCycles',blockInfo.NumCycles,...
            'RoundingMethod',blockInfo.RoundingMethod,...
            'OverflowAction',blockInfo.OverflowAction,...
            'CoefficientsDataType',blockInfo.CoefficientsDataType,...
            'ResetInputPort',blockInfo.ResetInputPort,...
            'HDLGlobalReset',blockInfo.HDLGlobalReset,...
            'OutputDataType',blockInfo.OutputDataType);

            pFilterArray{ii}.setCoeffDTCheck(false);
            if blockInfo.Interleaving
                pFilterArray{ii}.SymmetryOptimization=false;
            end

        else
            pFilterArray{ii}=dsphdl.FIRFilter('Numerator',blockInfo.Numerator(ii,:),...
            'FilterStructure',blockInfo.FilterStructure,...
            'RoundingMethod',blockInfo.RoundingMethod,...
            'OverflowAction',blockInfo.OverflowAction,...
            'CoefficientsDataType',blockInfo.CoefficientsDataType,...
            'ResetInputPort',blockInfo.ResetInputPort,...
            'HDLGlobalReset',blockInfo.HDLGlobalReset,...
            'OutputDataType',blockInfo.OutputDataType);

            pFilterArray{ii}.setCoeffDTCheck(false);

        end

        if blockInfo.ResetInputPort
            setup(pFilterArray{ii},cast(zeros(blockInfo.InputVectorSize,1),'like',inputNT),true,false);
        else
            setup(pFilterArray{ii},cast(zeros(blockInfo.InputVectorSize,1),'like',inputNT),true);
        end
    end

    firOutput=cell(size(blockInfo.Numerator,1),1);
    for ii=1:1:size(blockInfo.Numerator,1)
        if isa((hC.PirInputSignals(1).Type),'hdlcoder.tp_complex')||~isreal(blockInfo.Numerator)
            if blockInfo.ResetInputPort
                [out,~]=output(pFilterArray{ii},cast(complex(zeros(blockInfo.InputVectorSize,1)),'like',inputNT),true,false);
            else
                [out,~]=output(pFilterArray{ii},cast(complex(zeros(blockInfo.InputVectorSize,1)),'like',inputNT),true);
            end
            firOutput{ii}=out;
        else
            if blockInfo.ResetInputPort
                [out,~]=output(pFilterArray{ii},cast(zeros(blockInfo.InputVectorSize,1),'like',inputNT),true,false);
            else
                [out,~]=output(pFilterArray{ii},cast(zeros(blockInfo.InputVectorSize,1),'like',inputNT),true);
            end
            firOutput{ii}=out;
        end
    end


    for jj=1:1:blockInfo.FilterOrder


        FIRFilterType{jj}=firOutput{jj};

        if InputVectorSize>1
            if isa((hC.PirInputSignals(1).Type.BaseType),'hdlcoder.tp_complex')||~isreal(blockInfo.Numerator)
                blockInfo.FIRFilterType{jj}=pirelab.getPirVectorType(pir_complex_t(numerictype2pirtype(FIRFilterType{jj})),InputVectorSize);
            else
                blockInfo.FIRFilterType{jj}=pirelab.getPirVectorType(numerictype2pirtype(FIRFilterType{jj}),InputVectorSize);

            end
        else
            if isa((hC.PirInputSignals(1).Type),'hdlcoder.tp_complex')||~isreal(blockInfo.Numerator)
                blockInfo.FIRFilterType{jj}=pir_complex_t(numerictype2pirtype(FIRFilterType{jj}));
            else
                blockInfo.FIRFilterType{jj}=numerictype2pirtype(FIRFilterType{jj});
            end
        end
    end

    inputDTfi=fi(0,inputDT.BaseType.Signed,inputDT.BaseType.WordLength,inputDT.BaseType.FractionLength*-1);


    [fullPrecision,inputPrecision]=dsp.internal.FIRFilterPrecision(cast(Numerator,'like',blockInfo.NumeratorQuantized),inputDTfi);

    if isnumerictype(blockInfo.OutputDataType)
        FIROutputype=blockInfo.OutputDataType;
    elseif strcmpi(blockInfo.OutputDataType,'Full precision')
        FIROutputype=fullPrecision;
    else
        wordLength=inputPrecision.WordLength;
        fractionLength=fullPrecision.FractionLength-(fullPrecision.WordLength-inputPrecision.WordLength);
        signed=fullPrecision.SignednessBool;
        FIROutputype=numerictype(signed,wordLength,fractionLength);


    end



    if InputVectorSize>1
        if isa((hC.PirInputSignals(1).Type.BaseType),'hdlcoder.tp_complex')||~isreal(blockInfo.Numerator)
            blockInfo.FIROutputype=pirelab.getPirVectorType(pir_complex_t(numerictype2pirtype(FIROutputype)),InputVectorSize);
        else
            blockInfo.FIROutputype=pirelab.getPirVectorType(numerictype2pirtype(FIROutputype),InputVectorSize);

        end
    else
        if isa((hC.PirInputSignals(1).Type),'hdlcoder.tp_complex')||~isreal(blockInfo.Numerator)
            blockInfo.FIROutputype=pir_complex_t(numerictype2pirtype(FIROutputype));
        else
            blockInfo.FIROutputype=(numerictype2pirtype(FIROutputype));
        end
    end





    latency=zeros(1,size(blockInfo.FilterOrder,1));

    if~isnumerictype(blockInfo.CoefficientsDataType)
        coeffDT=numerictype('double');
    else
        coeffDT=blockInfo.CoefficientsDataType;
    end


    for ii=1:1:blockInfo.FilterOrder

        latency(ii)=getLatency(pFilterArray{ii},coeffDT,...
        pFilterArray{ii}.Numerator,IsFilterComplex,double(InputVectorSize));

    end


    blockInfo.MinFIRLatency=min(latency);
    blockInfo.MaxFIRLatency=max(latency)+1;
    [~,ind]=max(latency(1:blockInfo.FilterOrder));
    blockInfo.FIRMaxDelay=ind;


    if blockInfo.NumCycles==1
        blockInfo.FIRDelay=zeros(1,size(blockInfo.FilterOrder,1));

        for ii=1:1:size(blockInfo.Numerator,1)
            blockInfo.FIRDelay(ii)=blockInfo.MaxFIRLatency-latency(ii)-1;
        end
    else
        blockInfo.FIRDelay=zeros(1,size(blockInfo.FilterOrder,1));

        for ii=1:1:size(blockInfo.Numerator,1)
            blockInfo.FIRDelay(ii)=blockInfo.MaxFIRLatency-latency(ii);
        end

    end

    blockInfo.XILINX_MAXOUTPUT_WORDLENGTH=48;
    blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH=44;
    blockInfo.CompiledInputSize=getVecSize(hC.PirInputSignal(1));
    blockInfo.SerializationOption='Minimum number of cycles between valid input samples';




end

function DT=resolveDT(DT,Mode)
    if strcmpi(Mode,'block')
        DT=hdlgetallfromsltype(DT);
        DT=numerictype(DT.signed,DT.size,DT.bp);
    else
        DT=DT.PirInputSignals(1).Type.BaseType;
        if isa(DT,'hdlcoder.tp_complex')
            DT=DT.BaseType;
            DT=numerictype(DT.Signed,DT.WordLength,-DT.FractionLength);
        else
            DT=numerictype(DT.Signed,DT.WordLength,-DT.FractionLength);
        end
    end
end

function OVF=resolveOverFlow(overFlow)
    if strcmpi(overFlow,'off')
        OVF='Wrap';
    else
        OVF='Saturate';
    end
end

function pirt=numerictype2pirtype(nt)

    pirt=pir_fixpt_t(nt.SignednessBool,nt.WordLength,-nt.FractionLength);
end

function vecSize=getVecSize(dataIn)
    dInType=pirgetdatatypeinfo(dataIn.Type);
    vecSize=dInType.dims;
end



