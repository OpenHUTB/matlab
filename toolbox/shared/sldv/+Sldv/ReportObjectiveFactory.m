classdef ReportObjectiveFactory<handle








    properties(Access=private)
        Options;
        IsFixedPoint;
        IsPathBased;
    end

    methods

        function this=ReportObjectiveFactory(options)
            this.Options=options;
            this.IsFixedPoint=sldvshareprivate('util_is_analyzing_for_fixpt_tool');
            this.IsPathBased=Sldv.utils.isPathBasedTestGeneration(this.Options);
        end

        function newPathObjective=createPathObjective(this,goal,linkInfo)%#ok*<INUSD>
            if strcmpi(goal.status,'GOAL_SATISFIABLE')
                status='Satisfied';
            elseif strcmpi(goal.status,'GOAL_FALSIFIABLE')
                status='Falsified';
            else
                status=goal.statusstr;
            end



            id=goal.outIndex;

            newPathObjective=struct(...
            'id',id,...
            'label',[],...
            'detectionSites',struct([]),...
            'objectives',[],...
            'extensionObjectives',[],...
            'descr',goal.description,...
            'status',status,...
            'testCaseIdx',[],...
            'analysisTime',[],...
            'conditionIndex',goal.condIndex,...
            'goal',goal.getGoalMapId...
            );
        end

        function newObjective=createObjective(this,goal,linkInfo,rangeData,modelH)
            type='';
            outcome='n/a';
            posIdx='n/a';
            busSelElIdx='n/a';
            uo=goal.up;

            switch(goal.type)
            case 'AVT_GOAL_ASSERT'
                type='Assert';
            case 'AVT_GOAL_CUSTEST'
                type='Test objective';
            case 'AVT_GOAL_CUSPROOF'
                type='Proof objective';
            case 'AVT_GOAL_CUSBLKCOV'
                type='Block Coverage';
            case 'AVT_GOAL_OVERFLOW'
                type='Overflow';
            case 'AVT_GOAL_FLOAT_INF'
                type='Inf value';
            case 'AVT_GOAL_FLOAT_NAN'
                type='NaN value';
            case 'AVT_GOAL_FLOAT_SUBNORMAL'
                type='Subnormal value';
            case 'AVT_GOAL_DIV0'
                type='Division by zero';
            case 'AVT_GOAL_RBW_HAZARD'
                type='Read-before-write';
            case 'AVT_GOAL_WAR_HAZARD'
                type='Write-after-read';
            case 'AVT_GOAL_WAW_HAZARD'
                type='Write-after-write';
            case 'AVT_GOAL_BLOCK_INPUT_RANGE_VIOLATION'
                type='Block input range violation';
            case 'AVT_GOAL_RANGE'
                type='Range';
                outcome=goal.outIndex;
                busSelElIdx=goal.busSelElIdx;
            case 'AVT_GOAL_DESRANGE'
                type='Design Range';
                outcome=goal.outIndex;
                busSelElIdx=goal.busSelElIdx;
            case 'AVT_GOAL_TRANS_CNFCT'
                type='Transition conflict';
            case 'AVT_GOAL_STATE_CONS'
                type='State inconsistency';
            case 'AVT_GOAL_SFARRAY_BNDS'
                type='Stateflow array bounds';
            case 'AVT_GOAL_EMLARRAY_BNDS'
                type='MATLAB array bounds';
            case 'AVT_GOAL_SELECT_BNDS'
                type='Selector index bounds';
            case 'AVT_GOAL_MPSWITCH_BNDS'
                type='Multiport Switch trigger bounds';
            case 'AVT_GOAL_INVALID_CAST'
                type='Invalid cast';
            case 'AVT_GOAL_MERGE_CNFCT'
                type='Merge conflict';
            case 'AVT_GOAL_UNINIT_DSR'
                type='Uninitialized DSR';
            case 'AVT_GOAL_ARRBOUNDS'
                type='Array bounds';
            case 'AVT_GOAL_OBJECTIVE_COMPOSITION'
                type='Objective Composition';
            case 'AVT_GOAL_SFCN_COND'
                type='S-Function Condition';
                posIdx=goal.condIndex;
            case 'AVT_GOAL_SFCN_DEC'
                type='S-Function Decision';
                posIdx=goal.condIndex;
            case 'AVT_GOAL_SFCN_MCDC'
                type='S-Function MCDC';
                posIdx=goal.condIndex;
            case 'AVT_GOAL_SFCN_ENTRY'
                type='S-Function Entry';
                posIdx=goal.condIndex;
            case 'AVT_GOAL_SFCN_EXIT'
                type='S-Function Exit';
                posIdx=goal.condIndex;
            case 'AVT_GOAL_SFCN_RELATIONAL_BOUNDARIES'
                type='S-Function RelationalBoundary';
                posIdx=goal.condIndex;
            case 'AVT_GOAL_SFCN_RTE'
                type='S-Function Runtime Error';
            case 'AVT_GOAL_CODE_COND'
                type='Condition';
                posIdx=goal.condIndex;
            case 'AVT_GOAL_CODE_DEC'
                type='Decision';
                posIdx=goal.condIndex;
            case 'AVT_GOAL_CODE_MCDC'
                type='MCDC';
                posIdx=goal.condIndex;
            case 'AVT_GOAL_CODE_ENTRY'
                type='Function Entry';
                posIdx=goal.condIndex;
            case 'AVT_GOAL_CODE_EXIT'
                type='Function Exit';
                posIdx=goal.condIndex;
            case 'AVT_GOAL_CODE_RELATIONAL_BOUNDARIES'
                type='RelationalBoundary';
                posIdx=goal.condIndex;
            case 'AVT_GOAL_CODE_RTE'
                type='C/C++ Runtime Error';
            case 'AVT_GOAL_PATH_OBJECTIVE'
                type='Observability Objective';
            case 'AVT_GOAL_SUT_EXEC'
                type='Execution';
            case 'AVT_GOAL_REQTABLE'
                type='Requirements Table Objective';
            otherwise
                if sldvprivate('sldv_datamodel_isa',uo,'Condition')
                    if isequal(uo.trueGoal,goal)
                        outcome=true;
                    end
                    if isequal(uo.falseGoal,goal)
                        outcome=false;
                    end

                    posIdx=uo.idx+1;
                    type='Condition';

                elseif sldvprivate('sldv_datamodel_isa',uo,'Decision')
                    decision=uo;
                    if length(decision.goals)==2
                        if isequal(goal,decision.goals(1))
                            goalF=goal;
                            if sldvprivate('sldv_datamodel_isa',goalF,'Goal')
                                outcome=false;
                            end
                        elseif isequal(goal,decision.goals(2))
                            goalT=goal;
                            if sldvprivate('sldv_datamodel_isa',goalT,'Goal')
                                outcome=true;
                            end
                        end
                    else
                        outcome=goal.outIndex;
                    end
                    posIdx=decision.idx+1;
                    type='Decision';

                elseif sldvprivate('sldv_datamodel_isa',uo,'McdcExpr')
                    if goal.outIndex==1
                        outcome=true;
                    else
                        outcome=false;
                    end
                    posIdx=goal.condIndex+1;
                    type='MCDC';

                elseif sldvprivate('sldv_datamodel_isa',uo,'RelationalBoundary')
                    outcome=true;
                    posIdx=uo.idx+1;
                    type='RelationalBoundary';

                else
                    [blkCondGoalTypes,~,blkCondObjTypes]=Sldv.utils.getSupportedBlockConditions;
                    pos=find(strcmp(blkCondGoalTypes,goal.type),1);

                    if~isempty(pos)
                        type=blkCondObjTypes{pos};
                    end
                end
            end

            status=this.getObjectiveStatus(goal);
            info=[];
            if any(strcmp(goal.status,{'GOAL_EXCLUDED','GOAL_JUSTIFIED'}))&&~isempty(goal.information)
                info=goal.information;
            end


            rangeValues={};
            if strcmp(goal.type,'AVT_GOAL_RANGE')
                range=rangeData(cell2mat(rangeData(:,1))==goal.getGoalMapId,:);
                if~isempty(range)

                    ranges=range(:,2:3);
                    ranges=cellfun(@cellstr,ranges,'UniformOutput',0);

                    fcnName=cell(size(ranges));
                    fcnName(:)={'getTypedValue'};

                    typeString=cell(size(ranges));
                    typeString(:)={goal.compiledType};

                    isRWV=cell(size(ranges));
                    isRWV(:)={false};

                    mdlH=cell(size(ranges));
                    mdlH(:)={modelH};

                    rangeValues=cellfun(@sldvshareprivate,fcnName,ranges,typeString,isRWV,mdlH,'UniformOutput',false);

                    if~this.IsFixedPoint
                        rVals=[rangeValues{:}];
                        range_lb=min(rVals);
                        range_ub=max(rVals);
                        if~isempty(range_lb)&&~isempty(range_ub)
                            if isnan(range_lb)&&isnan(range_ub)
                                rangeValues={NaN};
                            else
                                if range_lb==range_ub
                                    rangeValues={range_lb};
                                else
                                    rangeValues={range_lb,range_ub};
                                end
                                if any(isnan(rVals))
                                    rangeValues{end+1}=NaN;
                                end
                            end
                        end
                    else

                        rangeValues=sldvshareprivate('get_non_overlapping_ranges',rangeValues);
                    end
                end
            end

            if this.IsFixedPoint
                newObjective=struct(...
                'type',type,...
                'status',status,...
                'descr',goal.description,...
                'label',goal.label,...
                'outcomeValue',outcome,...
                'busElementIdx',busSelElIdx,...
                'coveragePointIdx',posIdx,...
                'linkInfo',linkInfo,...
                'range',[],...
                'emlVarId',goal.emlVarId...
                );
            else
                newObjective=struct(...
                'type',type,...
                'status',status,...
                'descr',goal.description,...
                'dscrptEmph',{formatToDscrptEmph(goal.description,goal.descriptionFormat)},...
                'label',goal.label,...
                'outcomeValue',outcome,...
                'busElementIdx',busSelElIdx,...
                'coveragePointIdx',posIdx,...
                'linkInfo',linkInfo,...
                'range',[],...
                'moduleName','',...
                'codeLnk','',...
                'goal',goal.getGoalMapId,...
                'rationale',info...
                );

                if goal.isCodeGoal||goal.isSFcnCodeGoal
                    if goal.isCodeGoal
                        newObjective.moduleName=goal.moduleName;
                    end
                    newObjective.codeLnk=goal.codeLnkInfo;
                end
            end
            if this.IsPathBased
                newObjective.detectability=[];
                newObjective.pathObjectives=[];
                newObjective.satPathObjective=[];
                newObjective.detectionSites=struct([]);
            end

            newObjective.range=rangeValues;
        end

        function status=getObjectiveStatus(this,goal)
            isDedDeadLogic=strcmp(this.Options.Mode,'DesignErrorDetection')&&...
            strcmp(this.Options.DetectDeadLogic,'on');
            hasDeadLogic=isDedDeadLogic||...
            (strcmp(this.Options.Mode,'TestGeneration')&&...
            slavteng('feature','ChangeUnsatisfiableToDeadLogic'));

            if hasDeadLogic&&strcmpi(goal.status,'GOAL_UNSATISFIABLE')
                status='Dead Logic';
            elseif hasDeadLogic&&strcmpi(goal.status,'GOAL_UNSATISFIABLE_APPROX')
                status='Dead Logic under approximation';
            elseif isDedDeadLogic&&Sldv.utils.isDeadLogicGoal(goal)
                status=this.getStatusForDeadLogic(goal);
            else
                if strcmpi(goal.status,'GOAL_SATISFIABLE')
                    status='Satisfied';
                elseif strcmpi(goal.status,'GOAL_FALSIFIABLE')
                    status='Falsified';
                elseif strcmpi(goal.status,'GOAL_SATISFIED_BY_COVERAGE_DATA')
                    status='Satisfied by coverage data';
                elseif strcmpi(goal.status,'GOAL_SATISFIED_BY_EXISTING_TESTCASE')
                    status='Satisfied by existing testcase';
                else
                    status=goal.statusstr;
                end
            end

        end



        function emptyObjective=createEmptyObjective(this)
            if this.IsFixedPoint
                emptyObjective=struct(...
                'type','',...
                'status','GOAL_INDETERMINATE',...
                'descr','',...
                'label','',...
                'outcomeValue',false,...
                'busElementIdx',-1,...
                'coveragePointIdx',-1,...
                'linkInfo',-1,...
                'range',[],...
                'emlVarId',''...
                );
            else










                emptyObjective.type='';
                emptyObjective.status='GOAL_INDETERMINATE';
                emptyObjective.descr='';
                emptyObjective.dscrptEmph={};
                emptyObjective.label='';
                emptyObjective.outcomeValue=false;
                emptyObjective.busElementIdx=-1;
                emptyObjective.coveragePointIdx=-1;
                emptyObjective.linkInfo=-1;
                emptyObjective.range=[];
                emptyObjective.moduleName='';
                emptyObjective.codeLnk='';
                emptyObjective.goal=-1;
                emptyObjective.rationale=[];
            end
            if this.IsPathBased
                emptyObjective.detectability=[];
                emptyObjective.pathObjectives=[];
                emptyObjective.satPathObjective=[];
                emptyObjective.detectionSites=struct([]);
            end
        end
    end

    methods(Access='private')

        function status=getStatusForDeadLogic(this,goal)
            opts=this.Options;

            if strcmp(opts.DetectActiveLogic,'on')

                if strcmpi(goal.status,'GOAL_SATISFIABLE')



                    status='Active Logic';
                elseif strcmpi(goal.status,'GOAL_SATISFIABLE_NEEDS_SIMULATION')
                    status='Active Logic - needs simulation';
                elseif strcmpi(goal.status,'GOAL_FALSIFIABLE')



                    status='Active Logic';
                elseif strcmpi(goal.status,'GOAL_FALSIFIABLE_NEEDS_SIMULATION')
                    status='Active Logic - needs simulation';
                else
                    status=goal.statusstr;
                end
            else


                if goal.isEnabled
                    status='n/a';
                elseif any(strcmp(goal.status,{'GOAL_EXCLUDED','GOAL_JUSTIFIED'}))
                    status=goal.statusstr;
                end
            end
        end
    end
end

function array=formatToDscrptEmph(description,descriptionFormat)
    if isempty(descriptionFormat)

        array={false,description};
    else

        array={};

        count=numel(description);
        assert(count==numel(descriptionFormat));

        currentIndex=1;
        currentFormat=descriptionFormat(1);
        for index=1:count
            if descriptionFormat(index)~=currentFormat
                emphasis=currentFormat;
                array(end+1:end+2)={emphasis,...
                description(currentIndex:index-1)};
                currentFormat=descriptionFormat(index);
                currentIndex=index;
            end
        end

        array(end+1:end+2)={currentFormat,description(currentIndex:index)};
    end
end


