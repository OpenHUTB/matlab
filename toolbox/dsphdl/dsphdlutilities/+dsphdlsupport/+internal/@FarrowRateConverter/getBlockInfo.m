function blockInfo=getBlockInfo(this,hC)








    blockInfo=struct();

    typeInfo=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    InputVectorSize=typeInfo.dims;
    IsFilterComplex=logical(typeInfo.iscomplex);

    if isa(hC,'hdlcoder.sysobj_comp')


        hSysObj=hC.getSysObjImpl;


        inputDT=hC.PirInputSignals(1).Type.BaseType;
        inputNT=fi(0,inputDT.Signed,inputDT.WordLength,inputDT.FractionLength*-1);
        inputWL=hC.PirInputSignals(1).Type.BaseType.BaseType.WordLength;


        blockInfo.Mode=hSysObj.RateChangeSource;
        blockInfo.RateChange=hSysObj.RateChange;
        blockInfo.Numerator=hSysObj.Coefficients;
        blockInfo.FilterStructure=hSysObj.FilterStructure;
        blockInfo.NumCycles=hSysObj.NumCycles;
        blockInfo.ResetInputPort=hSysObj.ResetInputPort;
        blockInfo.HDLGlobalReset=hSysObj.HDLGlobalReset;
        blockInfo.RoundingMethod=hSysObj.RoundingMethod;


        blockInfo.CoefficientsDataType=hSysObj.CoefficientsDataType;

        if strcmpi(blockInfo.Mode,'Property')
            fractionaldelayFixdt=(hSysObj.RateChangeDataType);
        else
            rateDT=hC.PirInputSignals(3).Type.BaseType;
            fractionaldelayFixdt=fixdt(1,rateDT.WordLength,-rateDT.FractionLength);
        end
        if strcmpi(fractionaldelayFixdt.DataTypeMode,'Fixed-point: unspecified scaling')
            if blockInfo.RateChange>=1
                if blockInfo.RateChange<2
                    fracDT=fi(2,fractionaldelayFixdt);
                else
                    fracDT=fi(blockInfo.RateChange,fractionaldelayFixdt);
                end
            else
                fracDT=fi(1,fractionaldelayFixdt);
            end
            blockInfo.FractionalDelayDataType=numerictype2pirtype(numerictype(fracDT.numerictype));
        else

            blockInfo.FractionalDelayDataType=numerictype2pirtype(numerictype(fractionaldelayFixdt));
        end

        blockInfo.OutputDataType=hC.PirOutputSignals(1).Type;


        blockInfo.OverflowAction=hSysObj.OverflowAction;


        if ischar(hSysObj.MultiplicandDataType)
            switch hSysObj.MultiplicandDataType
            case 'Full precision'
                blockInfo.MultiplicandDataType=blockInfo.FractionalDelayDataType;
            end
        else
            multiplicandFixdt=hSysObj.MultiplicandDataType;
            if strcmpi(multiplicandFixdt.DataTypeMode,'Fixed-point: unspecified scaling')
                multDT=fi(1,multiplicandFixdt);
                blockInfo.MultiplicandDataType=numerictype2pirtype(numerictype(multDT.numerictype));
            else
                blockInfo.MultiplicandDataType=numerictype2pirtype(numerictype(multiplicandFixdt));
            end
        end
        blockInfo.inMode=[true;...
        strcmpi((hSysObj.ResetInputPort),'on')];


    else


        hBlock=hC.SimulinkHandle;

        inputDT=hC.PirInputSignals(1).Type.BaseType;
        inputNT=fi(0,inputDT.Signed,inputDT.WordLength,inputDT.FractionLength*-1);
        inputWL=hC.PirInputSignals(1).Type.BaseType.BaseType.WordLength;


        blockInfo.Mode=get_param(hBlock,'RateChangeSource');
        blockInfo.RateChange=this.hdlslResolve('RateChange',hBlock);
        blockInfo.Numerator=this.hdlslResolve('Coefficients',hBlock);
        blockInfo.FilterStructure=get_param(hBlock,'FilterStructure');
        blockInfo.NumCycles=this.hdlslResolve('NumCycles',hBlock);
        blockInfo.ResetInputPort=strcmpi(get_param(hBlock,'ResetInputPort'),'on');
        blockInfo.HDLGlobalReset=strcmpi(get_param(hBlock,'HDLGlobalReset'),'on');
        blockInfo.RoundingMethod=get_param(hBlock,'RoundingMode');


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

        if strcmpi(blockInfo.Mode,'Property')
            fractionaldelayFixdt=this.hdlslResolve('RateChangeDataTypeStr',hBlock);

        else

            rateDT=hC.PirInputSignals(3).Type.BaseType;

            if~rateDT.Signed
                fractionaldelayFixdt=fixdt(1,rateDT.WordLength+1,-rateDT.FractionLength);
            else
                fractionaldelayFixdt=fixdt(1,rateDT.WordLength,-rateDT.FractionLength);
            end
        end

        if strcmpi(fractionaldelayFixdt.DataTypeMode,'Fixed-point: unspecified scaling')
            if blockInfo.RateChange>=1
                if blockInfo.RateChange<2
                    fracDT=fi(2,fractionaldelayFixdt);
                else
                    fracDT=fi(blockInfo.RateChange,fractionaldelayFixdt);
                end
            else
                fracDT=fi(1,fractionaldelayFixdt);
            end
            blockInfo.FractionalDelayDataType=numerictype2pirtype(numerictype(fracDT.numerictype));
        else
            blockInfo.FractionalDelayDataType=numerictype2pirtype(numerictype(fractionaldelayFixdt));
        end


        blockInfo.OutputDataType=hC.PirOutputSignals(1).Type;

        if strcmpi(get_param(hBlock,'OverflowMode'),'off')
            blockInfo.OverflowAction='Wrap';
        else
            blockInfo.OverflowAction='Saturate';
        end


        switch get_param(hBlock,'MultiplicandDataTypeStr')
        case 'Inherit: Inherit via internal rule'
            blockInfo.MultiplicandDataType=blockInfo.FractionalDelayDataType;
        otherwise
            multiplicandFixdt=this.hdlslResolve('MultiplicandDataTypeStr',hBlock);
            if strcmpi(multiplicandFixdt.DataTypeMode,'Fixed-point: unspecified scaling')
                multDT=fi(1,multiplicandFixdt);
                blockInfo.MultiplicandDataType=numerictype2pirtype(numerictype(multDT.numerictype));
            else
                blockInfo.MultiplicandDataType=numerictype2pirtype(numerictype(multiplicandFixdt));
            end
        end


        blockInfo.inMode=[true;...
        strcmpi(get_param(hBlock,'ResetInputPort'),'on')];

    end



    if isnumerictype(blockInfo.CoefficientsDataType)
        coeffsNumerictype=blockInfo.CoefficientsDataType;
    else
        coeffsNumerictype=numerictype([],inputWL);
    end

    blockInfo.NumeratorQuantized=fi(blockInfo.Numerator,coeffsNumerictype);
    blockInfo.FilterOrder=size(blockInfo.Numerator,1);

    pFilterArray=cell(size(blockInfo.Numerator,1),1);
    oldMSB=0;oldFraction=0;

    for ii=1:1:size(blockInfo.Numerator,1)
        if blockInfo.NumCycles==1
            pFilterArray{ii}=dsphdl.FIRFilter('Numerator',blockInfo.Numerator(:,ii)',...
            'FilterStructure',blockInfo.FilterStructure,...
            'RoundingMethod',blockInfo.RoundingMethod,...
            'OverflowAction',blockInfo.OverflowAction,...
            'CoefficientsDataType',blockInfo.CoefficientsDataType,...
            'ResetInputPort',blockInfo.ResetInputPort,...
            'HDLGlobalReset',blockInfo.HDLGlobalReset,...
            'OutputDataType','Full precision');

            pFilterArray{ii}.setCoeffDTCheck(false);


            if blockInfo.ResetInputPort
                setup(pFilterArray{ii},cast(0,'like',inputNT),true,false);
            else
                setup(pFilterArray{ii},cast(0,'like',inputNT),true);
            end
        else
            pFilterArray{ii}=dsphdl.FIRFilter('Numerator',blockInfo.Numerator(:,ii)',...
            'FilterStructure','Partly serial systolic',...
            'NumCycles',blockInfo.NumCycles,...
            'RoundingMethod',blockInfo.RoundingMethod,...
            'OverflowAction',blockInfo.OverflowAction,...
            'CoefficientsDataType',blockInfo.CoefficientsDataType,...
            'ResetInputPort',blockInfo.ResetInputPort,...
            'HDLGlobalReset',blockInfo.HDLGlobalReset,...
            'OutputDataType','Full precision');

            pFilterArray{ii}.setCoeffDTCheck(false);


            if blockInfo.ResetInputPort
                setup(pFilterArray{ii},cast(0,'like',inputNT),true,false);
            else
                setup(pFilterArray{ii},cast(0,'like',inputNT),true);
            end

        end
    end

    firOutput=cell(size(blockInfo.Numerator,1),1);
    for ii=1:1:size(blockInfo.Numerator,1)
        if isa((hC.PirInputSignals(1).Type),'hdlcoder.tp_complex')
            if blockInfo.ResetInputPort
                [out,~]=output(pFilterArray{ii},cast(0+0*i,'like',inputNT),true,false);
            else
                [out,~]=output(pFilterArray{ii},cast(0+0*i,'like',inputNT),true);
            end
            firOutput{ii}=out;
        else
            if blockInfo.ResetInputPort
                [out,~]=output(pFilterArray{ii},cast(0,'like',inputNT),true,false);
            else
                [out,~]=output(pFilterArray{ii},cast(0,'like',inputNT),true);
            end
            firOutput{ii}=out;
        end
    end


    for jj=1:1:blockInfo.FilterOrder
        MSB=firOutput{jj}.WordLength-firOutput{jj}.FractionLength;
        fraction=firOutput{jj}.FractionLength;
        if MSB>oldMSB
            oldMSB=MSB;
        end
        if fraction>oldFraction
            oldFraction=fraction;
        end
        FIRFilterType{jj}=firOutput{jj};
        if isa((hC.PirInputSignals(1).Type),'hdlcoder.tp_complex')
            blockInfo.FIRFilterType{jj}=pir_complex_t(numerictype2pirtype(FIRFilterType{jj}));

        else
            blockInfo.FIRFilterType{jj}=numerictype2pirtype(FIRFilterType{jj});

        end
    end


    FIROutputype=numerictype(inputNT.Signed,oldMSB+oldFraction,oldFraction);
    if isa((hC.PirInputSignals(1).Type),'hdlcoder.tp_complex')
        blockInfo.FIROutputype=pir_complex_t(numerictype2pirtype(FIROutputype));
    else
        blockInfo.FIROutputype=numerictype2pirtype(FIROutputype);
    end



    inputDTfi=fi(0,inputDT.BaseType.Signed,inputDT.BaseType.WordLength,inputDT.BaseType.FractionLength*-1);
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
    blockInfo.SymmetryOptimization=true;

end






function pirt=numerictype2pirtype(nt)

    pirt=pir_fixpt_t(nt.SignednessBool,nt.WordLength,-nt.FractionLength);
end

function vecSize=getVecSize(dataIn)
    dInType=pirgetdatatypeinfo(dataIn.Type);
    vecSize=dInType.dims;
end






