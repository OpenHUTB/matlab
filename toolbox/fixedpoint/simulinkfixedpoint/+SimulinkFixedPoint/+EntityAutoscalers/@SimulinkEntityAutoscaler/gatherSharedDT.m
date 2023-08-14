function sharedLists=gatherSharedDT(h,blkObj)




    sharedLists={};

    sharedSamePortSrc=hShareSrcAtSamePort(h,blkObj);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedSamePortSrc);

    sharedAllPorts=shareDataForSpecificPorts(h,isBlocksRequireSameDtAllPorts(blkObj),-1,-1);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedAllPorts);

    sharedFirstInOutput=shareDataForSpecificPorts(h,isBlocksRequireSameDtFirstInputOutput(blkObj),1,1);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedFirstInOutput);

    sharedAllInput=shareDataForSpecificPorts(h,isBlocksRequireSameDtAllInput(blkObj),-1,[]);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedAllInput);

    sharedSecondToEnd=shareDataForSpecificPorts(h,isBlocksRequireSameDtInput2ndToEnd(blkObj),'2:end',[]);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedSecondToEnd);

    sameDatatype=sameDataTypeForSpecificPorts(h,blkObj);
    sharedLists=h.hAppendToSharedLists(sharedLists,sameDatatype);

    sharedParams=shareDataTypeWithParameter(h,blkObj);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedParams);

    sharedParams=SimulinkFixedPoint.AutoscalerUtils.shareDataTypeWithSigObj(h,blkObj);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedParams);


    function sharedListPorts=shareDataForSpecificPorts(h,blk,inportSet,outportSet)

        sharedListPorts='';

        if~isempty(blk)

            sharedListPorts=h.hShareDTSpecifiedPorts(blk,inportSet,outportSet);
        end


        function sharedParams=shareDataTypeWithParameter(h,blk)

            sharedParams={};

            if isa(blk,'Simulink.Gain')
                if strcmp(blk.paramDataTypeStr,'Inherit: Same as input')
                    sharedListPorts=h.hShareDTSpecifiedPorts(blk,1,[]);
                    if~isempty(sharedListPorts)
                        sharedParams=sharedListPorts;

                        paramRec.blkObj=blk;
                        paramRec.pathItem='Gain';
                        sharedParams{end+1}=paramRec;
                    end
                end
            end


            if isa(blk,'Simulink.DiscreteFir')||isa(blk,'Simulink.AllpoleFilter')

                if strcmp(blk.StateDataTypeStr,'Inherit: Same as input')
                    sharedParamsState={};
                    sharedListPorts=h.hShareDTSpecifiedPorts(blk,1,[]);
                    if~isempty(sharedListPorts)
                        sharedParamsState=sharedListPorts;
                        paramRec.blkObj=blk;
                        paramRec.pathItem='States';
                        sharedParamsState{end+1}=paramRec;
                    end

                    if~isempty(sharedParamsState)
                        sharedParams{end+1}=sharedParamsState;
                    end
                end


                if ismember('States',h.getPathItems(blk))&&...
                    strcmp(blk.StateDataTypeStr,'Inherit: Same as accumulator')
                    paramRec1.blkObj=blk;
                    paramRec1.pathItem='Accumulator';
                    paramRec2.blkObj=blk;
                    paramRec2.pathItem='States';
                    sharedParamsState={paramRec1,paramRec2};
                    sharedParams{end+1}=sharedParamsState;
                end


                if strcmp(blk.ProductDataTypeStr,'Inherit: Same as input')
                    sharedParamsProduct={};
                    sharedListPorts=h.hShareDTSpecifiedPorts(blk,1,[]);
                    if~isempty(sharedListPorts)
                        sharedParamsProduct=sharedListPorts;
                        paramRec.blkObj=blk;
                        paramRec.pathItem='Product output';
                        sharedParamsProduct{end+1}=paramRec;
                    end
                    if~isempty(sharedParamsProduct)
                        sharedParams{end+1}=sharedParamsProduct;
                    end
                end
                if strcmp(blk.AccumDataTypeStr,'Inherit: Same as product output')
                    sharedParamsAccum={};
                    sharedParamsAccum{1}.blkObj=blk;
                    sharedParamsAccum{1}.pathItem='Product output';
                    sharedParamsAccum{2}.blkObj=blk;
                    sharedParamsAccum{2}.pathItem='Accumulator';
                    sharedParams{end+1}=sharedParamsAccum;
                elseif strcmp(blk.AccumDataTypeStr,'Inherit: Same as input')
                    sharedParamsAccum={};
                    sharedListPorts=h.hShareDTSpecifiedPorts(blk,1,[]);
                    if~isempty(sharedListPorts)
                        sharedParamsAccum=sharedListPorts;
                        paramRec.blkObj=blk;
                        paramRec.pathItem='Accumulator';
                        sharedParamsAccum{end+1}=paramRec;
                    end
                    if~isempty(sharedParamsAccum)
                        sharedParams{end+1}=sharedParamsAccum;
                    end
                end
            end

            if isa(blk,'Simulink.DiscreteFilter')||isa(blk,'Simulink.DiscreteTransferFcn')

                if strcmp(blk.InitialStatesSource,'Dialog')&&...
                    ~strcmp(blk.FilterStructure,'Direct form I')&&...
                    strcmp(blk.StateDataTypeStr,'Inherit: Same as input')
                    sharedParamsState={};
                    sharedListPorts=h.hShareDTSpecifiedPorts(blk,1,[]);
                    if~isempty(sharedListPorts)
                        sharedParamsState=sharedListPorts;
                        paramRec.blkObj=blk;
                        paramRec.pathItem='States';
                        sharedParamsState{end+1}=paramRec;
                    end

                    if~isempty(sharedParamsState)
                        sharedParams{end+1}=sharedParamsState;
                    end
                end
                if strcmp(blk.InitialStatesSource,'Input port')

                    inputIndex=2+strcmp(blk.NumeratorSource,'Input port')+...
                    strcmp(blk.DenominatorSource,'Input port')+...
                    ~strcmp(blk.ExternalReset,'None');
                    sharedParamsState={};
                    sharedListPorts=h.hShareDTSpecifiedPorts(blk,inputIndex,[]);
                    if~isempty(sharedListPorts)
                        sharedParamsState=sharedListPorts;
                        paramRec.blkObj=blk;
                        paramRec.pathItem='States';
                        sharedParamsState{end+1}=paramRec;
                    end

                    if~isempty(sharedParamsState)
                        sharedParams{end+1}=sharedParamsState;
                    end
                end
                if strcmp(blk.NumProductDataTypeStr,'Inherit: Same as input')
                    sharedParamsNumProduct={};
                    sharedListPorts=h.hShareDTSpecifiedPorts(blk,1,[]);
                    if~isempty(sharedListPorts)
                        sharedParamsNumProduct=sharedListPorts;
                        paramRec.blkObj=blk;
                        paramRec.pathItem='Numerator product output';
                        sharedParamsNumProduct{end+1}=paramRec;
                    end
                    if~isempty(sharedParamsNumProduct)
                        sharedParams{end+1}=sharedParamsNumProduct;
                    end
                end
                if strcmp(blk.NumAccumDataTypeStr,'Inherit: Same as product output')
                    sharedParamsNumAccum={};
                    sharedParamsNumAccum{1}.blkObj=blk;
                    sharedParamsNumAccum{1}.pathItem='Numerator product output';
                    sharedParamsNumAccum{2}.blkObj=blk;
                    sharedParamsNumAccum{2}.pathItem='Numerator accumulator';
                    sharedParams{end+1}=sharedParamsNumAccum;
                elseif strcmp(blk.NumAccumDataTypeStr,'Inherit: Same as input')
                    sharedParamsNumAccum={};
                    sharedListPorts=h.hShareDTSpecifiedPorts(blk,1,[]);
                    if~isempty(sharedListPorts)
                        sharedParamsNumAccum=sharedListPorts;
                        paramRec.blkObj=blk;
                        paramRec.pathItem='Numerator accumulator';
                        sharedParamsNumAccum{end+1}=paramRec;
                    end
                    if~isempty(sharedParamsNumAccum)
                        sharedParams{end+1}=sharedParamsNumAccum;
                    end
                end

                if strcmp(blk.DenProductDataTypeStr,'Inherit: Same as input')
                    sharedParamsDenProduct={};
                    sharedListPorts=h.hShareDTSpecifiedPorts(blk,1,[]);
                    if~isempty(sharedListPorts)
                        sharedParamsDenProduct=sharedListPorts;
                        paramRec.blkObj=blk;
                        paramRec.pathItem='Denominator product output';
                        sharedParamsDenProduct{end+1}=paramRec;
                    end
                    if~isempty(sharedParamsDenProduct)
                        sharedParams{end+1}=sharedParamsDenProduct;
                    end
                end
                if strcmp(blk.DenAccumDataTypeStr,'Inherit: Same as product output')
                    sharedParamsDenAccum={};
                    sharedParamsDenAccum{1}.blkObj=blk;
                    sharedParamsDenAccum{1}.pathItem='Denominator product output';
                    sharedParamsDenAccum{2}.blkObj=blk;
                    sharedParamsDenAccum{2}.pathItem='Denominator accumulator';
                    sharedParams{end+1}=sharedParamsDenAccum;
                elseif strcmp(blk.DenAccumDataTypeStr,'Inherit: Same as input')
                    sharedParamsDenAccum={};
                    sharedListPorts=h.hShareDTSpecifiedPorts(blk,1,[]);
                    if~isempty(sharedListPorts)
                        sharedParamsDenAccum=sharedListPorts;
                        paramRec.blkObj=blk;
                        paramRec.pathItem='Denominator accumulator';
                        sharedParamsDenAccum{end+1}=paramRec;
                    end
                    if~isempty(sharedParamsDenAccum)
                        sharedParams{end+1}=sharedParamsDenAccum;
                    end
                end

                if isa(blk,'Simulink.DiscreteFilter')
                    if strcmp(blk.MultiplicandDataTypeStr,'Inherit: Same as input')
                        sharedParamsMultiplicand={};
                        sharedListPorts=h.hShareDTSpecifiedPorts(blk,1,[]);
                        if~isempty(sharedListPorts)
                            sharedParamsMultiplicand=sharedListPorts;
                            paramRec.blkObj=blk;
                            paramRec.pathItem='Multiplicand';
                            sharedParamsMultiplicand{end+1}=paramRec;
                        end
                        if~isempty(sharedParamsMultiplicand)
                            sharedParams{end+1}=sharedParamsMultiplicand;
                        end
                    end
                end
            end

            if isa(blk,'Simulink.Probe')
                if strcmp(blk.ProbeWidth,'on')&&strcmp(blk.ProbeWidthDataType,'Same as input')
                    paramRec.blkObj=blk;
                    paramRec.pathItem='Width';
                    sharedParams{end+1}=paramRec;
                end
                if strcmp(blk.ProbeSampleTime,'on')&&strcmp(blk.ProbeSampleTimeDataType,'Same as input')
                    paramRec.blkObj=blk;
                    paramRec.pathItem='SampleTime';
                    sharedParams{end+1}=paramRec;
                end
                if strcmp(blk.ProbeComplexSignal,'on')&&strcmp(blk.ProbeComplexityDataType,'Same as input')
                    paramRec.blkObj=blk;
                    paramRec.pathItem='SignalComplex';
                    sharedParams{end+1}=paramRec;
                end
                if strcmp(blk.ProbeSignalDimensions,'on')&&strcmp(blk.ProbeDimensionsDataType,'Same as input')
                    paramRec.blkObj=blk;
                    paramRec.pathItem='SignalDimension';
                    sharedParams{end+1}=paramRec;
                end
                if strcmp(blk.ProbeFramedSignal,'on')&&strcmp(blk.ProbeFrameDataType,'Same as input')
                    paramRec.blkObj=blk;
                    paramRec.pathItem='SignalFrame';
                    sharedParams{end+1}=paramRec;
                end
                if~isempty(sharedParams)
                    sharedListPorts=hShareDTSpecifiedPorts(h,blk,1,[]);
                    sharedParams=[sharedParams,sharedListPorts];
                end
            end


            function sharedListPorts=sameDataTypeForSpecificPorts(h,blk)

                sharedListPorts={};

                switch class(blk)
                case 'Simulink.DiscreteIntegrator'
                    if strcmp(blk.InitialConditionSource,'external')
                        sharedListPorts=h.hShareDTSpecifiedPorts(blk,2,1);
                    end
                    return;
                case 'Simulink.Assignment'
                    if isempty(regexp(blk.IndexOptions,'(port)','ONCE'))
                        sharedListPorts=h.hShareDTSpecifiedPorts(blk,-1,-1);
                        return;
                    end
                    if strcmp(blk.OutputInitialize,'Initialize using input port <Y0>')

                        sharedListPorts=h.hShareDTSpecifiedPorts(blk,[1,2],1);
                    else

                        sharedListPorts=h.hShareDTSpecifiedPorts(blk,1,1);
                    end

                case 'Simulink.SFunction'
                    if strcmpi(blk.MaskType,'Lookup Table Dynamic')


                        sharedListPorts=h.hShareDTSpecifiedPorts(blk,[1,2],[]);
                    end
                otherwise
                    return;
                end


                function isAllPorts=isBlocksRequireSameDtAllPorts(blk)


                    searchPairSets={
                    {'MaskType','Bitwise Operator'}
                    {'MaskType','Tapped Delay Line'}
                    {'BlockType','Bias'}
                    {'BlockType','UnaryMinus'}


                    {'BlockType','ComplexToRealImag'}
                    {'BlockType','RealImagToComplex'}
                    {'BlockType','InitialCondition'}
                    {'BlockType','DeadZone'}
                    {'BlockType','RateLimiter'}

                    {'BlockType','Squeeze'}

                    {'BlockType','Saturate','OutDataTypeStr','Inherit: Same as input'}
                    {'BlockType','Relay','OutputDataTypeStr','Inherit: All ports same datatype'}
                    {'BlockType','Gain','OutDataTypeStr','Inherit: Same as input'}
                    {'BlockType','DiscreteFir','OutDataTypeStr','Inherit: Same as input'}
                    {'BlockType','AllpoleFilter','OutDataTypeStr','Inherit: Same as input'}

                    {'BlockType','Abs','OutDataTypeStr','Inherit: Same as input'}
                    {'BlockType','MinMax','InputSameDT','on','OutDataTypeStr','Inherit: Inherit via internal rule'}

                    {'BlockType','Math','Operator','conj'}
                    {'BlockType','Math','Operator','transpose'}
                    {'BlockType','Math','Operator','hermitian'}

                    {'BlockType','Math','Operator','magnitude^2','OutDataTypeStr','Inherit: Same as first input'}
                    {'BlockType','Math','Operator','square','OutDataTypeStr','Inherit: Same as first input'}
                    {'BlockType','Math','Operator','sqrt','OutDataTypeStr','Inherit: Same as first input'}
                    {'BlockType','Math','Operator','reciprocal','OutDataTypeStr','Inherit: Same as first input'}

                    {'BlockType','Logic','AllPortsSameDT','on'}
                    {'BlockType','Mux'}

                    {'BlockType','Concatenate'}
                    {'BlockType','Reshape'}
                    {'BlockType','PermuteDimensions'}

                    {'BlockType','BusToVector'}

                    {'BlockType','ForEachSliceSelector'}
                    {'BlockType','ForEachSliceAssignment'}

                    {'BlockType','Width','OutDataTypeMode','All ports same datatype'}


                    };

                    isAllPorts=searchPairs2Blk(blk,searchPairSets);


                    function isFirstInOut=isBlocksRequireSameDtFirstInputOutput(blk)


                        searchPairSets={

                        {'BlockType','Selector'}


                        {'BlockType','Sum','OutDataTypeStr','Inherit: Same as first input'}
                        {'BlockType','DotProduct','OutDataTypeStr','Inherit: Same as first input'}
                        {'BlockType','Sqrt','OutDataTypeStr','Inherit: Same as first input'}
                        {'BlockType','DiscreteFilter','OutDataTypeStr','Inherit: Same as input'}
                        {'BlockType','DiscreteTransferFcn','OutDataTypeStr','Inherit: Same as input'}


                        };

                        isFirstInOut=searchPairs2Blk(blk,searchPairSets);


                        function isAllInput=isBlocksRequireSameDtAllInput(blk)


                            searchPairSets={
                            {'BlockType','RelationalOperator','InputSameDT','on'}
                            {'BlockType','Sum','InputSameDT','on'}
                            {'BlockType','DotProduct','InputSameDT','on'}
                            {'BlockType','MinMax','InputSameDT','on'}
                            {'BlockType','Math','Operator','mod'}
                            {'BlockType','Math','Operator','rem'}
                            {'BlockType','Trigonometry','Operator','atan2'}
                            };

                            isAllInput=searchPairs2Blk(blk,searchPairSets);


                            function isToEnd=isBlocksRequireSameDtInput2ndToEnd(blk)


                                searchPairSets={
                                {'BlockType','MultiPortSwitch','InputSameDT','on'}
                                };

                                isToEnd=searchPairs2Blk(blk,searchPairSets);


                                function existBlk=searchPairs2Blk(blk,searchPairSets)


                                    existBlk=[];
                                    ss=[searchPairSets{:}];
                                    if any(strcmp(blk.BlockType,ss))||...
                                        any(strcmp(blk.MaskType,ss))
                                        for i=1:length(searchPairSets)
                                            existBlk=find(blk,searchPairSets{i});
                                            if~isempty(existBlk)
                                                break;
                                            end
                                        end
                                    end




