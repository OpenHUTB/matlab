function addCharacteristics_addToPlot(modelName,addFlag)



    ds=ee.internal.mask.getSimscapeBlockDatasetFromModel(modelName);
    blockName=[modelName,'/Characteristics'];

    terminals=ds.getTabulatedDataFromSymbol('term');
    referenceTerminal=ds.getTabulatedDataFromSymbol('ref');
    stimulusTerminals=setdiff(terminals,referenceTerminal,'stable');
    if length(terminals)==length(stimulusTerminals)
        pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_ReferenceTerminalMustBeInTheListOfTerminals')));
    end
    if length(stimulusTerminals)+1~=length(terminals)
        pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_AtMostOneReferenceTerminalCanExistInTheListOfTerminals')));
    end

    index=get_param(blockName,'characteristicIndex');
    if exist(index,'var')
        index=eval(index);
    else
        index=str2num(index);%#ok<ST2NM>
    end
    if any(index<=0)||any(mod(index,1))||isempty(index)||~isnumeric(index)
        pm_error('physmod:ee:library:PositiveInteger',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_CharacteristicIndex')));
    end
    if index>length(ds.characteristicData)+1
        pm_warning('physmod:ee:library:ParameterWarning',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:warning_GivenPlotNumberRequiresInsertionOfABlankPlot')));
    end
    for ii=(length(ds.characteristicData)+1):index
        ds.addCharacteristic(simscapeCharacteristic);
    end

    if~addFlag
        for ii=1:length(ds.characteristicData(index).curves)
            ds.characteristicData(index).deleteCurve(1);
        end
    end

    charType=get_param(blockName,'targetOrSimulatedData');
    stepVals=value(ee.internal.mask.getParamWithUnit(blockName,'stepValues'),'1');
    if~isvector(stepVals)||length(stepVals)<1||isempty(stepVals)||~isnumeric(index)
        pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_StepValuesMustContainAtLeastOneNumericPoint')));
    end
    if length(unique(stepVals))~=length(stepVals)
        pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingOrDescendingVec',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_StepValues')));
    end
    if strcmp(charType,'Target only')||strcmp(charType,'Target and simulated')
        outputVals=value(ee.internal.mask.getParamWithUnit(blockName,'outputValues'),'1');
        sweepVals=value(ee.internal.mask.getParamWithUnit(blockName,'sweepValues'),'1');
        if size(outputVals,2)~=length(sweepVals)||size(outputVals,1)~=length(stepVals)
            pm_error('physmod:ee:library:MatrixWrongDimension',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_OutputValues')));
        end
        if isempty(outputVals)||~isnumeric(outputVals)
            pm_error('physmod:ee:library:NotNumeric',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_OutputValues')));
        end
        if isempty(sweepVals)||~isnumeric(sweepVals)
            pm_error('physmod:ee:library:NotNumeric',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_SweepValues')));
        end
    elseif strcmp(charType,'Simulated only')
        sweepVals=value(ee.internal.mask.getParamWithUnit(blockName,'sweepRange'),'1');
        if isempty(sweepVals)||~isnumeric(sweepVals)
            pm_error('physmod:ee:library:NotNumeric',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_SweepRange')));
        end
    else
        pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_CharacteristicType')));
    end
    if~isvector(sweepVals)||length(sweepVals)<=1
        pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThan',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_SweepValues')),'1');
    end
    if length(unique(sweepVals))~=length(sweepVals)
        pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingOrDescendingVec',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_SweepValues')));
    end

    sweepTyp=get_param(blockName,'sweepType');
    stepTyp=get_param(blockName,'stepType');
    outputTyp=get_param(blockName,'outputType');
    if strcmp(sweepTyp,stepTyp)
        pm_error('physmod:simscape:compiler:patterns:checks:NotEqual',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_SweepType')),getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_StepType')));
    end
    if strcmp(sweepTyp,outputTyp)
        pm_error('physmod:simscape:compiler:patterns:checks:NotEqual',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_SweepType')),getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_OutputType')));
    end
    if strcmp(stepTyp,outputTyp)
        pm_error('physmod:simscape:compiler:patterns:checks:NotEqual',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_StepType')),getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_OutputType')));
    end
    termType=cell(1,length(terminals));
    for ii=1:length(termType)
        if strcmpi(terminals{ii},referenceTerminal)
            termType{ii}='reference';
        else
            termType{ii}='';
        end
    end
    for ii=1:length(stepVals)
        stimulus=cell(1,length(stimulusTerminals));

        [stimtyp,nodeinfo]=strtok(sweepTyp,'_');
        if ismember(referenceTerminal,nodeinfo(2:end))
            nodename=setdiff(nodeinfo(2:end),referenceTerminal,'stable');
        end
        if length(nodename)~=1
            pm_error('physmod:simscape:compiler:patterns:checks:LengthEqual',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_SweptStimulusNode')),'1');
        end
        termIndex=find(strcmpi(nodename,terminals),1);
        stimIndex=find(strcmpi(nodename,stimulusTerminals),1);
        switch stimtyp
        case 'V'
            termType{termIndex}='voltage';
            stimulus{stimIndex}=sweepVals;
        case 'I'
            termType{termIndex}='current';
            stimulus{stimIndex}=sweepVals;
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_SweepType')));
        end

        [stimtyp,nodeinfo]=strtok(stepTyp,'_');
        if ismember(referenceTerminal,nodeinfo(2:end))
            nodename=setdiff(nodeinfo(2:end),referenceTerminal,'stable');
        end
        if length(nodename)~=1
            pm_error('physmod:simscape:compiler:patterns:checks:LengthEqual',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_SteppedStimulusNode')),'1');
        end
        termIndex=find(strcmpi(nodename,terminals),1);
        stimIndex=find(strcmpi(nodename,stimulusTerminals),1);
        switch stimtyp
        case 'V'
            termType{termIndex}='voltage';
            stimulus{stimIndex}=stepVals(ii);
        case 'I'
            termType{termIndex}='current';
            stimulus{stimIndex}=stepVals(ii);
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_StepType')));
        end

        for jj=1:length(termType)
            if isempty(termType{jj})
                pm_error('physmod:ee:library:RelatedMaskParameters',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_SweepTypeAndStepTypeMustCorrespondToDifferentNonreference')));
            end
        end

        [stimtyp,nodeinfo]=strtok(outputTyp,'_');
        if ismember(referenceTerminal,nodeinfo(2:end))
            nodename=setdiff(nodeinfo(2:end),referenceTerminal,'stable');
        else
            nodename=nodeinfo(2:end);
        end
        switch stimtyp
        case 'V'
            output='voltage';
            if length(nodename)~=1
                pm_error('physmod:simscape:compiler:patterns:checks:LengthEqual',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_VoltageOutputNode')),'1');
            end
            termIndex=find(strcmpi(nodename,terminals),1);
            outputTerm=termIndex;
        case 'I'
            output='current';
            if length(nodename)~=1
                pm_error('physmod:simscape:compiler:patterns:checks:LengthEqual',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_CurrentOutputNode')),'1');
            end
            termIndex=find(strcmpi(nodename,terminals),1);
            outputTerm=termIndex;
        case 'C'
            output='capacitance';
            if length(nodename)~=2
                pm_error('physmod:simscape:compiler:patterns:checks:LengthEqual',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_CapacitanceOutputNode')),'2');
            end
            termIndex=[find(strcmpi(nodename(1),terminals),1),find(strcmpi(nodename(2),terminals),1,'last')];
            outputTerm=termIndex;
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_StepType')));
        end
        if strcmp(charType,'Target only')||strcmp(charType,'Target and simulated')
            ds.characteristicData(index).addCurve(simscapeTargetCurve(termType,stimulus,output,outputTerm,outputVals(ii,:)));
            if strcmp(charType,'Target and simulated')
                componentPath=ds.getTabulatedDataFromSymbol('model');
                switch componentPath
                case{'ee.semiconductors.sp_nmos',''}
                    ds.characteristicData(index).addCurve(simscapeSimulatedSpNmosCurve(termType,stimulus,output,outputTerm,ds.parameters));
                case 'ee.semiconductors.sp_pmos'
                    ds.characteristicData(index).addCurve(simscapeSimulatedSpPmosCurve(termType,stimulus,output,outputTerm,ds.parameters));
                otherwise
                    pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_SupportedCurveType')));
                end
            end
        else
            componentPath=ds.getTabulatedDataFromSymbol('model');
            switch componentPath
            case{'ee.semiconductors.sp_nmos',''}
                ds.characteristicData(index).addCurve(simscapeSimulatedSpNmosCurve(termType,stimulus,output,outputTerm,ds.parameters));
            case 'ee.semiconductors.sp_pmos'
                ds.characteristicData(index).addCurve(simscapeSimulatedSpPmosCurve(termType,stimulus,output,outputTerm,ds.parameters));
            otherwise
                pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:addCharacteristics_addToPlot:error_SupportedCurveType')));
            end
        end
    end
end