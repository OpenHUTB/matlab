function list=getPropList(h,filterName)




    switch filterName
    case 'all'
        list=LocAllProps(h);
    case 'sim'
        list={'StartTime'
'StopTime'
'Solver'
'RelTol'
'AbsTol'
'Refine'
'MaxStep'
'InitialStep'
'FixedStep'
'MaxOrder'
'MaxConsecutiveZCs'
'ConsecutiveZCsStepRelTol'
'OutputOption'
'OutputTimes'
'LoadExternalInput'
'ExternalInput'
'SaveTime'
'TimeSaveName'
'SaveState'
'StateSaveName'
'SaveOutput'
'OutputSaveName'
'LoadInitialState'
'InitialState'
'SaveFinalState'
'FinalStateName'
'Decimation'
'AlgebraicLoopMsg'
'MinStepSizeMsg'
'MaxConsecutiveZCsMsg'
'UnconnectedInputMsg'
'UnconnectedOutputMsg'
'UnconnectedLineMsg'
'ConsistencyChecking'
'ZeroCross'
'ZeroCrossAlgorithm'
'ZcThreshold'
'ShapePreserveControl'
        };

    case 'paper'
        list=LocFilterList(LocAllProps(h),'Paper');
    case 'ext'
        list=LocFilterList(LocAllProps(h),'ExtMode');
    case 'rtw'
        list=LocFilterList(LocAllProps(h),'RTW');
    case 'fcn'
        list=LocFilterList(LocAllProps(h),'Fcn',true);
    case 'main'
        list={
'Name'
'FileName'
'Created'
'Creator'
'Description'
'Tag'
'Version'
'Blocks'
'Signals'
        };
    case 'version'
        list={
'Created'
'Creator'
'UpdateHistory'
'ModifiedByFormat'
'ModifiedBy'
'LastModifiedBy'
'ModifiedDateFormat'
'ModifiedDate'
'LastModifiedDate'
'ModifiedComment'
'ModifiedHistory'
'ModelVersionFormat'
'ModelVersion'
'ConfigurationManager'
        };
    case 'rtwsummary'
        list={
'NumModelInputs'
'NumModelOutputs'
'NumNonVirtBlocksInModel'
'NumBlockTypeCounts'
'NumVirtualSubsystems'
'NumNonvirtSubsystems'
'DirectFeedthrough'
'NumContStates'
'ZCFindingDisabled'
'NumNonsampledZCs'
'NumZCEvents'
'NumDataStoreElements'
'NumBlockSignals'
'NumBlockParams'
'NumAlgebraicLoops'
'InvariantConstants'
        };
    otherwise
        list={};
    end


    function filtered=LocFilterList(unfiltered,spec,compareEnd)




        listBlock=strvcat(unfiltered{:});
        if nargin>2&compareEnd
            listBlock=strjust(listBlock(:,end:-1:1),'left');
            spec=spec(:,end:-1:1);
        end

        okIndices=strmatch(spec,listBlock);
        filtered=unfiltered(okIndices);


        function propNames=LocAllProps(h)


            persistent PROPSRC_ALL_MODEL_PROPERTIES

            if isempty(PROPSRC_ALL_MODEL_PROPERTIES)
                PROPSRC_ALL_MODEL_PROPERTIES=sort([
                h.getAllGettableProperties
                h.getPropList('rtwsummary')
                ]);
            end

            propNames=PROPSRC_ALL_MODEL_PROPERTIES;

