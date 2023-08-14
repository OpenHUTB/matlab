function blockInfo=getBlockInfo(this,hC)








    blockInfo=struct();
    blockInfo.XILINX_MAXOUTPUT_WORDLENGTH=48;
    blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH=44;
    blockInfo.DELAYLINELIMIT2MAP2RAM=64;
    if isa(hC,'hdlcoder.sysobj_comp')


        hSysObj=hC.getSysObjImpl;

        blockInfo.FilterStructure=hSysObj.FilterStructure;
        blockInfo.NumeratorSource=hSysObj.NumeratorSource;
        if strcmpi(blockInfo.NumeratorSource,'Property')
            blockInfo.Numerator=hSysObj.Numerator;
        else
            blockInfo.Numerator=hSysObj.NumeratorPrototype;
        end

        if strcmpi(blockInfo.FilterStructure,'Partly serial systolic')
            blockInfo.SerializationOption=hSysObj.SerializationOption;
            if strcmpi(blockInfo.SerializationOption,'Minimum number of cycles between valid input samples')
                sFactor=hSysObj.NumCycles;
                if isinf(sFactor)||sFactor>=length(blockInfo.Numerator)
                    blockInfo.SharingFactor=length(blockInfo.Numerator);
                else
                    blockInfo.SharingFactor=sFactor;
                end
            else
                blockInfo.MaxMultiplier=hSysObj.NumberOfMultipliers;
                blockInfo.SharingFactor=ceil(length(blockInfo.Numerator)/blockInfo.MaxMultiplier);
            end
        end


        blockInfo.RoundingMethod=hSysObj.RoundingMethod;
        blockInfo.OverflowAction=hSysObj.OverflowAction;
        blockInfo.OutputDataType=hSysObj.OutputDataType;
        blockInfo.CompiledInputDT=resolveDT(hC,'SysObj');
        blockInfo.CompiledInputSize=getVecSize(hC.PirInputSignal(1));
        if strcmpi(blockInfo.NumeratorSource,'Input port (Parallel Interface)')
            blockInfo.CompiledCoefInputSize=getVecSize(hC.PirInputSignal(3));
            COEFInputDT=pirgetdatatypeinfo(hC.PirInputSignal(3).Type);
            blockInfo.CoefficientsDataType=numerictype(COEFInputDT.issigned,COEFInputDT.wordsize,-COEFInputDT.binarypoint);
            blockInfo.CoefficientsComplexity=COEFInputDT.iscomplex;
        else
            blockInfo.CompiledCoefInputSize=0;
            blockInfo.CoefficientsDataType=hSysObj.CoefficientsDataType;
        end
        blockInfo.inMode=[true;...
        hSysObj.ResetInputPort];
        blockInfo.HDLGlobalReset=hSysObj.HDLGlobalReset;
        blockInfo.ResetInputPort=hSysObj.ResetInputPort;











    else


        hBlock=hC.SimulinkHandle;


        blockInfo.FilterStructure=get_param(hBlock,'FilterStructure');
        blockInfo.NumeratorSource=get_param(hBlock,'NumeratorSource');
        if strcmpi(blockInfo.NumeratorSource,'Property')
            blockInfo.Numerator=this.hdlslResolve('Numerator',hBlock);
        else
            blockInfo.Numerator=this.hdlslResolve('NumeratorPrototype',hBlock);
        end

        if strcmpi(blockInfo.FilterStructure,'Partly serial systolic')
            blockInfo.SerializationOption=get_param(hBlock,'SerializationOption');
            if strcmpi(blockInfo.SerializationOption,'Minimum number of cycles between valid input samples')
                sFactor=this.hdlslResolve('NumCycles',hBlock);
                if isinf(sFactor)||sFactor>=length(blockInfo.Numerator)
                    blockInfo.SharingFactor=length(blockInfo.Numerator);
                else
                    blockInfo.SharingFactor=sFactor;
                end
            else
                blockInfo.MaxMultiplier=this.hdlslResolve('NumberOfMultipliers',hBlock);
                blockInfo.SharingFactor=blockInfo.MaxMultiplier;
            end
        end

        blockInfo.inMode=[true;...
        strcmpi(get_param(hBlock,'ResetInputPort'),'on')];
        blockInfo.HDLGlobalReset=strcmpi(get_param(hBlock,'HDLGlobalReset'),'on');
        blockInfo.ResetInputPort=strcmpi(get_param(hBlock,'ResetInputPort'),'on');
        blockInfo.RoundingMethod=get_param(hBlock,'RoundingMode');


        if strcmpi(get_param(hBlock,'OverflowMode'),'off')
            blockInfo.OverflowAction='Wrap';
        else
            blockInfo.OverflowAction='Saturate';
        end


        if strcmpi(blockInfo.NumeratorSource,'Property')
            if strcmp(get_param(hBlock,'CoefficientsDataTypeStr'),'Inherit: Same word length as input')
                blockInfo.CoefficientsDataType='Same word length as input';
            else

                coeffsDTResolved=this.hdlslResolve('CoefficientsDataTypeStr',hBlock);
                if ischar(coeffsDTResolved)&&strcmp(coeffsDTResolved,'Inherit: Same word length as input')
                    blockInfo.CoefficientsDataType='Same word length as input';
                else
                    if strcmpi(coeffsDTResolved.Signedness,'Unsigned')
                        blockInfo.CoefficientsDataType=numerictype(fi(0,1,coeffsDTResolved.WordLength+1,coeffsDTResolved.FractionLength));
                    else
                        blockInfo.CoefficientsDataType=numerictype(coeffsDTResolved);
                    end
                end
            end
            blockInfo.CompiledCoefInputSize=0;
        else
            blockInfo.CompiledCoefInputSize=getVecSize(hC.PirInputSignal(3));
            COEFInputDT=pirgetdatatypeinfo(hC.PirInputSignal(3).Type);
            blockInfo.CoefficientsDataType=numerictype(COEFInputDT.issigned,COEFInputDT.wordsize,-COEFInputDT.binarypoint);
            blockInfo.CoefficientsComplexity=COEFInputDT.iscomplex;
        end
        blockInfo.CompiledPortDT=get_param(hBlock,'CompiledPortDataTypes');
        blockInfo.CompiledInputDT=resolveDT(blockInfo.CompiledPortDT.Inport{1},'block');
        blockInfo.CompiledOutputDT=resolveDT(blockInfo.CompiledPortDT.Outport{1},'block');
        blockInfo.CompiledInputSize=getVecSize(hC.PirInputSignal(1));


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
    if~isempty(blockInfo.Numerator)
        blockInfo.NumeratorQuantized=fi(blockInfo.Numerator,coeffsNumerictype);
        blockInfo.SymmetryOptimization=true;
    else
        blockInfo.NumeratorQuantized=[];
        blockInfo.SymmetryOptimization=false;
    end

end


function DT=resolveDT(DT,Mode)
    if strcmpi(Mode,'block')
        DT=hdlgetallfromsltype(DT);
        DT=numerictype(DT.signed,DT.size,DT.bp);
    else
        DT=DT.PirInputSignals(1).Type.BaseType;
        DT=numerictype(DT.Signed,DT.WordLength,-DT.FractionLength);
    end
end

function vecSize=getVecSize(dataIn)
    dInType=pirgetdatatypeinfo(dataIn.Type);
    vecSize=dInType.dims;
end




















