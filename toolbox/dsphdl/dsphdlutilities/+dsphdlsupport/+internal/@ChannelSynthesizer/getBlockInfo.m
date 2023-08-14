function blockInfo=getBlockInfo(this,hC)






    blockInfo.XILINX_MAXOUTPUT_WORDLENGTH=48;
    blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH=44;
    blockInfo.DELAYLINELIMIT2MAP2RAM=64;
    tpinfo=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);

    blockInfo.NumFrequencyBands=double(tpinfo.dims);
    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;

        blockInfo.inMode=[true;...
        sysObjHandle.ResetInputPort];
        blockInfo.FilterStructure=sysObjHandle.FilterStructure;
        blockInfo.ComplexMultiplication=sysObjHandle.ComplexMultiplication;
        blockInfo.Normalize=sysObjHandle.Normalize;
        blockInfo.RoundingMethod=sysObjHandle.RoundingMethod;
        blockInfo.OverflowAction=sysObjHandle.OverflowAction;

        blockInfo.FilterCoefficient=sysObjHandle.FilterCoefficients;
        blockInfo.CompiledInputDT=resolveInputDT(tpinfo,'SysObj');
        blockInfo.OutputDataType=resolveFiltDT(this,sysObjHandle.OutputDataType,...
        sysObjHandle,sysObjHandle.OutputDataType);
        blockInfo.CoefficientsDataType=resolveCoeffDT(this,sysObjHandle.CoefficientsDataType,...
        sysObjHandle,sysObjHandle.CoefficientsDataType);
        blockInfo.Numerator=blockInfo.FilterCoefficient;
        if sysObjHandle.Normalize
            blockInfo.BitGrowthVector=zeros(log2(blockInfo.NumFrequencyBands),1);
        else
            blockInfo.BitGrowthVector=ones(log2(blockInfo.NumFrequencyBands),1);
        end
        blockInfo.resetnone=false;
    else

        slHandle=hC.Simulinkhandle;

        blockInfo.inMode=[true;...
        strcmpi(get_param(slHandle,'ResetInputPort'),'on')];
        blockInfo.FilterStructure=get_param(slHandle,'FilterStructure');
        blockInfo.ComplexMultiplication=get_param(slHandle,'ComplexMultiplication');
        blockInfo.Normalize=strcmpi(get_param(slHandle,'Normalize'),'on');
        blockInfo.RoundingMethod=get_param(slHandle,'roundingMode');
        blockInfo.OverflowAction=resolveOverFlow(get_param(slHandle,'OverflowMode'));

        blockInfo.FilterCoefficient=this.hdlslResolve('FilterCoefficients',slHandle);
        blockInfo.CompiledPortDT=get_param(slHandle,'CompiledPortDataTypes');
        blockInfo.CompiledInputDT=resolveInputDT(blockInfo.CompiledPortDT.Inport{1},'block');
        blockInfo.OutputDataType=resolveFiltDT(this,strrep(get_param(slHandle,'OutputDataTypeStr'),'Inherit: ',''),slHandle,'OutputDataTypeStr');
        blockInfo.CoefficientsDataType=resolveCoeffDT(this,strrep(get_param(slHandle,'CoefficientsDataTypeStr'),'Inherit: ',''),slHandle,'CoefficientsDataTypeStr');
        blockInfo.Numerator=blockInfo.FilterCoefficient;
        if blockInfo.Normalize
            blockInfo.BitGrowthVector=zeros(log2(double(blockInfo.NumFrequencyBands)),1);
        else
            blockInfo.BitGrowthVector=ones(log2(double(blockInfo.NumFrequencyBands)),1);
        end
    end
    blockInfo.resetnone=false;
end

function DT=resolveInputDT(inputDT,Mode)
    if strcmpi(Mode,'block')
        DT=hdlgetallfromsltype(inputDT);
        DT=numerictype(DT.signed,DT.size,DT.bp);
    else
        DT=inputDT;

        DT=numerictype(DT.issigned,DT.wordsize,-DT.binarypoint);
    end
end

function resolvedDT=resolveCoeffDT(this,unResolvedDT,hBlock,dataTypeStr)
    if isnumerictype(unResolvedDT)
        if strcmpi(unResolvedDT.Signedness,'Signed')
            resolvedDT=numerictype(1,unResolvedDT.WordLength,unResolvedDT.FractionLength);
        else
            resolvedDT=numerictype(0,unResolvedDT.WordLength,unResolvedDT.FractionLength);
        end
    elseif strcmpi(unResolvedDT,'Same word length as input')

        resolvedDT=unResolvedDT;
    else
        type=this.hdlslResolve(dataTypeStr,hBlock);
        resolvedDT=numerictype(type);
    end
end

function resolvedDT=resolveFiltDT(this,unResolvedDT,hBlock,dataTypeStr)
    if isnumerictype(unResolvedDT)
        if strcmpi(unResolvedDT.Signedness,'Signed')
            resolvedDT=numerictype(1,unResolvedDT.WordLength,unResolvedDT.FractionLength);
        else
            resolvedDT=numerictype(0,unResolvedDT.WordLength,unResolvedDT.FractionLength);
        end
    elseif strcmpi(unResolvedDT,'Same as input')||strcmpi(unResolvedDT,'Inherit via internal rule')...
        ||strcmpi(unResolvedDT,'Full precision')
        resolvedDT=unResolvedDT;
    else
        type=this.hdlslResolve(dataTypeStr,hBlock);
        resolvedDT=numerictype(type);
    end
end

function OVF=resolveOverFlow(overFlow)
    if strcmpi(overFlow,'off')
        OVF='Wrap';
    else
        OVF='Saturate';
    end
end

