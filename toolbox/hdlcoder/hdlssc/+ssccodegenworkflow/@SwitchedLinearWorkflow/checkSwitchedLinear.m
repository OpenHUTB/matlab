function checkSwitchedLinear(obj)



    listOfSwitches={};

    simscapeModel=obj.SimscapeModel;

    try





        [simscapeSF,simscapeSFInputs,simscapeSFOutputs,solverPaths]=utilGetSimscapeSF(simscapeModel);




        if isempty(simscapeSF)

            me=MException('checkSwitchedLinear:NoSSCNetworks',...
            message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:NoSSCNetworks',simscapeModel).getString);
            throwAsCaller(me);
        else

            discData=cell(1,numel(simscapeSF));
            psBlockData=cell(1,numel(simscapeSF));
            evData={};
            spsLinkBlockData={};
            atomicSubsystemData={};
            referencedSubsystemData={};
            spsFilterData={};
            pssUnitData={};
            nonlinearBlockData={};

            obj.linearizationInfo=repmat(struct,numel(simscapeSF),1);
            inputs=cell(1,numel(simscapeSF));
            outputs=cell(1,numel(simscapeSF));
            dynamicSystems=cell(1,numel(simscapeSF));
            if obj.SolverTypes(1)

                simscape.engine.sli.sl.swldaemon('STOP')
                simscape.engine.sli.sl.swldaemon('START')


                stopDeamon=onCleanup(@()simscape.engine.sli.sl.swldaemon('STOP'));
            else

                simscape.engine.sli.sl.daemon('STOP');

                consistent_only=false;

                simscape.engine.sli.sl.daemon('START',consistent_only);
                stopDeamon=onCleanup(@()simscape.engine.sli.sl.daemon('STOP'));



                commonArgs={'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','all','FollowLinks','on'};
                CounterBlocks=find_system(simscapeModel,commonArgs{:},'ReferenceBlock','fl_lib/Physical Signals/Sources/PS Counter');
                RandomBlocks=find_system(simscapeModel,commonArgs{:},'ReferenceBlock','fl_lib/Physical Signals/Sources/PS Random Number');
                RepSeqBlocks=find_system(simscapeModel,commonArgs{:},'ReferenceBlock','fl_lib/Physical Signals/Sources/PS Repeating Sequence');
                UniformRandBlocks=find_system(simscapeModel,commonArgs{:},'ReferenceBlock','fl_lib/Physical Signals/Sources/PS Uniform Random Number');

                SourceBlocks=[CounterBlocks;RandomBlocks;RepSeqBlocks;UniformRandBlocks];


                if~isempty(SourceBlocks)

                    SourceBlocks=unique(SourceBlocks);
                    obj.SourceBlocks=SourceBlocks;

                    me=MException('checkSwitchedLinear:Source',...
                    message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:SourceBlocks').getString);
                    throwAsCaller(me);
                end

            end
            if iscell(simscapeSF)
                for i=1:numel(simscapeSF)
                    dynamicSystem=utilGetDynamicSystem(simscapeSF{i},simscapeSFInputs{i},simscapeSFOutputs{i},solverPaths{i});
                    inputs{i}=simscapeSFInputs{i};
                    outputs{i}=simscapeSFOutputs{i};
                    dynamicSystems{i}=dynamicSystem;
                end
            else
                dynamicSystems{1}=utilGetDynamicSystem(simscapeSF,simscapeSFInputs,simscapeSFOutputs,solverPaths);
                inputs{1}=simscapeSFInputs;
                outputs{1}=simscapeSFOutputs;
            end

            obj.DynamicSystemObj=dynamicSystems;

            obj.NumberOfDifferentialVariables=obj.NumberOfDifferentialVariables.*ones(1,numel(simscapeSF));



            SinkBlocks=find_system(simscapeModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','SimscapeProbe');
            if~isempty(SinkBlocks)


                obj.SinkBlocks=SinkBlocks;

                me=MException('checkSwitchedLinear:Sink',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:SinkBlocks').getString);
                throwAsCaller(me);
            end




            MultiBodyNetwork=find_system(simscapeModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','SimscapeMultibodyBlock');
            if~isempty(MultiBodyNetwork)

                MultiBodyNetwork=unique(MultiBodyNetwork);
                obj.MulitBodyBlocks=MultiBodyNetwork;

                me=MException('checkSwitchedLinear:Mulitbody',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:MulitbodySSCModel').getString);
                throwAsCaller(me);
            end





            forEachBlocks=find_system(simscapeModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','ForEach');
            for ii=1:numel(forEachBlocks)
                parentPath=get_param(forEachBlocks(ii),'Parent');


                solverConfigBlock=find_system(parentPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','ReferenceBlock','nesl_utility/Solver Configuration');
                if~isempty(solverConfigBlock)

                    forEachBlocks=unique(forEachBlocks);
                    obj.ForEachBlocks=forEachBlocks;

                    me=MException('checkSwitchedLinear:ForEachBlock',...
                    message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:ForEachBlock').getString);
                    throwAsCaller(me);
                end
            end


            for i=1:numel(dynamicSystems)
                dynamicSystem=dynamicSystems{i};

                if(isempty(dynamicSystem.VariableData)&&isempty(dynamicSystem.Output))
                    me=MException('checkSwitchedLinear:noStatesOrOutputs',...
                    message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:noStatesOrOutputs',simscapeModel).getString);
                    throwAsCaller(me);
                end


                discData{i}=dynamicSystem.VariableData;


                solverSystem=NetworkEngine.SolverSystem(dynamicSystem);
                if~(solverSystem.IsMPwConstant)
                    me=MException('checkSwitchedLinear:TimeVaryingLinearBlocks',...
                    message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:TimeVaryingLinearBlocks',simscapeModel).getString);
                    throwAsCaller(me);
                end


                if(solverSystem.IsCondSwitchedLinear)||obj.SolverTypes(i)
                    nonlinearitySuitable=true;
                else



                    equationData=dynamicSystem.EquationData;

                    failedBlks={};
                    for ii=1:numel(equationData)
                        if~equationData(ii).switched_linear&&~isWhiteListed(equationData(ii))
                            failedBlks{end+1}=equationData(ii).object;%#ok<AGROW>
                        end
                    end


                    if~isempty(failedBlks)
                        failedBlks=unique(failedBlks);
                        nonlinearBlockData=[nonlinearBlockData,failedBlks];%#ok<AGROW>
                        nonlinearitySuitable=false;
                    else
                        nonlinearitySuitable=true;
                    end
                end

                if(nonlinearitySuitable)
                    [spsBlks,pssBlks]=utilGetConverterBlocks(inputs{i},outputs{i});

                    [spsBlks,pssBlks]=utilOrderConverterBlocks(dynamicSystem,inputs{i},outputs{i},spsBlks,pssBlks);
                    obj.spsBlks{i}=spsBlks;
                    psBlockData{i}=[spsBlks,pssBlks];






                    [linkedSubsystems,atomicSubsystems,referencedSubsystems,spsFilters,pssUnit]=...
                    utilCheckConverterBlocks(spsBlks,pssBlks,obj.SolverTypes(i));

                    if~isempty(linkedSubsystems)
                        spsLinkBlockData=[spsLinkBlockData;linkedSubsystems];%#ok<AGROW>
                    end

                    if~isempty(atomicSubsystems)
                        atomicSubsystemData=[atomicSubsystemData;atomicSubsystems];%#ok<AGROW>
                    end

                    if~isempty(referencedSubsystems)
                        referencedSubsystemData=[referencedSubsystemData,referencedSubsystems];%#ok<AGROW>
                    end
                    if~isempty(spsFilters)
                        spsFilterData=[spsFilterData,spsFilters];%#ok<AGROW>
                    end
                    if~isempty(pssUnit)
                        pssUnitData=[pssUnitData,pssUnit];%#ok<AGROW>
                    end

                    equationData=dynamicSystem.EquationData;

                    switches{i}={};%#ok<AGROW>
                    diodes{i}={};%#ok<AGROW>
                    IGBTs{i}={};%#ok<AGROW>
                    nlInductors{i}={};%#ok<AGROW>
                    for equationNum=1:numel(equationData)
                        equation=equationData(equationNum);
                        if(equation.object)
                            refBlock=get_param(equation.object,'ReferenceBlock');
                            switch sprintf(refBlock)
                            case sprintf('fl_lib/Electrical/Electrical Elements/Switch')
                                if isempty(switches{i})||~any(ismember(switches{i}(:,1),equation.object))
                                    switches{i}=[switches{i};{equation.object,'Switch',i}];
                                end
                            case sprintf('fl_lib/Electrical/Electrical Elements/Diode')
                                if isempty(diodes{i})||~any(ismember(diodes{i}(:,1),equation.object))
                                    diodes{i}=[diodes{i};{equation.object,'Diode',i}];
                                end
                            case sprintf('ee_lib/Semiconductors &\nConverters/Diode')
                                if isempty(diodes{i})||~any(ismember(diodes{i}(:,1),{equation.object}))
                                    diodes{i}=[diodes{i};{equation.object,'Diode',i}];
                                end
                            case sprintf('ee_lib/Semiconductors &\nConverters/IGBT\n(Ideal,\nSwitching)')
                                if strcmp(get_param(equation.object,'diode_param'),'1')
                                    if isempty(IGBTs{i})||~any(ismember(IGBTs{i}(:,1),equation.object))
                                        IGBTs{i}=[IGBTs{i};{equation.object,'IGBT',i}];
                                    end
                                end
                            case sprintf('ee_lib/Passive/Nonlinear Inductor')
                                if isempty(nlInductors{i})||~any(ismember(nlInductors{i}(:,1),{equation.object}))
                                    nlInductors{i}=[nlInductors{i};{equation.object,'Nonlinear Inductor',i}];
                                end
                            end
                        end
                    end
                    listOfSwitches=[listOfSwitches;switches{i};diodes{i};IGBTs{i};nlInductors{i}];%#ok<AGROW>
                end
            end
            obj.listOfSwitches=repmat(struct,size(listOfSwitches,1),1);
            for switchNum=1:size(listOfSwitches,1)
                obj.listOfSwitches(switchNum).Name=listOfSwitches{switchNum,1};
                obj.listOfSwitches(switchNum).Type=listOfSwitches{switchNum,2};
                obj.listOfSwitches(switchNum).Approx=false;
                obj.listOfSwitches(switchNum).Rs='auto';
                obj.listOfSwitches(switchNum).NetworkNum=listOfSwitches{switchNum,3};

            end


            obj.DiscreteVariableData=discData;
            obj.SpsPssConverterBlks=psBlockData;

            if~isempty(spsLinkBlockData)

                obj.InvalidSPSBlocks=spsLinkBlockData;
                me=MException('checkSwitchedLinear:LinkedSPSBlocks',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:LinkedSPSBlocks').getString);
                throwAsCaller(me);
            end

            if~isempty(atomicSubsystemData)
                obj.InvalidSPSBlocks=atomicSubsystemData;
                me=MException('checkSwitchedLinear:AtomicSPSBlocks',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:AtomicSPSBlocks').getString);
                throwAsCaller(me);
            end

            if~isempty(referencedSubsystemData)
                obj.InvalidSPSBlocks=referencedSubsystemData;
                me=MException('checkSwitchedLinear:RefSPSBlocks',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:RefSPSBlocks').getString);
                throwAsCaller(me);
            end

            if~isempty(spsFilters)
                if obj.SolverTypes(i)
                    obj.InvalidSPSBlocks=spsFilterData;
                    me=MException('checkSwitchedLinear:FilterSPSBlocks',...
                    message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:FilterSPSBlocks').getString);
                    throwAsCaller(me);
                else
                    obj.InvalidSPSBlocks=spsFilterData;
                    me=MException('checkSwitchedLinear:FilterSPSBlocksBE',...
                    message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:FilterSPSBlocksBE').getString);
                    throwAsCaller(me);
                end
            end

            if~isempty(atomicSubsystemData)
                obj.InvalidSPSBlocks=atomicSubsystemData;
                me=MException('checkSwitchedLinear:AtomicSPSBlocks',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:AtomicSPSBlocks').getString);
                throwAsCaller(me);
            end

            if~isempty(referencedSubsystemData)
                obj.InvalidSPSBlocks=referencedSubsystemData;
                me=MException('checkSwitchedLinear:RefSPSBlocks',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:RefSPSBlocks').getString);
                throwAsCaller(me);
            end

            if~isempty(spsFilterData)
                obj.InvalidSPSBlocks=spsFilterData;
                me=MException('checkSwitchedLinear:FilterSPSBlocks',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:FilterSPSBlocks').getString);
                throwAsCaller(me);
            end


            if~nonlinearitySuitable
                obj.NonlinearBlocks=nonlinearBlockData;
                solverBlk=obj.SolverConfiguration;
                useLocalSolver=get_param(solverBlk,'UseLocalSolver');
                if strcmp(useLocalSolver,'on')
                    solverChoice=get_param(solverBlk,'LocalSolverChoice');
                    if strcmp(solverChoice,'NE_PARTITIONING_ADVANCER')
                        me=MException('checkSwitchedLinear:NonlinearSSCModel',...
                        message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:NonlinearSSCModel',simscapeModel).getString);
                    else
                        me=MException('checkSwitchedLinear:NonlinearSSCModelBE',...
                        message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:NonlinearSSCModelBE',simscapeModel).getString);
                    end
                else
                    me=MException('checkSwitchedLinear:NonlinearSSCModelBE',...
                    message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:NonlinearSSCModelBE',simscapeModel).getString);
                end

                throwAsCaller(me);
            end


            if strcmp(hdlfeature('SSCHDLAutoReplace'),'on')



                solverBlks=obj.SolverConfiguration;

                if numel(solverBlks)>numel(unique(solverBlks))
                    obj.GenerateAutomaticLayout=false;
                end
            end

        end
    catch me
        throwAsCaller(me);
    end
end



