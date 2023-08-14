function blockInfo=getBlockInfo(this,hC)







    blockInfo=struct();




    blockInfo.PipeLevel=4;
    tempSize=getVecSize(hC.PirInputSignal(1));
    blockInfo.FrameSize=double(tempSize(1));

    if isa(hC,'hdlcoder.sysobj_comp')


        hSysObj=hC.getSysObjImpl;
















        blockInfo.Structure=hSysObj.Structure;
        blockInfo.Numerator=hSysObj.Numerator;
        blockInfo.Denominator=hSysObj.Denominator;
        blockInfo.ScaleValues=hSysObj.ScaleValues;
        blockInfo.RoundingMethod=hSysObj.RoundingMethod;
        blockInfo.OverflowAction=hSysObj.OverflowAction;
        blockInfo.NumeratorDataType=hSysObj.NumeratorDataType;
        blockInfo.CustomNumeratorDataType=hSysObj.CustomNumeratorDataType;
        blockInfo.DenominatorDataType=hSysObj.DenominatorDataType;
        blockInfo.CustomDenominatorDataType=hSysObj.CustomDenominatorDataType;
        blockInfo.ScaleValuesDataType=hSysObj.ScaleValuesDataType;
        blockInfo.CustomScaleValuesDataType=hSysObj.CustomScaleValuesDataType;
        blockInfo.AccumulatorDataType=hSysObj.AccumulatorDataType;
        blockInfo.CustomAccumulatorDataType=hSysObj.CustomAccumulatorDataType;
        blockInfo.OutputDataType=hSysObj.OutputDataType;
        blockInfo.CustomOutputDataType=hSysObj.CustomOutputDataType;
        blockInfo.Latency=hSysObj.getLatency;
        blockInfo.CompiledInputDT=resolveDT(hC,'SysObj');
        blockInfo.NumSections=size(blockInfo.Denominator,1);

        inputWL=blockInfo.CompiledInputDT.WordLength;
        inputFL=blockInfo.CompiledInputDT.FractionLength;
        inputSign=blockInfo.CompiledInputDT.Signed;

        if strcmp(blockInfo.NumeratorDataType,'Custom')
            numNumerictype=blockInfo.CustomNumeratorDataType;
            numSign=numNumerictype.Signed;
            numWL=numNumerictype.WordLength;
            numFL=numNumerictype.FractionLength;
            blockInfo.numCoeffs=fi(blockInfo.Numerator,numSign,numWL,numFL);
            blockInfo.numCoeffWL=numWL;
            blockInfo.numCoeffFL=-1*numFL;
        else
            blockInfo.numCoeffs=fi(blockInfo.Numerator,[],inputWL);
            blockInfo.numCoeffWL=inputWL;
            blockInfo.numCoeffFL=-1*blockInfo.numCoeffs.FractionLength;
        end

        if strcmp(blockInfo.DenominatorDataType,'Custom')
            denNumerictype=blockInfo.CustomDenominatorDataType;
            denSign=denNumerictype.Signed;
            denWL=denNumerictype.WordLength;
            denFL=denNumerictype.FractionLength;
            blockInfo.denCoeffs=fi(blockInfo.Denominator(:,2:end),denSign,denWL,denFL);
            blockInfo.denCoeffWL=denWL;
            blockInfo.denCoeffFL=-1*denFL;
        else
            blockInfo.denCoeffs=fi(blockInfo.Denominator(:,2:end),1,inputWL);
            blockInfo.denCoeffWL=inputWL;
            blockInfo.denCoeffFL=-1*blockInfo.denCoeffs.FractionLength;
        end
        blockInfo.denCoeffOrigFL=blockInfo.denCoeffFL;

        if strcmp(blockInfo.ScaleValuesDataType,'Custom')
            svNumerictype=blockInfo.CustomScaleValuesDataType;
            svSign=svNumerictype.Signed;
            svWL=svNumerictype.WordLength;
            svFL=svNumerictype.FractionLength;
            blockInfo.SVSign=svSign;
            blockInfo.SVWL=svWL;
            blockInfo.SVFL=-1*svFL;
            nSV=numel(blockInfo.ScaleValues);
            if nSV<blockInfo.NumSections+1
                blockInfo.SVCoeffs=fi([blockInfo.ScaleValues(:);ones(blockInfo.NumSections-nSV+1,1)],blockInfo.SVSign,blockInfo.SVWL,-blockInfo.SVFL);
            else
                blockInfo.SVCoeffs=fi(blockInfo.ScaleValues(:),blockInfo.SVSign,blockInfo.SVWL,-blockInfo.SVFL);
            end

        else
            nSV=numel(blockInfo.ScaleValues);
            if nSV<blockInfo.NumSections+1
                blockInfo.SVCoeffs=fi([blockInfo.ScaleValues(:);ones(blockInfo.NumSections-nSV+1,1)],[],inputWL);
            else
                blockInfo.SVCoeffs=fi(blockInfo.ScaleValues(:),[],inputWL);
            end
            blockInfo.SVSign=blockInfo.SVCoeffs.Signed;
            blockInfo.SVWL=inputWL;
            blockInfo.SVFL=-1*blockInfo.SVCoeffs.FractionLength;
        end

        if strcmp(blockInfo.AccumulatorDataType,'Custom')
            accumNumerictype=blockInfo.CustomAccumulatorDataType;
        else
            accumNumerictype=numerictype(inputSign,inputWL,inputFL);
        end
        blockInfo.accumTypeSign=accumNumerictype.Signed;
        blockInfo.accumTypeWL=accumNumerictype.WordLength;
        blockInfo.accumTypeFL=-1*accumNumerictype.FractionLength;

        if strcmp(blockInfo.OutputDataType,'Custom')
            outNumerictype=blockInfo.CustomOutputDataType;
        elseif strcmp(blockInfo.OutputDataType,'Same as first input')
            outNumerictype=numerictype(inputSign,inputWL,inputFL);
        else
            outNumerictype=numerictype(blockInfo.accumTypeSign,blockInfo.accumTypeWL,-blockInfo.accumTypeFL);
        end
        blockInfo.sectionDataType=outNumerictype;
        blockInfo.sectionTypeSign=strcmp(blockInfo.sectionDataType.Signedness,'Signed');
        blockInfo.sectionTypeWL=blockInfo.sectionDataType.WordLength;
        blockInfo.sectionTypeFL=-1*blockInfo.sectionDataType.FractionLength;

        if strcmpi(blockInfo.Structure,'Pipelined feedback form')
            [no,nm,nno,do,~]=dsphdlpipebiquadcoeffs(blockInfo.Numerator,blockInfo.Denominator,blockInfo.ScaleValues,...
            blockInfo.PipeLevel,blockInfo.FrameSize);
            blockInfo.PipeNumerator=no;
            blockInfo.PipeNumeratorMap=nm;
            blockInfo.PipeNewNumerator=nno;
            blockInfo.PipeDenominator=do;
            if strcmp(blockInfo.DenominatorDataType,'Inherit: Same word length as input')
                tempdo=fi(do(:,2:end),1,inputWL);
                blockInfo.denCoeffFL=-1*tempdo.FractionLength;
            else

                denDTResolved=blockInfo.DenominatorDataType;
                if ischar(denDTResolved)&&strcmp(denDTResolved,'Inherit: Same word length as input')
                    tempdo=fi(do(:,2:end),1,inputWL);
                    blockInfo.denCoeffFL=-1*tempdo.FractionLength;
                end
            end

        else
            blockInfo.PipeNumerator=[];
            blockInfo.PipeNumeratorMap=[];
            blockInfo.PipeNewNumerator=[];
            blockInfo.PipeDenominator=[];
        end
    else

        hBlock=hC.SimulinkHandle;

        blockInfo.Structure=get_param(hBlock,'Structure');
        blockInfo.Numerator=this.hdlslResolve('Numerator',hBlock);
        blockInfo.Denominator=this.hdlslResolve('Denominator',hBlock);
        blockInfo.ScaleValues=this.hdlslResolve('ScaleValues',hBlock);


        if strcmpi(get_param(hBlock,'OverflowMode'),'off')
            blockInfo.OverflowAction='Wrap';
        else
            blockInfo.OverflowAction='Saturate';
        end
        blockInfo.RoundingMethod=get_param(hBlock,'RoundingMode');

        blockInfo.CompiledPortDT=get_param(hBlock,'CompiledPortDataTypes');
        blockInfo.CompiledInputDT=resolveDT(blockInfo.CompiledPortDT.Inport{1},'block');
        inputWL=blockInfo.CompiledInputDT.WordLength;
        blockInfo.CompiledOutputDT=resolveDT(blockInfo.CompiledPortDT.Outport{1},'block');


        if strcmp(get_param(hBlock,'NumeratorDataTypeStr'),'Inherit: Same word length as input')
            blockInfo.NumeratorDataType=numerictype([],inputWL);
        else

            numDTResolved=this.hdlslResolve('NumeratorDataTypeStr',hBlock);
            if ischar(numDTResolved)&&strcmp(numDTResolved,'Inherit: Same word length as input')
                blockInfo.NumeratorDataType=numerictype([],inputWL);
            else
                blockInfo.NumeratorDataType=numerictype(numDTResolved);
            end
        end

        if strcmp(get_param(hBlock,'DenominatorDataTypeStr'),'Inherit: Same word length as input')
            blockInfo.DenominatorDataType=numerictype([],inputWL);
        else

            denDTResolved=this.hdlslResolve('DenominatorDataTypeStr',hBlock);
            if ischar(denDTResolved)&&strcmp(denDTResolved,'Inherit: Same word length as input')
                blockInfo.DenominatorDataType=numerictype([],inputWL);
            else
                blockInfo.DenominatorDataType=numerictype(denDTResolved);
            end
        end

        if strcmp(get_param(hBlock,'ScaleValuesDataTypeStr'),'Inherit: Same word length as input')
            blockInfo.ScaleValuesDataType=numerictype([],inputWL);
        else

            SVDTResolved=this.hdlslResolve('ScaleValuesDataTypeStr',hBlock);
            if ischar(SVDTResolved)&&strcmp(SVDTResolved,'Inherit: Same word length as input')
                blockInfo.ScaleValuesDataType=numerictype([],inputWL);
            else
                blockInfo.ScaleValuesDataType=numerictype(SVDTResolved);
            end
        end

        if strcmp(get_param(hBlock,'AccumulatorDataTypeStr'),'Inherit: Same as first input')
            blockInfo.AccumulatorDataType=blockInfo.CompiledInputDT;
        else

            AccDTResolved=this.hdlslResolve('AccumulatorDataTypeStr',hBlock);
            if ischar(AccDTResolved)&&strcmp(AccDTResolved,'Inherit: Same as first input')
                blockInfo.AccumulatorDataType=blockInfo.CompiledInputDT;
            else
                blockInfo.AccumulatorDataType=numerictype(AccDTResolved);
            end
        end


        switch get_param(hBlock,'OutputDataTypeStr')
        case 'Inherit: Inherit via internal rule'
            blockInfo.OutputDataType=blockInfo.AccumulatorDataType;
        case 'Inherit: Same as first input'
            blockInfo.OutputDataType=blockInfo.CompiledOutputDT;
        otherwise

            outputDTResolved=this.hdlslResolve('OutputDataTypeStr',hBlock);
            if ischar(outputDTResolved)&&strcmp(outputDTResolved,'Inherit: Inherit via internal rule')
                blockInfo.OutputDataType='Full precision';
            elseif ischar(outputDTResolved)&&strcmp(outputDTResolved,'Inherit: Same as first input')
                blockInfo.OutputDataType=blockInfo.CompiledInputDT;
            else
                blockInfo.OutputDataType=numerictype(outputDTResolved);
            end
        end

        blockInfo.NumSections=size(blockInfo.Denominator,1);
        numWL=blockInfo.NumeratorDataType.WordLength;
        if~strcmp(blockInfo.NumeratorDataType.Signedness,'Auto')
            numSign=strcmp(blockInfo.NumeratorDataType.Signedness,'Signed');
            numFL=-1*blockInfo.NumeratorDataType.FractionLength;
            blockInfo.numCoeffs=fi(blockInfo.Numerator,numSign,numWL,-numFL);
        else
            blockInfo.numCoeffs=fi(blockInfo.Numerator,[],numWL);
        end
        blockInfo.numCoeffWL=blockInfo.numCoeffs.WordLength;
        blockInfo.numCoeffFL=-1*blockInfo.numCoeffs.FractionLength;

        denWL=blockInfo.DenominatorDataType.WordLength;
        if~strcmp(blockInfo.DenominatorDataType.Signedness,'Auto')
            denSign=strcmp(blockInfo.DenominatorDataType.Signedness,'Signed');
            denFL=-1*blockInfo.DenominatorDataType.FractionLength;
            blockInfo.denCoeffs=fi(blockInfo.Denominator(:,2:end),denSign,denWL,-denFL);
        else
            blockInfo.denCoeffs=fi(blockInfo.Denominator(:,2:end),1,denWL);
        end
        blockInfo.denCoeffWL=blockInfo.denCoeffs.WordLength;
        blockInfo.denCoeffFL=-1*blockInfo.denCoeffs.FractionLength;
        blockInfo.denCoeffOrigFL=blockInfo.denCoeffFL;

        blockInfo.sectionDataType=blockInfo.OutputDataType;
        blockInfo.sectionTypeSign=strcmp(blockInfo.sectionDataType.Signedness,'Signed');
        blockInfo.sectionTypeWL=blockInfo.sectionDataType.WordLength;
        blockInfo.sectionTypeFL=-1*blockInfo.sectionDataType.FractionLength;


        nSV=numel(blockInfo.ScaleValues);
        blockInfo.SVWL=blockInfo.ScaleValuesDataType.WordLength;
        if~strcmp(blockInfo.ScaleValuesDataType.Signedness,'Auto')
            blockInfo.SVSign=strcmp(blockInfo.ScaleValuesDataType.Signedness,'Signed');
            blockInfo.SVFL=-1*blockInfo.ScaleValuesDataType.FractionLength;
            if nSV<blockInfo.NumSections+1
                blockInfo.SVCoeffs=fi([blockInfo.ScaleValues(:);ones(blockInfo.NumSections-nSV+1,1)],blockInfo.SVSign,blockInfo.SVWL,-blockInfo.SVFL);
            else
                blockInfo.SVCoeffs=fi(blockInfo.ScaleValues(:),blockInfo.SVSign,blockInfo.SVWL,-blockInfo.SVFL);
            end
        else
            if nSV<blockInfo.NumSections+1
                blockInfo.SVCoeffs=fi([blockInfo.ScaleValues(:);ones(blockInfo.NumSections-nSV+1,1)],[],blockInfo.SVWL);
            else
                blockInfo.SVCoeffs=fi(blockInfo.ScaleValues(:),[],blockInfo.SVWL);
            end
            blockInfo.SVSign=blockInfo.SVCoeffs.Signed;
            blockInfo.SVFL=-1*blockInfo.SVCoeffs.FractionLength;
        end
        blockInfo.accumTypeSign=blockInfo.AccumulatorDataType.SignednessBool;
        blockInfo.accumTypeWL=blockInfo.AccumulatorDataType.WordLength;
        blockInfo.accumTypeFL=-1*blockInfo.AccumulatorDataType.FractionLength;

        if strcmpi(blockInfo.Structure,'Pipelined feedback form')
            [no,nm,nno,do,~]=dsphdlpipebiquadcoeffs(blockInfo.Numerator,blockInfo.Denominator,blockInfo.ScaleValues,...
            blockInfo.PipeLevel,blockInfo.FrameSize);
            blockInfo.PipeNumerator=no;
            blockInfo.PipeNumeratorMap=nm;
            blockInfo.PipeNewNumerator=nno;
            blockInfo.PipeDenominator=do;
            if strcmp(get_param(hBlock,'DenominatorDataTypeStr'),'Inherit: Same word length as input')
                tempdo=fi(do(:,2:end),1,inputWL);
                blockInfo.denCoeffFL=-1*tempdo.FractionLength;
            else

                denDTResolved=this.hdlslResolve('DenominatorDataTypeStr',hBlock);
                if ischar(denDTResolved)&&strcmp(denDTResolved,'Inherit: Same word length as input')
                    tempdo=fi(do(:,2:end),1,inputWL);
                    blockInfo.denCoeffFL=-1*tempdo.FractionLength;
                end
            end
        else
            blockInfo.PipeNumerator=[];
            blockInfo.PipeNumeratorMap=[];
            blockInfo.PipeNewNumerator=[];
            blockInfo.PipeDenominator=[];
        end
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
