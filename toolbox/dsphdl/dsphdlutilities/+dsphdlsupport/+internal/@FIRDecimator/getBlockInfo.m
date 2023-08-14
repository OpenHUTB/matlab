function blockInfo=getBlockInfo(this,hC)






    blockInfo.XILINX_MAXOUTPUT_WORDLENGTH=48;
    blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH=44;
    blockInfo.DELAYLINELIMIT2MAP2RAM=64;
    hDriver=hdlcurrentdriver;
    blockInfo.synthesisTool=hDriver.getParameter('SynthesisTool');
    blockInfo.FilterCoefficientSource='Property';
    if isa(hC,'hdlcoder.sysobj_comp')
        hSysObj=hC.getSysObjImpl;
        blockInfo.FilterStructure=hSysObj.FilterStructure;
        blockInfo.Numerator=hSysObj.Numerator;
        blockInfo.DecimationFactor=hSysObj.DecimationFactor;
        if strcmpi(blockInfo.FilterStructure,'Direct form systolic')
            numCycle=hSysObj.NumCycles;
            if isinf(numCycle)
                blockInfo.NumCycles=length(blockInfo.Numerator);
            else
                blockInfo.NumCycles=numCycle;
            end
        else
            blockInfo.NumCycles=1;
        end

        blockInfo.RoundingMethod=hSysObj.RoundingMethod;
        blockInfo.OverflowAction=hSysObj.OverflowAction;
        blockInfo.inMode=[true;...
        hSysObj.ResetInputPort];
        blockInfo.HDLGlobalReset=hSysObj.HDLGlobalReset;
        blockInfo.ResetInputPort=hSysObj.ResetInputPort;
        blockInfo.CompiledInputDT=resolveDT(hC,'SysObj');

        blockInfo.CoefficientsDataType=hSysObj.CoefficientsDataType;
        blockInfo.OutputDataType=hSysObj.OutputDataType;
    else

        hBlock=hC.Simulinkhandle;
        blockInfo.FilterStructure=get_param(hBlock,'FilterStructure');
        blockInfo.Numerator=this.hdlslResolve('Numerator',hBlock);
        blockInfo.DecimationFactor=this.hdlslResolve('DecimationFactor',hBlock);
        if strcmpi(blockInfo.FilterStructure,'Direct form systolic')
            numCycle=this.hdlslResolve('NumCycles',hBlock);
            if isinf(numCycle)
                blockInfo.NumCycles=length(blockInfo.Numerator);
            else
                blockInfo.NumCycles=numCycle;
            end
        else
            blockInfo.NumCycles=1;
        end

        blockInfo.RoundingMethod=get_param(hBlock,'roundingMode');
        blockInfo.OverflowAction=resolveOverFlow(get_param(hBlock,'OverflowMode'));

        blockInfo.inMode=[true;...
        strcmpi(get_param(hBlock,'ResetInputPort'),'on')];
        blockInfo.HDLGlobalReset=strcmpi(get_param(hBlock,'HDLGlobalReset'),'on');
        blockInfo.ResetInputPort=strcmpi(get_param(hBlock,'ResetInputPort'),'on');
        blockInfo.CompiledPortDT=get_param(hBlock,'CompiledPortDataTypes');
        blockInfo.CompiledInputDT=resolveDT(blockInfo.CompiledPortDT.Inport{1},'block');
        blockInfo.CompiledOutputDT=resolveDT(blockInfo.CompiledPortDT.Outport{1},'block');

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
    end


    inputWL=hC.PirInputSignals(1).Type.BaseType.BaseType.WordLength;


    if isnumerictype(blockInfo.CoefficientsDataType)
        coeffsNumerictype=blockInfo.CoefficientsDataType;
    else
        coeffsNumerictype=numerictype([],inputWL);
    end

    blockInfo.NumeratorQuantized=fi(blockInfo.Numerator,coeffsNumerictype);

    [blockInfo.isPartlySerial,blockInfo.isLthBand,blockInfo.vldIdx,blockInfo.delayBalanceVector,blockInfo.singlePartlySerial]=getPartlySerialProp(hC,blockInfo);

end

function DT=resolveDT(DT,Mode)
    if strcmpi(Mode,'block')
        DT=hdlgetallfromsltype(DT);
        DT=numerictype(DT.signed,DT.size,DT.bp);
    else

        DT=DT.PirInputSignals(1).Type.BaseType.BaseType;
        DT=numerictype(DT.Signed,DT.WordLength,-DT.FractionLength);
    end
end

function OVF=resolveOverFlow(overFlow)
    if strcmpi(overFlow,'off')
        OVF='Wrap';
    else
        OVF='Saturate';
    end
end

function[isPartlySerialArch,isLthBand,vldIdx,delayBalanceVector,singlePartlySerial]=getPartlySerialProp(hC,blockInfo)
    if strcmpi(blockInfo.FilterStructure,'Direct form transposed')
        isPartlySerialArch=false;
        isLthBand=false;
        vldIdx=1;
        delayBalanceVector=0;
        singlePartlySerial=false;
    else
        decimFactor=blockInfo.DecimationFactor;
        numerator=blockInfo.Numerator;
        firDecim=dsphdl.FIRDecimator('Numerator',numerator,...
        'FilterStructure',blockInfo.FilterStructure,...
        'DecimationFactor',decimFactor,...
        'NumCycles',blockInfo.NumCycles);

        inData=hC.PirInputsignals(1);
        pirInType=pirgetdatatypeinfo(inData.Type);
        slInType=numerictype(pirInType.issigned,pirInType.wordsize,-pirInType.binarypoint);
        slCoeffType=getCoefficientsDT(firDecim,slInType);
        reshape_coeff=reshapeFilterCoef(firDecim,numerator,decimFactor);
        [isLthBand,~]=dsphdl.FIRDecimator.isLthBandFilter(reshape_coeff,decimFactor);
        isPartlySerialArch=isPartlySerial(firDecim,pirInType.dims,isLthBand,reshape_coeff);
        singlePartlySerial=blockInfo.NumCycles>=length(numerator);
        fcell=getPartlySerialFIRFilters(firDecim,numerator,singlePartlySerial,slInType);
        [~,delayBalanceVector]=getPartlySerialLatency(firDecim,fcell,slCoeffType,logical(pirInType.iscomplex));
        delayBalanceVector=flipud(delayBalanceVector);
        nonZeroCoeffV=getNonZeroCoeffFilter(firDecim,fcell,slCoeffType);
        vldIdx=0;
        for ii=1:length(fcell)
            if delayBalanceVector(ii)==0&&nonZeroCoeffV(ii)==true
                vldIdx=vldIdx+1;
            end
        end
    end
end


