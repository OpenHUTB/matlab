
classdef TestSequenceManager


    properties(Access=protected)
chart
sttManager
viewManager
    end

    properties(Constant,Access=protected)

        exposedBlockProperties={'Name','ChartUpdate','SampleTime','Description',...
        'Document','Tag','SupportVariableSizing','SaturateOnIntegerOverflow',...
        'InputFimath','EmlDefaultFimath','HasOutputData','OutputData','StateActivityOutputDataType'};


        blockPropertyToAlias=containers.Map(...
        {'hasoutputdata','outputdata','chartupdate','stateactivityoutputdatatype'},...
        {'EnableActiveStepData','ActiveStepDataSymbol','UpdateMethod','ActiveStepDataType'});

        aliasToBlockProperty=containers.Map(...
        {'enableactivestepdata','activestepdatasymbol','updatemethod','activestepdatatype'},...
        {'hasOutputData','OutputData','ChartUpdate','StateActivityOutputDataType'});



        symbolPropertyAliasToDataProperty=containers.Map(...
        {'InitialValue','VariableSize',...
        'ResolveToSignalObject','RangeMinimum','RangeMaximum',...
        'Size','Unit','IsComplex',...
        'ActiveStepEnumName'},...
        {'Props.InitialValue','Props.Array.IsDynamic',...
        'Props.ResolveToSignalObject','Props.Range.Minimum','Props.Range.Maximum',...
        'Props.Array.Size','Props.Unit.Name','Props.Complexity',...
        'OutputState.EnumTypeName'}...
        );
    end

    methods(Access=protected)

        function busy=isBusy(self,supportFastRestart)
            model=get(bdroot(sfprivate('getActiveInstance',self.sttManager.parentChartId)),'Object');
            if supportFastRestart


                busy=(ismember(model.SimulationStatus,{'updating','initializing','terminating'})...
                ||(model.isHierarchySimulating&&~strcmp(model.SimulationStatus,'compiled'))...
                ||model.isHierarchyBuilding);
            else
                busy=(ismember(model.SimulationStatus,{'updating','initializing','terminating'})...
                ||(model.isHierarchySimulating)...
                ||model.isHierarchyBuilding);
            end
        end

        function permission=isWritable(self)




            permission=true;



            assert(~isempty(self.chart.path));

            parentBlock=get_param(self.chart.path,'Object');

            while(isa(parentBlock,'Simulink.SubSystem'))


                if(strcmp(parentBlock.permissions,'NoReadOrWrite')...
                    ||strcmp(parentBlock.permissions,'ReadOnly'))
                    permission=false;
                    return;
                end

                parentBlock=get_param(parentBlock.parent,'Object');
            end
        end

        function permission=isReadable(self)




            permission=true;



            assert(~isempty(self.chart.path));

            parentBlock=get_param(self.chart.path,'Object');

            while(isa(parentBlock,'Simulink.SubSystem'))


                if(strcmp(parentBlock.permissions,'NoReadOrWrite'))
                    permission=false;
                    return;
                end

                parentBlock=get_param(parentBlock.parent,'Object');
            end
        end

        function self=initInternManager(self,path,readonly,supportFastRestart)

            if~Simulink.harness.internal.licenseTest()
                error(message('Simulink:Harness:LicenseNotAvailable'));
            end

            if iscell(path)&&numel(path)>1
                error(message('Stateflow:reactive:MultipleTSPathAPI'));
            end

            rt=sfroot();



            try
                find_system(path,'SearchDepth',1);
            catch
                error(message('Stateflow:reactive:InvalidTestSequence',path))
            end

            self.chart=rt.find('-isa','Stateflow.ReactiveTestingTableChart','Path',path);
            if(isempty(self.chart))
                error(message('Stateflow:reactive:InvalidTestSequence',path))
            end
            if(~self.isReadable()||(~readonly&&~self.isWritable()))
                error(message('Stateflow:reactive:TestSequenceLocked',path))
            end

            self.sttManager=Stateflow.STT.StateEventTableMan(self.chart.id);
            assert(~isempty(self.sttManager),'Error: Unable to find internal table for %s',path)
            if(~readonly&&self.isBusy(supportFastRestart))
                error(message('Stateflow:reactive:ModelIsBusy'))
            end


            self.viewManager=self.sttManager.viewManager;
            assert(~isempty(self.viewManager),'Error: Unable to find internal view for %s',path)



            if~readonly&&self.viewManager.isViewAvailable
                error(message('Stateflow:reactive:ImportTestSequenceCloseUI',path));
            end

        end

        function stepId=getStepId(self,stepName)

            namePath=strsplit(stepName,'.');
            stepId=-1;

            function parentAndIdList=getSTTParentAndId(self,stepName)




                model=self.sttManager.tableModel;
                parentAndIdList=struct('parent',{},'id',{});
                numSkipRows=self.viewManager.getNumRowsToSkip();

                for row=numSkipRows:model.numRows
                    ccell=model.getCellAtLocation(row,Stateflow.STT.Constants.STATES_COLUMN_INDEX);
                    if strcmp(ccell.stateName,stepName)

                        res.parent=ccell.parent;
                        res.id=row;
                        parentAndIdList(end+1)=res;%#ok<AGROW>
                    end
                end
            end

            function isValid=isValidNamePath(parentId,namePathId)


                parentCell=Stateflow.STT.StateCell(parentId);
                if(namePathId==1)

                    isValid=(parentCell.parent==0);
                else
                    if(parentCell.parent==0)

                        isValid=false;
                    else
                        if(strcmp(parentCell.stateName,namePath(namePathId-1)))

                            isValid=isValidNamePath(parentCell.parent,namePathId-1);
                        else

                            isValid=false;
                        end
                    end
                end
            end




            potentialParents=getSTTParentAndId(self,namePath(end));


            for i=1:length(potentialParents)
                if isValidNamePath(potentialParents(i).parent,length(namePath))


                    stepId=potentialParents(i).id;
                    break;
                end
            end
        end

        function beforeId=getBeforeIdForAfter(self,afterId)



            beforeId=-1;
            if afterId>0

                model=self.sttManager.tableModel;
                ccell=model.getCellAtLocation(afterId,Stateflow.STT.Constants.STATES_COLUMN_INDEX);


                parentId=ccell.parent;
                for row=afterId+1:model.numRows
                    nextCell=model.getCellAtLocation(row,Stateflow.STT.Constants.STATES_COLUMN_INDEX);
                    if nextCell.parent==parentId
                        beforeId=row;
                        break;
                    end
                end
            end
        end

        function state=emptyState(~,name)


            state.stateId=-1;
            state.stateName=name;
            state.stateLabel=name;
            state.description='';
            state.rowHeight=-1;
            state.isExpanded=true;
            state.isWhenState=false;
            state.hasBreakpoint=false;
            state.transitions=[];
            state.children=[];
        end

        function transition=trTransition(~,cond,dest)


            transition.cond=cond;
            transition.dest=dest;
            transition.hasBreakpoint=false;
        end

        function[stepName,parentStepName]=getStepAndParentNames(~,newStepName)

            pathName=strsplit(newStepName,'.');

            stepName=strjoin(pathName(end));
            parentStepName=strjoin(pathName(1:(end-1)),'.');
        end

        function res=isNameInvalid(~,name)
            res=isempty(regexp(name,'^[A-Za-z]\w*$','once'));
        end

        function[stepName,parentStep]=checkStepParent(self,newStepName)
            [stepName,parentStep]=self.getStepAndParentNames(newStepName);
            if isempty(parentStep)&&self.isUsingScenarios()
                error(message('Stateflow:reactive:InvalidStepPathWithScenarioEnabled',newStepName));
            end
        end

        function res=isValidStep(self,stepNamePath)



            namePath=strsplit(stepNamePath,'.');
            for i=1:length(namePath)
                if self.isNameInvalid(namePath{i})
                    error(message('Stateflow:reactive:InvalidStepName',namePath{i}));
                end
            end

            res=(self.getStepId(stepNamePath)>0);
        end

        function res=isDeletableStep(self,stepTableIndex)

            res=true;
            if~self.isUsingScenarios()
                if(self.sttManager.tableModel.numRows<=2)


                    res=false;
                else

                    if(stepTableIndex==2&&self.getBeforeIdForAfter(stepTableIndex)==-1)
                        res=false;
                    end
                end
            else
                ccell=self.sttManager.tableModel.getCellAtLocation(stepTableIndex,Stateflow.STT.Constants.STATES_COLUMN_INDEX);
                assert(ccell.parent>0);
                parentCell=Stateflow.STT.StateCell(ccell.parent);
                assert(parentCell.parent>0);
                grandParentCell=Stateflow.STT.StateCell(parentCell.parent);
                if grandParentCell.parent==0

                    if self.getBeforeIdForAfter(stepTableIndex)==-1

                        cellBeforeCurrent=self.sttManager.tableModel.getCellAtLocation(stepTableIndex-1,Stateflow.STT.Constants.STATES_COLUMN_INDEX);
                        if cellBeforeCurrent.cellObjectId==ccell.parent

                            res=false;
                        end
                    end
                end
            end
        end

        function res=isValidScenario(self,scenarioName)




            if self.isNameInvalid(scenarioName)
                error(message('Stateflow:reactive:InvalidScenarioName',scenarioName));
            end


            res=(self.getScenarioIndex(scenarioName)>0);
        end


        function scenarioIndex=getScenarioIndex(self,scenarioName)
            [~,scenarioIndex]=ismember(scenarioName,self.getAllScenarios());
        end

        function checkAreInSameDepth(self,step1,step2)
            [~,step1Parent]=self.getStepAndParentNames(step1);
            [~,step2Parent]=self.getStepAndParentNames(step2);
            if(~strcmp(step1Parent,step2Parent))
                error(message('Stateflow:reactive:StepDepthDiffer',step1,step2));
            end
        end

        function res=findLastChild(self,index)

            if(index<self.sttManager.tableModel.numRows)

                ccell=self.sttManager.tableModel.getCellAtLocation(index,Stateflow.STT.Constants.STATES_COLUMN_INDEX);
                nextcell=self.sttManager.tableModel.getCellAtLocation(index+1,1);

                isSubstep=(nextcell.parent==ccell.cellObjectId);
                while isSubstep

                    index=findLastChild(self,index+1);

                    if(index<self.sttManager.tableModel.numRows)

                        nextcell=self.sttManager.tableModel.getCellAtLocation(index+1,1);
                        isSubstep=(nextcell.parent==ccell.cellObjectId);
                    else
                        isSubstep=false;
                    end
                end
            end
            res=index;
        end


        function res=getFullStepName(self,parentId,name)
            parentCell=Stateflow.STT.StateCell(parentId);
            if(parentCell.parent==0)
                res=name;
            else
                parentFullName=self.getFullStepName(parentCell.parent,parentCell.stateName);
                res=[parentFullName,'.',name];
            end
        end


        function res=getStepList(self)
            table=self.sttManager.tableModel;
            numSkipRows=self.viewManager.getNumRowsToSkip();
            if~self.isUsingScenarios()
                res=cell(1,table.numRows-(numSkipRows-1));
                for row=numSkipRows:table.numRows
                    ccell=table.getCellAtLocation(row,Stateflow.STT.Constants.STATES_COLUMN_INDEX);
                    res{row-(numSkipRows-1)}=self.getFullStepName(ccell.parent,ccell.stateName);
                end
            else
                siblings=table.getSiblingRowsOf(2);
                allRows=numSkipRows:table.numRows;
                allStepRows=setdiff(allRows,siblings);
                res=cell(1,numel(allStepRows));
                for i=1:numel(allStepRows)
                    row=allStepRows(i);
                    ccell=table.getCellAtLocation(row,Stateflow.STT.Constants.STATES_COLUMN_INDEX);
                    res{i}=self.getFullStepName(ccell.parent,ccell.stateName);
                end
            end
        end


        function prop=getBlockPropertyName(self,p)
            if(self.aliasToBlockProperty.isKey(p))
                prop=self.aliasToBlockProperty(p);
            else
                prop=p;
            end
        end


        function prop=getBlockAliasProperty(self,p)
            if(self.blockPropertyToAlias.isKey(lower(p)))
                prop=self.blockPropertyToAlias(lower(p));
            else
                prop=p;
            end
        end

        function prop=getSymbolDataPropertyPath(self,p)



            l=self.symbolPropertyAliasToDataProperty.keys;
            idx=find(strcmpi(p,l),1);
            if isempty(idx)

                prop=p;
            else

                prop=self.symbolPropertyAliasToDataProperty(l{idx});
            end
        end


        function res=getBlockActiveStepOutput(self)

            if isempty(self.chart.OutputData)
                res='';
            else
                res=self.chart.OutputData.Name;
            end
        end


        function res=getBlockScenarioParameter(self)
            res=self.viewManager.getScenarioParameterName();
        end


        function lastId=getTransitionCount(self,stepId)
            table=self.sttManager.tableModel;
            ccell=table.getCellAtLocation(stepId,Stateflow.STT.Constants.STATES_COLUMN_INDEX);
            lastId=0;

            if~(ccell.isWhenChild)
                for i=2:table.numColumns
                    trCell=table.getCellAtLocation(stepId,i);



                    if(isempty(trCell.destinationState))
                        break;
                    end
                    lastId=lastId+1;
                end
            end
        end


        function symbol=getSymbol(self,name)
            symbol=self.sttManager.parentChartUddH.find('-depth',1,'Name',name,{'-isa','Stateflow.Data','-or','-isa','Stateflow.FunctionCall','-or','-isa','Stateflow.Trigger','-or','-isa','Stateflow.Message'});
            assert(length(symbol)<=1);
        end
    end

    methods


        function self=TestSequenceManager(path,readonly,supportFastRestart)
            if(nargin<3)

                supportFastRestart=false;
            end
            if(nargin<2)

                readonly=false;
            end

            if isnumeric(path)
                try
                    bdroot(path);
                catch ME
                    throwAsCaller(ME);
                end
                mdl=get(path,'path');
                blk=get(path,'name');
                path=[mdl,'/',blk];
            end

            self=self.initInternManager(path,readonly,supportFastRestart);
        end


        function res=getProperty(self,propertyName)


            if(nargin<2)
                for i=1:numel(self.exposedBlockProperties)

                    property=self.getBlockAliasProperty(self.exposedBlockProperties{i});

                    if(strcmpi('ActiveStepDataSymbol',property))
                        res.(property)=self.getBlockActiveStepOutput();
                    else
                        res.(property)=self.chart.(self.exposedBlockProperties{i});
                    end
                end
                res.ScenarioParameter=self.getBlockScenarioParameter();
                if strcmp(self.chart.StateMachineType,'Classic')
                    res.Semantics='StateflowCompatible';
                else
                    res.Semantics='Legacy';
                end
            else
                switch lower(propertyName)
                case 'enableactivestepoutput'
                    self.throwWarningWithoutBackTrace(message('Stateflow:reactive:DeprecatedParameter','EnableActiveStepOutput','EnableActiveStepData'));
                    propertyName='EnableActiveStepData';
                case 'outputdata'
                    self.throwWarningWithoutBackTrace(message('Stateflow:reactive:DeprecatedParameter','OutputData','ActiveStepDataSymbol'));
                    propertyName='ActiveStepDataSymbol';
                end

                if(strcmpi(propertyName,'ScenarioParameter'))
                    res=self.getBlockScenarioParameter();
                elseif strcmpi(propertyName,'Semantics')
                    if strcmp(self.chart.StateMachineType,'Classic')
                        res='StateflowCompatible';
                    else
                        res='Legacy';
                    end
                else
                    property=self.getBlockPropertyName(lower(propertyName));

                    if~ismember(lower(property),lower(self.exposedBlockProperties))
                        error(message('Stateflow:reactive:InvalidTSBProperty',propertyName));
                    end

                    if(strcmpi('OutputData',property))
                        res=self.getBlockActiveStepOutput();
                    else
                        res=self.chart.(property);
                    end
                end
            end
        end


        function setProperty(self,varargin)
            p=inputParser;
            p.PartialMatching=false;

            activeStepDataStringSupported=sf('feature','ActiveStateOutputString');
            for i=1:numel(self.exposedBlockProperties)
                p.addParameter(self.getBlockAliasProperty(self.exposedBlockProperties{i}),'');
            end

            p.addParameter('ScenarioParameter','');

            p.addParameter('EnableActiveStepOutput','');
            p.addParameter('OutputData','');
            p.addParameter('Semantics','',@(x)any(strcmpi(x,{'StateflowCompatible','Legacy'})));

            p.parse(varargin{:});
            results=p.Results;
            usingDefaults=p.UsingDefaults;

            if~ismember('EnableActiveStepOutput',usingDefaults)
                self.throwWarningWithoutBackTrace(message('Stateflow:reactive:DeprecatedParameter','EnableActiveStepOutput','EnableActiveStepData'));
                if~ismember('EnableActiveStepData',usingDefaults)
                    self.throwWarningWithoutBackTrace(message('Stateflow:reactive:DeprecatedParameterIsIgnored','EnableActiveStepOutput','EnableActiveStepData'));
                else
                    results.EnableActiveStepData=results.EnableActiveStepOutput;
                    usingDefaults{end+1}='EnableActiveStepOutput';
                end
            end
            if~ismember('OutputData',usingDefaults)
                self.throwWarningWithoutBackTrace(message('Stateflow:reactive:DeprecatedParameter','OutputData','ActiveStepDataSymbol'));
                if~ismember('ActiveStepDataSymbol',usingDefaults)
                    self.throwWarningWithoutBackTrace(message('Stateflow:reactive:DeprecatedParameterIsIgnored','OutputData','ActiveStepDataSymbol'));
                else
                    results.ActiveStepDataSymbol=results.OutputData;
                    usingDefaults{end+1}='OutputData';
                end
            end

            for i=1:numel(self.exposedBlockProperties)
                currentProperty=self.getBlockAliasProperty(self.exposedBlockProperties{i});
                if~ismember(currentProperty,usingDefaults)
                    property=self.exposedBlockProperties{i};
                    value=results.(currentProperty);
                    if(~isequal(value,self.chart.(property)))

                        if(self.chart.isReadonlyProperty(property)||(~activeStepDataStringSupported&&strcmp(property,'StateActivityOutputDataType')))
                            if numel(varargin)==1&&isstruct(varargin{:})
                                self.throwWarningWithoutBackTrace(message('Stateflow:reactive:ReadOnlySymbolProperty',currentProperty,self.chart.Path));
                            else
                                error(message('Stateflow:reactive:ReadOnlySymbolProperty',currentProperty,self.chart.Path));
                            end
                        else

                            try
                                self.chart.(property)=value;
                            catch ME
                                throwAsCaller(addCause(MException(message('Stateflow:reactive:PropertyError',value,currentProperty,self.chart.Path)),ME));
                            end
                        end
                    end
                end
            end

            if~ismember('Semantics',usingDefaults)
                if strcmpi(results.Semantics,'StateflowCompatible')
                    self.chart.StateMachineType='Classic';
                else
                    self.chart.StateMachineType='Simplified';
                end
            end


            if~ismember('ScenarioParameter',usingDefaults)
                if~isequal(results.ScenarioParameter,self.getBlockScenarioParameter())
                    if numel(varargin)==1&&isstruct(varargin{:})
                        self.throwWarningWithoutBackTrace(message('Stateflow:reactive:ReadOnlySymbolProperty','ScenarioParameter',self.chart.Path));
                    else
                        error(message('Stateflow:reactive:ReadOnlySymbolProperty','ScenarioParameter',self.chart.Path));
                    end
                end
            end
        end



        function res=isUsingScenarios(self)
            res=self.viewManager.getIsUseScenarios();
        end

        function useScenario(self,scenarioName)
            if self.isUsingScenarios()
                error(message('Stateflow:reactive:RepeatedCreateScenario',self.chart.Path))
            end

            try
                validateattributes(scenarioName,{'char'},{'nonempty'});
            catch ME
                throwAsCaller(MException(message('Stateflow:reactive:InvalidScenarioName',ME.message)));
            end

            if self.isNameInvalid(scenarioName)
                error(message('Stateflow:reactive:InvalidScenarioName',scenarioName));
            end

            self.viewManager.jsConvertToScenarios(scenarioName);


            self.sttManager.tableModel.columnWidths(3)=1;
        end

        function addScenario(self,newScenario)
            if~self.isUsingScenarios()
                error(message('Stateflow:reactive:AddScenarioBeforeEnable',self.chart.Path))
            end

            try
                validateattributes(newScenario,{'char'},{'nonempty'});
            catch ME
                throwAsCaller(MException(message('Stateflow:reactive:InvalidScenarioName',ME.message)));
            end

            if(self.isValidScenario(newScenario))
                error(message('Stateflow:reactive:ScenarioRedefinition',newScenario));
            end

            self.viewManager.jsAddScenario([],newScenario);
        end

        function deleteScenario(self,scenarioName)
            if~self.isUsingScenarios()
                error(message('Stateflow:reactive:DeleteScenarioBeforeEnable',self.chart.Path));
            end

            if numel(self.getAllScenarios())==1
                error(message('Stateflow:reactive:DeleteUniqueScenario',scenarioName));
            end

            try
                validateattributes(scenarioName,{'char'},{'nonempty'});
            catch ME
                throwAsCaller(MException(message('Stateflow:reactive:InvalidScenarioName',ME.message)));
            end

            scenarioIndex=self.getScenarioIndex(scenarioName);

            if scenarioIndex==0
                error(message('Stateflow:reactive:InvalidScenarioName',scenarioName));
            end

            linearIndex=self.getStepId(scenarioName);
            self.viewManager.jsDeleteScenario(scenarioIndex-1,linearIndex-3);
        end

        function scenarios=getAllScenarios(self)
            if~self.isUsingScenarios()
                error(message('Stateflow:reactive:RetrieveScenarioBeforeEnable',self.chart.Path))
            end

            scenarios={};
            contents=Stateflow.internal.StateTransitionTableManager.GetTableAsStruct(self.viewManager.stateflowParentId,true);
            tableData=contents.tableData;

            for i=2:numel(tableData)
                scenarios{i-1}=tableData(i).stateLabel;
            end
        end

        function activateScenario(self,scenarioName)
            if~self.isUsingScenarios()
                error(message('Stateflow:reactive:ActivateScenarioBeforeEnable',self.chart.Path));
            end
            if self.getScenarioControlSource==sltest.testsequence.ScenarioControlSource.Workspace
                error(message('Stateflow:reactive:ActivateScenarioForWorkspaceControl',self.chart.Path));
            end
            try
                validateattributes(scenarioName,{'char'},{'nonempty'});
            catch ME
                throwAsCaller(MException(message('Stateflow:reactive:InvalidScenarioName',ME.message)));
            end
            scenarioIndex=self.getScenarioIndex(scenarioName);
            if scenarioIndex==0
                error(message('Stateflow:reactive:InvalidScenarioName',scenarioName));
            end
            self.viewManager.jsActiveScenario(scenarioIndex-1);
        end

        function scenarioName=getActiveScenario(self)
            if~self.isUsingScenarios()
                error(message('Stateflow:reactive:GetActiveScenarioBeforeEnable',self.chart.Path));
            end
            if self.getScenarioControlSource==sltest.testsequence.ScenarioControlSource.Workspace
                error(message('Stateflow:reactive:GetActiveScenarioForWorkspaceControl',self.chart.Path));
            end
            activeScenarioIndex=self.viewManager.jsActiveScenario();
            allScenarios=self.getAllScenarios();
            scenarioName=allScenarios{activeScenarioIndex+1};
        end

        function setScenarioControlSource(self,source)
            if~self.isUsingScenarios()
                error(message('Stateflow:reactive:ControlScenarioBeforeEnable',self.chart.Path));
            end
            switch(source)
            case sltest.testsequence.ScenarioControlSource.Block
                self.viewManager.jsSetReadActiveFromWorkspace(false);
            case sltest.testsequence.ScenarioControlSource.Workspace
                self.viewManager.jsSetReadActiveFromWorkspace(true);
            end
        end

        function scenarioControlSource=getScenarioControlSource(self)
            if~self.isUsingScenarios()
                error(message('Stateflow:reactive:GetScenarioControlBeforeEnable',self.chart.Path));
            end
            isWorkspace=self.viewManager.jsGetReadActiveFromWorkspace();
            switch(isWorkspace)
            case true
                scenarioControlSource=sltest.testsequence.ScenarioControlSource.Workspace;
            case false
                scenarioControlSource=sltest.testsequence.ScenarioControlSource.Block;
            end
        end

        function editScenario(self,currentScenarioName,varargin)
            if~self.isUsingScenarios()
                error(message('Stateflow:reactive:EditScenarioBeforeEnable',self.chart.Path));
            end

            try
                validateattributes(currentScenarioName,{'char'},{'nonempty'});
            catch ME
                throwAsCaller(MException(message('Stateflow:reactive:InvalidScenarioName',ME.message)));
            end

            p=inputParser;
            p.PartialMatching=false;
            p.addParameter('Name','',@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.parse(varargin{:});
            scenarioIndex=self.getScenarioIndex(currentScenarioName);

            if scenarioIndex==0
                error(message('Stateflow:reactive:InvalidScenarioName',currentScenarioName));
            end

            if~ismember('Name',p.UsingDefaults)
                try
                    validateattributes(p.Results.Name,{'char'},{'nonempty'});
                catch ME
                    throwAsCaller(MException(message('Stateflow:reactive:InvalidScenarioName',ME.message)));
                end
                newScenarioName=p.Results.Name;
                if(~strcmp(newScenarioName,currentScenarioName)&&self.isValidScenario(newScenarioName))
                    error(message('Stateflow:reactive:ScenarioRedefinition',newScenarioName));
                end

                linearIndex=self.getStepId(currentScenarioName);
                self.viewManager.jsSetStateLabel(linearIndex-3,newScenarioName,false);
            end
        end





        function addStep(self,newStep,varargin)








            if isstruct(newStep)

                if~(isempty(varargin))
                    error(message('Stateflow:reactive:NonUniqueStructParameter','step'));
                end

                if~isfield(newStep,'Name')
                    error(message('Stateflow:reactive:MissingStepName'));
                else
                    newStepName=newStep.Name;

                    varargin={rmfield(newStep,'Name')};
                end
            else
                try
                    validateattributes(newStep,{'char'},{'nonempty'});
                catch ME
                    throwAsCaller(MException(message('Stateflow:reactive:InvalidStepName',ME.message)));
                end

                newStepName=newStep;
            end

            if(self.isValidStep(newStepName))
                error(message('Stateflow:reactive:StepRedefinition',newStepName));
            end
            [stepName,parentStep]=self.checkStepParent(newStepName);
            data=self.emptyState(stepName);
            numSkipRows=self.viewManager.getNumRowsToSkip();
            if(isempty(parentStep))
                self.viewManager.jsAddState(-1,-1,data);
            else
                parentId=self.getStepId(parentStep);
                if(parentId<0)


                    self.addStep(parentStep);

                    parentId=self.getStepId(parentStep);
                end

                self.viewManager.jsAddState((parentId-numSkipRows),-1,data);
            end
            self.editStepHelper(newStepName,'addStep',varargin{:});
        end

        function addStepAfter(self,newStep,afterStepName,varargin)









            if isstruct(newStep)

                if~(isempty(varargin))
                    error(message('Stateflow:reactive:NonUniqueStructParameter','step'));
                end

                if~isfield(newStep,'Name')
                    error(message('Stateflow:reactive:MissingStepName'));
                else
                    newStepName=newStep.Name;

                    varargin={rmfield(newStep,'Name')};
                end
            else
                newStepName=newStep;
            end

            [stepName,parentStep]=self.getStepAndParentNames(newStepName);
            actualNewStepName=newStepName;
            [~,parentAfterStep]=self.checkStepParent(afterStepName);
            if isempty(parentStep)&&~isempty(parentAfterStep)
                actualNewStepName=[parentAfterStep,'.',newStepName];
            end
            if(self.isValidStep(actualNewStepName))
                error(message('Stateflow:reactive:StepRedefinition',actualNewStepName));
            end
            if(~(self.isValidStep(afterStepName)))
                error(message('Stateflow:reactive:UndefinedStep',afterStepName));
            end
            if~isempty(parentStep)&&~strcmp(parentStep,parentAfterStep)
                error(message('Stateflow:reactive:StepDepthDiffer',newStepName,afterStepName));
            end
            parentId=self.getStepId(parentAfterStep);
            afterId=self.getStepId(afterStepName);
            numSkipRows=self.viewManager.getNumRowsToSkip();
            if(afterId==self.sttManager.tableModel.numRows)
                afterId=-1;
            else
                afterId=self.getBeforeIdForAfter(afterId);
                if afterId>0

                    afterId=afterId-numSkipRows;
                end
            end
            data=self.emptyState(stepName);
            if parentId>0

                parentId=parentId-numSkipRows;
            end
            self.viewManager.jsAddState(parentId,afterId,data);
            self.editStepHelper(actualNewStepName,'addStepAfter',varargin{:});
        end

        function addStepBefore(self,newStep,beforeStepName,varargin)









            if isstruct(newStep)

                if~(isempty(varargin))
                    error(message('Stateflow:reactive:NonUniqueStructParameter','step'));
                end

                if~isfield(newStep,'Name')
                    error(message('Stateflow:reactive:MissingStepName'));
                else
                    newStepName=newStep.Name;

                    varargin={rmfield(newStep,'Name')};
                end
            else
                newStepName=newStep;
            end

            [stepName,parentStep]=self.getStepAndParentNames(newStepName);
            actualNewStepName=newStepName;
            [~,parentBeforeStep]=self.checkStepParent(beforeStepName);
            if isempty(parentStep)&&~isempty(parentBeforeStep)
                actualNewStepName=[parentBeforeStep,'.',newStepName];
            end
            if(self.isValidStep(actualNewStepName))
                error(message('Stateflow:reactive:StepRedefinition',actualNewStepName));
            end
            if(~(self.isValidStep(beforeStepName)))
                error(message('Stateflow:reactive:UndefinedStep',beforeStepName));
            end
            if~isempty(parentStep)&&~strcmp(parentStep,parentBeforeStep)
                error(message('Stateflow:reactive:StepDepthDiffer',newStepName,beforeStepName));
            end
            parentId=self.getStepId(parentBeforeStep);
            afterId=self.getStepId(beforeStepName);
            numSkipRows=self.viewManager.getNumRowsToSkip();
            data=self.emptyState(stepName);

            self.viewManager.jsAddState((parentId-numSkipRows),(afterId-numSkipRows),data);
            self.editStepHelper(actualNewStepName,'addStepBefore',varargin{:});
        end

        function deleteStep(self,stepName)





            if(~self.isValidStep(stepName))
                error(message('Stateflow:reactive:UndefinedStep',stepName));
            end
            self.checkStepParent(stepName);
            stepId=self.getStepId(stepName);


            if~self.isDeletableStep(stepId)
                error(message('Stateflow:reactive:DeleteUniqueStep',stepName));
            end

            numSkipRows=self.viewManager.getNumRowsToSkip();
            self.viewManager.jsDeleteState(stepId-numSkipRows);
        end

        function editStep(self,newStep,varargin)

            if isstruct(newStep)
                if~(isempty(varargin))
                    error(message('Stateflow:reactive:NonUniqueStructParameter','step'));
                end
                if~isfield(newStep,'Name')
                    error(message('Stateflow:reactive:MissingStepName'));
                else
                    stepName=newStep.Name;

                    varargin={rmfield(newStep,'Name')};
                end
            else
                stepName=newStep;
            end
            self.editStepHelper(stepName,'editStep',varargin{:});
        end

        function editStepHelper(self,stepName,editType,varargin)

            if(numel(varargin)==1&&isstruct(varargin{:}))

                if(isfield(varargin{:},'TransitionCount'))
                    varargin={rmfield(varargin{:},'TransitionCount')};
                end
                if(isfield(varargin{:},'IsWhenSubStep'))
                    varargin={rmfield(varargin{:},'IsWhenSubStep')};
                end
            end

            p=inputParser;
            p.PartialMatching=false;
            if strcmp(editType,'editStep')
                p.addParameter('Name','',@(x)validateattributes(x,{'char'},{'nonempty'}));
            end

            p.addParameter('Label','',@ischar);
            p.addParameter('Action','',@ischar);
            p.addParameter('IsWhenStep',false,@islogical);
            p.addParameter('WhenCondition','',@ischar);
            p.addParameter('Description','',@ischar);
            if ismember(editType,{'addStep','editStep'})
                p.addParameter('Index',-1,@(x)validateattributes(x,{'numeric'},{'scalar','>',0}));
            end
            p.parse(varargin{:});

            if(~self.isValidStep(stepName))
                error(message('Stateflow:reactive:UndefinedStep',stepName));
            end

            self.checkStepParent(stepName);
            numSkipRows=self.viewManager.getNumRowsToSkip();
            index=self.getStepId(stepName);
            ccell=self.sttManager.tableModel.getCellAtLocation(index,Stateflow.STT.Constants.STATES_COLUMN_INDEX);

            editLabel=~ismember('Label',p.UsingDefaults)||~ismember('Action',p.UsingDefaults);
            label='';
            if~editLabel

                [~,label]=strtok(ccell.cellText,char(10));
                if~isempty(label)
                    label(1)=[];
                end
            else
                if~ismember('Label',p.UsingDefaults)
                    label=p.Results.Label;
                    self.throwWarningWithoutBackTrace(message('Stateflow:reactive:DeprecatedParameter','Label','Action'));
                end
                if~ismember('Action',p.UsingDefaults)
                    if~isempty(label)
                        self.throwWarningWithoutBackTrace(message('Stateflow:reactive:DeprecatedParameterIsIgnored','Label','Action'));
                    end
                    label=p.Results.Action;
                end
            end

            if ismember('WhenCondition',p.UsingDefaults)
                whencond=ccell.whenCondition;
            else
                whencond=p.Results.WhenCondition;
            end


            if~ismember('WhenCondition',p.UsingDefaults)
                parentid=ccell.parent;
                assert(parentid>numSkipRows-2);
                pcell=Stateflow.STT.StateCell(parentid);
                [~,parentStep]=self.getStepAndParentNames(stepName);
                if((pcell.isWhenState==false))
                    error(message('Stateflow:reactive:NonWhenChildInvalidWhenConditionRTT',stepName,parentStep));
                end



                if ismember(editType,{'editStep','addStepAfter'})

                    if(index>=self.sttManager.tableModel.numRows)
                        error(message('Stateflow:reactive:WhenChildInvalidWhenConditionRTT',stepName,parentStep));
                    end


                    index2=self.findLastChild(index);
                    if(index2>=self.sttManager.tableModel.numRows)
                        error(message('Stateflow:reactive:WhenChildInvalidWhenConditionRTT',stepName,parentStep));
                    end

                    nextcell=self.sttManager.tableModel.getCellAtLocation(index2+1,1);

                    if(nextcell.parent~=parentid)
                        error(message('Stateflow:reactive:WhenChildInvalidWhenConditionRTT',stepName,parentStep));
                    end
                end
            end

            if~isempty(whencond)
                whencond=[' when ',whencond];
            end

            if ismember('Index',p.Parameters)&&~ismember('Index',p.UsingDefaults)
                siblings=self.sttManager.tableModel.getSiblingRowsOf(index);
                if p.Results.Index>length(siblings)
                    error(message('Stateflow:reactive:InvalidStepIndex',p.Results.Index,stepName));
                end
            end

            if strcmp(editType,'editStep')&&~ismember('Name',p.UsingDefaults)
                stepName=p.Results.Name;
            else
                [stepName,~]=self.getStepAndParentNames(stepName);
            end
            label=sprintf('%s%s\n%s',stepName,whencond,label);

            self.viewManager.jsSetStateLabel(index-numSkipRows,label,false);

            if~ismember('IsWhenStep',p.UsingDefaults)
                self.viewManager.jsSetStateWhenState(index-numSkipRows,p.Results.IsWhenStep);
            end

            if~ismember('Description',p.UsingDefaults)
                self.viewManager.jsSetStateDescription(index-numSkipRows,p.Results.Description,false);
            end

            if ismember('Index',p.Parameters)&&~ismember('Index',p.UsingDefaults)
                if find(siblings==index,1)~=p.Results.Index
                    self.viewManager.jsReorderState(index-numSkipRows,p.Results.Index-1);
                end
            end
        end


        function res=readStep(self,stepName,property)


            if(~self.isValidStep(stepName))
                error(message('Stateflow:reactive:UndefinedStep',stepName));
            end
            self.checkStepParent(stepName);
            index=self.getStepId(stepName);
            ccell=self.sttManager.tableModel.getCellAtLocation(index,Stateflow.STT.Constants.STATES_COLUMN_INDEX);



            if(nargin<3)
                res.Name=stepName;
                res.Action=self.unwrapStepLabel(ccell.cellText);
                res.IsWhenStep=logical(ccell.isWhenState);
                res.IsWhenSubStep=logical(ccell.isWhenChild);

                if(ccell.isWhenChild)
                    res.WhenCondition=ccell.whenCondition;
                end
                res.Description=ccell.stateUddH.Description;
                res.Index=find(self.sttManager.tableModel.getSiblingRowsOf(index)==index,1);
                res.TransitionCount=self.getTransitionCount(index);
            else
                switch lower(property)
                case 'name'
                    res=stepName;
                case 'label'

                    res=self.unwrapStepLabel(ccell.cellText);
                    self.throwWarningWithoutBackTrace(message('Stateflow:reactive:DeprecatedParameter','Label','Action'));
                case 'action'

                    res=self.unwrapStepLabel(ccell.cellText);
                case 'iswhenstep'
                    res=logical(ccell.isWhenState);
                case 'whencondition'
                    if(ccell.isWhenChild)
                        res=ccell.whenCondition;
                    else
                        error(message('Stateflow:reactive:NonWhenChildInvalidRead',stepName))
                    end
                case 'iswhenchild'
                    res=ccell.isWhenChild;
                    self.throwWarningWithoutBackTrace(message('Stateflow:reactive:DeprecatedParameter','IsWhenChild','IsWhenSubStep'));
                case 'iswhensubstep'
                    res=logical(ccell.isWhenChild);
                case 'description'
                    res=ccell.stateUddH.Description;
                case 'index'
                    res=find(self.sttManager.tableModel.getSiblingRowsOf(index)==index,1);
                case 'transitioncount'
                    res=self.getTransitionCount(index);
                otherwise
                    error(message('Stateflow:reactive:InvalidStepProperty',stepName,property));
                end
            end
        end


        function res=findStep(self,varargin)
            p=inputParser;
            p.PartialMatching=false;
            p.addParameter('Name','',@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addParameter('RegExp','off',@(x)any(validatestring(x,{'on','off'})));
            p.addParameter('CaseSensitive','on',@(x)any(validatestring(x,{'on','off'})));
            p.addParameter('IsSubStepOf','',@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.parse(varargin{:});

            useRegExp=strcmp(p.Results.RegExp,'on');
            useCaseSensitive=strcmp(p.Results.CaseSensitive,'on');
            useName=~ismember('Name',p.UsingDefaults);
            useIsSubStepOf=~ismember('IsSubStepOf',p.UsingDefaults);
            if(useIsSubStepOf)
                if(~(self.isValidStep(p.Results.IsSubStepOf)))
                    error(message('Stateflow:reactive:UndefinedStep',p.Results.IsSubStepOf));
                end
                self.checkStepParent(p.Results.IsSubStepOf);
            end
            if(useRegExp)

                if(~useName)
                    error(message('Stateflow:reactive:MissingRegExpName'));
                end
            end

            stepList=self.getStepList();
            if useName
                if(useRegExp)
                    if(useCaseSensitive)

                        matchingSteps=cellfun(@(x)~isempty(regexp(x,p.Results.Name,'ONCE')),stepList);
                    else

                        matchingSteps=cellfun(@(x)~isempty(regexpi(x,p.Results.Name,'ONCE')),stepList);
                    end

                else
                    if(useCaseSensitive)

                        matchingSteps=cellfun(@(x)strcmp(p.Results.Name,x),stepList);
                    else

                        matchingSteps=cellfun(@(x)strcmpi(p.Results.Name,x),stepList);
                    end
                end
                res=stepList(matchingSteps);
            else

                res=stepList;
            end
            if useIsSubStepOf



                matchingSteps=cellfun(@(x)~isempty(regexp(x,['^',p.Results.IsSubStepOf,'\.[^\.]+$'],'once')),res);
                res=res(matchingSteps);
            end
        end

        function indentStep(self,stepName)
            if~self.isValidStep(stepName)
                error(message('Stateflow:reactive:UndefinedStep',stepName));
            end

            self.checkStepParent(stepName);
            index=self.getStepId(stepName);

            stateCell=self.sttManager.tableModel.getCellAtLocation(index,1);
            siblings=sf('find',self.sttManager.tableModel.stateCells,'.parent',stateCell.parent);
            if stateCell.cellObjectId==siblings(1)
                [~,parentName]=self.getStepAndParentNames(stepName);
                error(message('Stateflow:reactive:InvalidIndentStepFirstChild',stepName,parentName));
            end
            numSkipRows=self.viewManager.getNumRowsToSkip();
            self.viewManager.jsIndentState(index-numSkipRows);
        end

        function outdentStep(self,stepName)
            if~self.isValidStep(stepName)
                error(message('Stateflow:reactive:UndefinedStep',stepName));
            end
            self.checkStepParent(stepName);
            index=self.getStepId(stepName);

            stateCell=self.sttManager.tableModel.getCellAtLocation(index,1);
            parentCell=Stateflow.STT.StateCell(stateCell.parent);

            if~self.isUsingScenarios()
                if parentCell.rowType~=Stateflow.STT.RowType.STATE_ROW
                    error(message('Stateflow:reactive:InvalidOutdentStepNoParent',stepName));
                end
            else
                assert(parentCell.parent>0);
                grandParentCell=Stateflow.STT.StateCell(parentCell.parent);
                if grandParentCell.rowType~=Stateflow.STT.RowType.STATE_ROW
                    error(message('Stateflow:reactive:InvalidOutdentStepNoParent',stepName));
                end
            end

            siblings=sf('find',self.sttManager.tableModel.stateCells,'.parent',stateCell.parent);
            if stateCell.cellObjectId~=siblings(end)
                [~,parentName]=self.getStepAndParentNames(stepName);
                error(message('Stateflow:reactive:InvalidOutdentStepNotLastChild',stepName,parentName));
            end

            numSkipRows=self.viewManager.getNumRowsToSkip();
            self.viewManager.jsOutdentState(index-numSkipRows);
        end



        function addTransition(self,stepOrStruct,varargin)










            if isstruct(stepOrStruct)
                pStruct=inputParser;
                pStruct.addParameter('Step','',@(x)validateattributes(x,{'char'},{'nonempty'}));
                pStruct.addParameter('Condition','');
                pStruct.addParameter('NextStep','',@(x)validateattributes(x,{'char'},{'nonempty'}));
                pStruct.addParameter('Index',-1,@(x)validateattributes(x,{'numeric'},{'scalar','>',0}));
                pStruct.parse(stepOrStruct,varargin{:});
                stepName=pStruct.Results.Step;
                if(~ismember('Index',pStruct.UsingDefaults))
                    varargin={pStruct.Results.Condition,pStruct.Results.NextStep,pStruct.Results.Index};
                else
                    varargin={pStruct.Results.Condition,pStruct.Results.NextStep};
                end
            else
                stepName=stepOrStruct;
            end

            p=inputParser;

            p.addRequired('Step',@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addRequired('Condition');
            p.addRequired('NextStep',@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addOptional('Index',-1,@(x)validateattributes(x,{'numeric'},{'scalar','>',0}));
            p.parse(stepName,varargin{:});
            fromStep=p.Results.Step;

            if(~(self.isValidStep(fromStep)))
                error(message('Stateflow:reactive:UndefinedStep',fromStep));
            end

            [~,fromStepParent]=self.checkStepParent(fromStep);


            stateIndex=self.getStepId(fromStep);
            ccell=self.sttManager.tableModel.getCellAtLocation(stateIndex,Stateflow.STT.Constants.STATES_COLUMN_INDEX);
            if(ccell.isWhenChild)
                error(message('Stateflow:reactive:TransitionNotAllowOnWhenStepChild'));
            end

            nextStepName=p.Results.NextStep;
            if(~ismember('NextStep',p.UsingDefaults))



                self.isValidStep(nextStepName);
                [nextStepName,toStepParent]=self.checkStepParent(nextStepName);

                if(~strcmp(fromStepParent,toStepParent))
                    error(message('Stateflow:reactive:StepDepthDiffer',fromStepParent,toStepParent));
                end
            end


            condition=p.Results.Condition;


            index=p.Results.Index;
            if(~ismember('Index',p.UsingDefaults))




                if(index>self.getTransitionCount(stateIndex)+1)
                    error(message('Stateflow:reactive:InvalidTransitionIndex',index,fromStep));
                end
            end

            numSkipRows=self.viewManager.getNumRowsToSkip();
            self.viewManager.jsAddTransition(stateIndex-numSkipRows,index-1,self.trTransition(condition,nextStepName));

        end

        function deleteTransition(self,fromStep,transitionId)

            if(~(self.isValidStep(fromStep)))
                error(message('Stateflow:reactive:UndefinedStep',fromStep));
            end
            self.checkStepParent(fromStep);
            stepId=self.getStepId(fromStep);
            if(transitionId>self.getTransitionCount(stepId))
                error(message('Stateflow:reactive:InvalidTransitionIndex',transitionId,fromStep));
            end


            numSkipRows=self.viewManager.getNumRowsToSkip();
            self.viewManager.jsDeleteTransition(stepId-numSkipRows,transitionId-1);
        end

        function editTransition(self,stepName,transitionIndex,varargin)

            p=inputParser;




            p.addRequired('StepName',@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addRequired('TransitionIndex',@(x)validateattributes(x,{'numeric'},{'scalar','>',0}));



            p.addParameter('Step','');
            p.addParameter('Condition','');
            p.addParameter('NextStep','',@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addParameter('Index',-1,@(x)validateattributes(x,{'numeric'},{'scalar','>',0}));
            p.parse(stepName,transitionIndex,varargin{:});


            fromStep=p.Results.StepName;
            if(~(self.isValidStep(fromStep)))
                error(message('Stateflow:reactive:UndefinedStep',fromStep));
            end
            self.checkStepParent(fromStep);
            stepId=self.getStepId(fromStep);



            transitionId=p.Results.TransitionIndex;
            if(transitionId>self.getTransitionCount(stepId))
                error(message('Stateflow:reactive:InvalidTransitionIndex',transitionId,fromStep));
            end

            numSkipRows=self.viewManager.getNumRowsToSkip();


            if~ismember('Condition',p.UsingDefaults)
                self.viewManager.jsSetTransitionCondition(stepId-numSkipRows,transitionId-1,p.Results.Condition,false);
            end


            if~ismember('NextStep',p.UsingDefaults)
                stepDestination=p.Results.NextStep;

                if(~self.isValidStep(stepDestination))
                    error(message('Stateflow:reactive:UndefinedStep',stepDestination));
                end
                [nextStepName,~]=self.checkStepParent(stepDestination);
                self.checkAreInSameDepth(stepName,stepDestination);
                self.viewManager.jsSetTransitionDestination(stepId-numSkipRows,transitionId-1,nextStepName);
            end

            if~ismember('Index',p.UsingDefaults)

                newIndex=p.Results.Index;

                if(newIndex>self.getTransitionCount(stepId))
                    error(message('Stateflow:reactive:InvalidTransitionIndex',newIndex,fromStep));
                end
                if transitionId-1~=p.Results.Index-1
                    self.viewManager.jsReorderTransition(stepId-numSkipRows,transitionId-1,p.Results.Index-1);
                end
            end

        end

        function res=readTransition(self,stepName,transitionId,property)



            if(~self.isValidStep(stepName))
                error(message('Stateflow:reactive:UndefinedStep',stepName));
            end

            self.checkStepParent(stepName);
            stepId=self.getStepId(stepName);


            obj=self.sttManager.getCellAtLocation(stepId,transitionId+1);
            if(~isa(obj,'Stateflow.STT.TransitionCell')||isempty(obj.destinationState))
                error(message('Stateflow:reactive:InvalidTransitionIndex',transitionId,stepName));
            end
            ccell=self.sttManager.getCellAtLocation(stepId,Stateflow.STT.Constants.STATES_COLUMN_INDEX);


            destinationStateFullPath=self.getFullStepName(ccell.parent,obj.destinationState);

            if nargin<4
                res.Step=stepName;
                res.Index=transitionId;
                res.Condition=Stateflow.STT.Views.ReactiveViewManager.unwrapTransitionCondition(obj.condition);
                res.NextStep=destinationStateFullPath;
            else
                switch lower(property)
                case('condition')
                    res=Stateflow.STT.Views.ReactiveViewManager.unwrapTransitionCondition(obj.condition);
                case('nextstep')
                    res=destinationStateFullPath;
                case('step')
                    res=stepName;
                case('index')
                    res=transitionId;
                otherwise
                    error(message('Stateflow:reactive:InvalidTransitionProperty',property));
                end
            end

        end




        function res=findSymbol(self,varargin)


            p=inputParser;
            p.CaseSensitive=0;
            p.KeepUnmatched=0;
            p.PartialMatching=0;
            p.addParameter('Name','',@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addParameter('Kind','',@(x)any(validatestring(x,{'Data','Message','FunctionCall','Trigger'})));
            p.addParameter('Scope','',@(x)any(validatestring(x,{'Input','Output','Local','Constant','Parameter','Data Store Memory'})));
            p.addParameter('RegExp','off',@(x)any(validatestring(x,{'on','off'})));
            p.addParameter('CaseSensitive','on',@(x)any(validatestring(x,{'on','off'})));

            p.parse(varargin{:});
            useDefaultName=ismember('Name',p.UsingDefaults);
            useDefaultKind=ismember('Kind',p.UsingDefaults);
            useDefaultScope=ismember('Scope',p.UsingDefaults);
            useRegExp=strcmpi(p.Results.RegExp,'on');
            useCaseSensitive=strcmpi(p.Results.CaseSensitive,'on');

            if(useRegExp)

                if(useDefaultName)
                    error(message('Stateflow:reactive:MissingRegExpName'));
                end
            end

            if useDefaultKind
                kindList={{'-isa','Stateflow.Data',...
                '-or','-isa','Stateflow.FunctionCall',...
                '-or','-isa','Stateflow.Trigger',...
                '-or','-isa','Stateflow.Message'}};
            else
                kindList={'-isa',['Stateflow.',p.Results.Kind]};
            end

            if useDefaultScope
                scope={};
            else
                scope={'Scope',p.Results.Scope};
            end

            if useDefaultName||useRegExp||~useCaseSensitive


                name={};
            else
                name={'Name',p.Results.Name};
            end

            tmp=self.sttManager.parentChartUddH.find('-depth',1,name{:},scope{:},kindList{:});

            if~useCaseSensitive
                if useRegExp
                    tmp=tmp(arrayfun(@(x)(~isempty(regexpi(x.Name,p.Results.Name,'ONCE'))),tmp));
                else
                    tmp=tmp(arrayfun(@(x)strcmpi(x.Name,p.Results.Name),tmp));
                end
            else
                if useRegExp
                    tmp=tmp(arrayfun(@(x)(~isempty(regexp(x.Name,p.Results.Name,'ONCE'))),tmp));
                end
            end
            res={};
            for i=1:numel(tmp)
                res{end+1}=tmp(i).Name;%#ok<AGROW>
            end

        end

        function addSymbol(self,kind,scope,name)







            assert(~isempty(kind),'Error: Missing symbol kind',kind);
            assert(ismember(kind,{'Data','Message','Function Call','FunctionCall','Trigger'}),'Error: Kind %s is not a valid kind for Test Sequence symbols',kind);
            assert(~isempty(scope),'Error: Missing symbol scope',scope);
            assert(ismember(scope,{'Input','Output','Local','Constant','Parameter','Data Store Memory'}),'Error: Scope %s is not a valid scope for Test Sequence symbols',scope);
            assert(~isempty(name),'Error: Missing symbol name',name);

            if(~isvarname(name))
                error(message('Stateflow:reactive:InvalidSymbolName',name));
            end
            isValidSymbol=isempty(self.getSymbol(name));
            if~isValidSymbol
                error(message('Stateflow:reactive:SymbolRedefinition',name));
            end
            if strcmp(kind,'Message')&&~strcmp(scope,'Input')&&~strcmp(scope,'Output')
                error(message('Stateflow:reactive:InvalidMessageScope',scope));
            end
            if strcmp(kind,'Function Call')&&~strcmp(scope,'Output')
                error(message('Stateflow:reactive:InvalidFunctionCallScope',scope));
            end
            if strcmp(kind,'Trigger')&&~strcmp(scope,'Output')
                error(message('Stateflow:reactive:InvalidTriggerScope',scope));
            end
            self.viewManager.jsNewSymbol(lower(strrep(kind,' ','')),scope,name);
        end

        function editSymbol(self,nameOrStruct,varargin)

            if isstruct(nameOrStruct)
                if~(isempty(varargin))
                    error(message('Stateflow:reactive:NonUniqueStructParameter','symbol'));
                end

                if~isfield(nameOrStruct,'Name')
                    error(message('Stateflow:reactive:InvalidSymbolName',''));
                else
                    name=nameOrStruct.Name;
                    if isfield(nameOrStruct,'Kind')
                        nameOrStruct=rmfield(nameOrStruct,'Kind');
                    end

                    varargin={rmfield(nameOrStruct,'Name')};
                end
            else
                name=nameOrStruct;
            end
            if(~isvarname(name))
                error(message('Stateflow:reactive:InvalidSymbolName',name));
            end
            symbol=self.getSymbol(name);
            if(isempty(symbol))
                error(message('Stateflow:reactive:UndefinedSymbolName',name));
            end
            [properties,~,activeStep,scenarioParameter]=self.getSymbolProperties(symbol);
            p=inputParser;
            p.PartialMatching=false;


            for i=1:numel(properties)
                p.addParameter(properties{i},'');
            end

            p.parse(varargin{:});

            for i=1:numel(properties)
                if~ismember(properties{i},p.UsingDefaults)
                    value=p.Results.(properties{i});

                    prop=self.getSymbolDataPropertyPath(properties{i});
                    if(~isequal(value,eval(['symbol.',prop])))





                        if symbol.isReadonlyProperty(prop)&&~strcmp(properties{i},'InitialValue')&&~activeStep&&~scenarioParameter
                            if isstruct(nameOrStruct)
                                self.throwWarningWithoutBackTrace(message('Stateflow:reactive:ReadOnlySymbolProperty',properties{i},name));
                            else
                                error(message('Stateflow:reactive:ReadOnlySymbolProperty',properties{i},name));
                            end
                        else
                            try
                                if activeStep&&strcmp(properties{i},'Scope')&&~ismember(lower(value),{'local','output'})
                                    error(message('Stateflow:reactive:InvalidActiveStepDataScope',name));
                                elseif scenarioParameter&&~strcmp(properties{i},'Name')
                                    error(message('Stateflow:reactive:ReadOnlySymbolProperty',properties{i},name));
                                end
                                eval(['symbol.',prop,'= value ;']);
                            catch ME
                                throwAsCaller(addCause(MException(message('Stateflow:reactive:PropertyError',value,properties{i},name)),ME));
                            end



                            if~isequal(eval(['symbol.',prop]),value)
                                error(message('Stateflow:reactive:PropertyError',value,properties{i},name));
                            end
                        end
                    end
                end
            end
        end

        function res=readSymbol(self,name,property)


            if(~isvarname(name))
                error(message('Stateflow:reactive:InvalidSymbolName',name));
            end
            symbol=self.getSymbol(name);
            if(isempty(symbol))
                error(message('Stateflow:reactive:UndefinedSymbolName',name));
            end

            [properties,kind]=self.getSymbolProperties(symbol);
            if(nargin<3)

                res.Kind=kind;
                res.Scope=symbol.Scope;
                for k=1:numel(properties)
                    prop=self.getSymbolDataPropertyPath(properties{k});
                    res.(properties{k})=eval(['symbol.',prop]);
                end
            else

                if(strcmpi(property,'Kind'))
                    res=kind;
                else
                    if(strcmpi(property,'Scope'))
                        res=symbol.Scope;
                    else
                        if(~ismember(lower(properties),lower(property)))
                            error(message('Stateflow:reactive:InvalidSymbolProperty',name,property));
                        end
                        prop=self.getSymbolDataPropertyPath(property);



                        res=eval(['symbol.',prop]);
                    end
                end
            end
        end

        function deleteSymbol(self,name)

            if(~isvarname(name))
                error(message('Stateflow:reactive:InvalidSymbolName',name));
            end
            if(isempty(self.getSymbol(name)))
                error(message('Stateflow:reactive:UndefinedSymbolName',name));
            end
            symbol=self.getSymbol(name);
            [~,~,~,scenarioParameter]=self.getSymbolProperties(symbol);
            if scenarioParameter
                error(message('Stateflow:reactive:DeleteScenarioParameter',name));
            end
            self.viewManager.jsDeleteSymbol(name);
        end

    end

    methods(Static,Access=private)

        function[properties,kind,activeStep,scenarioParameter]=getSymbolProperties(symbol)
            persistent symbolPropertiesMap
            if isempty(symbolPropertiesMap)

                common={'Description','Document','Name','Tag','Scope'};


                symbolPropertiesMap.OutputTrigger=[common,{'Port'}];
                symbolPropertiesMap.OutputFunctionCall=[common,{'Port'}];
                symbolPropertiesMap.OutputMessage=[common,{'Port','DataType','Priority','Size','IsComplex','InitialValue'}];
                symbolPropertiesMap.OutputData=[common,{'Port','DataType','TestPoint','Size','InitialValue','VariableSize','RangeMinimum','RangeMaximum','IsComplex','Unit'}];
                symbolPropertiesMap.InputData=[common,{'Port','DataType','VariableSize','RangeMinimum','RangeMaximum','Size','IsComplex','Unit'}];
                symbolPropertiesMap.InputMessage=[common,{'Port','DataType','MessagePriorityOrder','Priority','QueueCapacity','QueueOverflowDiagnostic','QueueType','Size'}];
                symbolPropertiesMap.LocalData=[common,{'DataType','InitializeMethod','TestPoint','InitialValue','VariableSize','ResolveToSignalObject','RangeMinimum','RangeMaximum','Size','IsComplex'}];
                symbolPropertiesMap.ConstantData=[common,{'DataType','InitialValue','Size'}];
                symbolPropertiesMap.ParameterData=[common,{'DataType','Size','IsComplex'}];
                symbolPropertiesMap.DataStoreMemoryData=common;
                symbolPropertiesMap.OutputDataActiveStep=[common,{'Port','TestPoint','ActiveStepEnumName'}];
                symbolPropertiesMap.LocalDataActiveStep=[common,{'TestPoint','ActiveStepEnumName'}];
                for f=fieldnames(symbolPropertiesMap)'
                    symbolPropertiesMap.(f{:})=sort(symbolPropertiesMap.(f{:}));
                end
            end
            scope=symbol.Scope;
            if strcmp(scope,'Data Store Memory')
                scope='DataStoreMemory';
            end
            kind=extractAfter(class(symbol),'.');
            key=[scope,kind];
            activeStep=strcmp(kind,'Data')&&~isempty(symbol.OutputState);
            if activeStep
                key=[key,'ActiveStep'];
            end
            scenarioParameter=strcmp(kind,'Data')&&sf('get',symbol.id,'.props.isScenario');
            properties=symbolPropertiesMap.(key);
        end

        function label=unwrapStepLabel(l)

            [~,label]=strtok(l,char(10));
            if~isempty(label)
                if numel(label)==1
                    label='';
                else
                    label(1)=[];
                end
            end
        end

        function throwWarningWithoutBackTrace(w)
            prev=warning('off','backtrace');
            warning(w);
            warning(prev);
        end
    end

end
