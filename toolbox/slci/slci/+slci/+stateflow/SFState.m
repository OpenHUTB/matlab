




classdef SFState<slci.common.BdObject


    properties(Access=private)
        fEntryActionAST=[];
        fDuringActionAST=[];
        fExitActionAST=[];
        fParent=[];
        fFlag=0;
        fSfId=-1;
        fSubstates=[];
        fSubstateIndex=-1;
        fParallelDecomposition=false;
        fDefaultTransitions=[];
        fInnerTransitions=[];
        fOuterTransitions=[];
        fDefaultCfg=[];
        fOuterCfg=[];
        fInnerCfg=[];
        fName='';
        fSLFunctionHandles=[];
        fNeedConstraints=true;


        fProperties=[];


        fIsRecursive=false;

        fInputStatesToSendFuncMap=[];
    end

    methods(Access=private)


        function populateSendFuncCallGraph(aObj,actionAst)
            children=actionAst.getChildren();

            for i=1:numel(children)
                if isa(children{i},'slci.ast.SFAstSendFunction')
                    sendAst=children{i};
                    childrenOfSend=sendAst.getChildren();
                    destId=[];
                    for j=1:numel(childrenOfSend)
                        if isa(childrenOfSend{j},'slci.ast.SFAstIdentifier')
                            identifierAst=childrenOfSend{j};
                            destId=identifierAst.getId();
                            break;
                        end
                    end
                    if~isempty(destId)
                        aObj.ParentChart.addSendFunctionCallEdge(aObj.getSfId(),destId);
                    end
                else
                    aObj.populateSendFuncCallGraph(children{i});
                end
            end
        end

    end

    methods


        function out=getName(aObj)
            out=aObj.fName;
        end


        function out=getDecomposition(aObj)
            out=aObj.fProperties.getProperty('Decomposition');
        end


        function out=getType(aObj)
            out=aObj.fProperties.getProperty('Type');
        end


        function out=getSLFunctionHandles(aObj)
            out=aObj.fSLFunctionHandles;
        end


        function out=getSubstates(aObj)
            out=aObj.fSubstates;
        end


        function out=getSubstateIndex(aObj)
            out=aObj.fSubstateIndex;
        end


        function setSubstateIndex(aObj,aIndex)
            aObj.fSubstateIndex=aIndex;
        end


        function AddSubstate(aObj,aSubstate)
            if isempty(aObj.fSubstates)
                aObj.fSubstates=aSubstate;
            else
                aObj.fSubstates(end+1)=aSubstate;
            end
        end


        function out=getSfId(aObj)
            out=aObj.fSfId;
        end


        function setSfId(aObj,aSfId)
            aObj.fSfId=aSfId;
        end


        function out=getDefaultCfg(aObj)
            out=aObj.fDefaultCfg;
        end


        function setDefaultCfg(aObj,aDefaultCfg)
            aObj.fDefaultCfg=aDefaultCfg;
        end


        function out=getInnerCfg(aObj)
            out=aObj.fInnerCfg;
        end


        function setInnerCfg(aObj,aInnerCfg)
            aObj.fInnerCfg=aInnerCfg;
        end


        function out=getOuterCfg(aObj)
            out=aObj.fOuterCfg;
        end


        function setOuterCfg(aObj,aOuterCfg)
            aObj.fOuterCfg=aOuterCfg;
        end


        function out=getFlag(aObj)
            out=aObj.fFlag;
        end


        function setFlag(aObj,aFlag)
            aObj.fFlag=aFlag;
        end


        function CreateCfgs(aObj)

            if aObj.hasDefaultTransitions()...
                ||~isempty(aObj.getSubstates())
                aObj.fDefaultCfg=slci.stateflow.Cfg(aObj,'default');
            end
            transitions=aObj.getInnerTransitions();
            if~isempty(transitions)
                aObj.fInnerCfg=slci.stateflow.Cfg(aObj,'inner');
            end
            transitions=aObj.getOuterTransitions();
            if~isempty(transitions)
                aObj.fOuterCfg=slci.stateflow.Cfg(aObj,'outer');
            end
        end


        function BuildTransitionLists(aObj)
            stateObj=aObj.getUDDObject;
            transitionObjs=stateObj.defaultTransitions;
            for idx=1:numel(transitionObjs)
                id=transitionObjs(idx).Id;
                transition=aObj.ParentChart.getTransitionFromId(id);
                assert(~isempty(transition));
                aObj.AddDefaultTransition(transition);
            end
            transitionObjs=stateObj.outerTransitions;
            for idx=1:numel(transitionObjs)
                id=transitionObjs(idx).Id;
                transition=aObj.ParentChart.getTransitionFromId(id);
                assert(~isempty(transition));
                aObj.AddOuterTransition(transition);
            end
            transitionObjs=stateObj.innerTransitions;
            for idx=1:numel(transitionObjs)
                id=transitionObjs(idx).Id;
                transition=aObj.ParentChart.getTransitionFromId(id);
                assert(~isempty(transition));
                aObj.AddInnerTransition(transition);
            end
        end


        function out=hasDefaultTransitions(aObj)
            out=~isempty(aObj.fDefaultTransitions);
        end


        function out=getDefaultTransitions(aObj)
            out=aObj.fDefaultTransitions;
        end


        function AddDefaultTransition(aObj,aDefaultTransition)
            if isempty(aObj.fDefaultTransitions)
                aObj.fDefaultTransitions=aDefaultTransition;
            else
                aObj.fDefaultTransitions(end+1)=aDefaultTransition;
            end
        end


        function out=getInnerTransitions(aObj)
            out=aObj.fInnerTransitions;
        end


        function AddInnerTransition(aObj,aInnerTransition)
            if isempty(aObj.fInnerTransitions)
                aObj.fInnerTransitions=aInnerTransition;
            else
                aObj.fInnerTransitions(end+1)=aInnerTransition;
            end
        end


        function out=getOuterTransitions(aObj)
            out=aObj.fOuterTransitions;
        end


        function AddOuterTransition(aObj,aOuterTransition)
            if isempty(aObj.fOuterTransitions)
                aObj.fOuterTransitions=aOuterTransition;
            else
                aObj.fOuterTransitions(end+1)=aOuterTransition;
            end
        end



        function out=getEntryActionAST(aObj)
            if~isempty(aObj.fEntryActionAST)&&...
                aObj.fEntryActionAST.ContainsExecutable()
                out=aObj.fEntryActionAST;
            else
                out=[];
            end
        end



        function out=getDuringActionAST(aObj)
            if~isempty(aObj.fDuringActionAST)&&...
                aObj.fDuringActionAST.ContainsExecutable()
                out=aObj.fDuringActionAST;
            else
                out=[];
            end
        end



        function out=getExitActionAST(aObj)
            if~isempty(aObj.fExitActionAST)&&...
                aObj.fExitActionAST.ContainsExecutable()
                out=aObj.fExitActionAST;
            else
                out=[];
            end
        end

        function out=getASTs(aObj)
            out={};
            if~isempty(aObj.fEntryActionAST)
                out{end+1}=aObj.fEntryActionAST;
            end
            if~isempty(aObj.fDuringActionAST)
                out{end+1}=aObj.fDuringActionAST;
            end
            if~isempty(aObj.fExitActionAST)
                out{end+1}=aObj.fExitActionAST;
            end
        end


        function out=NonEmptyCfgs(aObj)
            out={};
            defaultCfg=aObj.getDefaultCfg;
            if~isempty(defaultCfg)
                out{end+1}=defaultCfg;
            end
            innerCfg=aObj.getInnerCfg;
            if~isempty(innerCfg)
                out{end+1}=innerCfg;
            end
            outerCfg=aObj.getOuterCfg;
            if~isempty(outerCfg)
                out{end+1}=outerCfg;
            end
        end


        function out=ParentChart(aObj)
            if isa(aObj.fParent,'slci.stateflow.SFState')
                out=aObj.fParent.ParentChart();
            else
                assert(isa(aObj.fParent,'slci.stateflow.Chart'))
                out=aObj.fParent;
            end
        end


        function out=ParentState(aObj)
            if isa(aObj.fParent,'slci.stateflow.SFState')
                out=aObj.fParent;
            else
                out=[];
            end
        end


        function out=getParent(aObj)
            out=aObj.fParent;
        end


        function setParent(aObj,aParent)
            aObj.fParent=aParent;
        end


        function out=ParentBlock(aObj)
            out=aObj.ParentChart().ParentBlock();
        end


        function out=ParentModel(aObj)
            out=aObj.ParentBlock().ParentModel();
        end


        function out=getParallelDecomposition(aObj)
            out=aObj.fParallelDecomposition;
        end


        function setParallelDecomposition(aObj,aValue)
            aObj.fParallelDecomposition=aValue;
        end


        function SortSubstates(aObj)
            numSubstates=numel(aObj.fSubstates);
            if numSubstates>0
                parentChart=aObj.ParentChart();
                aObj.fSubstates=parentChart.getSortedStates(...
                aObj.fSubstates,aObj.getUDDObject);
                for i=1:numSubstates
                    aObj.fSubstates(i).setSubstateIndex(i);
                end
            end
        end


        function setStateScopeSLFunctions(aObj)

            path=aObj.ParentChart.Path;
            aStateUDDObj=aObj.getUDDObject;
            slFunctions=slci.internal.getSFActiveObjs(...
            aStateUDDObj.find('-isa','Stateflow.SLFunction'));
            for i=1:numel(slFunctions)
                name=sf('get',slFunctions(i).Id,'.simulink.blockName');
                fnName=[path,'/',name];

                fnName=strrep(fnName,'\n',sprintf('\n'));


                value=get_param(fnName,'Handle');
                aObj.fSLFunctionHandles=[aObj.fSLFunctionHandles,value];
            end
        end


        function buildSendFunctionCallGraph(aObj)
            asts=aObj.getASTs();
            for i=1:numel(asts)
                aObj.populateSendFuncCallGraph(asts{i});
            end


            if~isempty(aObj.ParentState())&&~isempty(aObj.ParentChart())
                aObj.ParentChart.addSendFunctionCallEdge(aObj.ParentState().getSfId(),aObj.getSfId());
            end
        end


        function setRecursive(aObj,aCallGraph)
            aObj.fIsRecursive=aCallGraph.isRecursive(aObj.getSID());



            if~isempty(aObj.fInputStatesToSendFuncMap)&&...
                ~aObj.fIsRecursive&&...
                ~isa(aObj.getParent,'slci.stateflow.Chart')&&...
                ~aObj.fParallelDecomposition
                subStatesName=arrayfun(@(x)x.getName,...
                aObj.getParent.getSubstates,'UniformOutput',false);
                connectedStatesName=[subStatesName,aObj.getParent.getName];
                aObj.fIsRecursive=any(arrayfun(@(x)strcmp(aObj.getName,x),...
                connectedStatesName));
            end
        end


        function out=isRecursive(aObj)
            out=aObj.fIsRecursive;
        end


        function createAST(aObj)
            astObjContainer=Stateflow.Ast.getContainer(aObj.getUDDObject);
            astObjSections=astObjContainer.sections;
            for i=1:numel(astObjSections)
                section=astObjSections{i};
                if isa(section,'Stateflow.Ast.EntrySection')
                    aObj.fEntryActionAST=slci.internal.createStateflowAst(section,aObj);
                elseif isa(section,'Stateflow.Ast.DuringSection')
                    aObj.fDuringActionAST=slci.internal.createStateflowAst(section,aObj);
                elseif isa(section,'Stateflow.Ast.ExitSection')
                    aObj.fExitActionAST=slci.internal.createStateflowAst(section,aObj);
                end
            end
        end


        function mapInputStatesToSendFuncMap(aObj,aDestStateName,aSendFuncName)
            if(aObj.fInputStatesToSendFuncMap.isKey(aDestStateName))
                val=[aObj.fInputStatesToSendFuncMap(aDestStateName),aSendFuncName];
                aObj.fInputStatesToSendFuncMap(aDestStateName)=unique(val);
            else
                aObj.fInputStatesToSendFuncMap(aDestStateName)={aSendFuncName};
            end
        end


        function aObj=SFState(aStateUDDObj,addConstraints)
            aObj.fSfId=aStateUDDObj.Id;
            aObj.fClassName=DAStudio.message('Slci:compatibility:ClassNameState');
            aObj.fClassNames=DAStudio.message('Slci:compatibility:ClassNameStates');
            aObj.fNeedConstraints=addConstraints;
            aObj.fName=aStateUDDObj.Name;
            aObj.setUDDObject(aStateUDDObj);
            aObj.setParallelDecomposition(strcmpi(aStateUDDObj.Type,'AND'));

            aObj.populateStateProperties(aStateUDDObj);



            aObj.fInputStatesToSendFuncMap=containers.Map('KeyType','char','ValueType','any');

            if aObj.needConstraints

                aObj.addConstraint(slci.compatibility.StateflowActionOperationsConstraint);

                aObj.addConstraint(slci.compatibility.StateflowEnumOperationsConstraint);

                aObj.addConstraint(slci.compatibility.StateflowCustomDataConstraint);

                aObj.addConstraint(slci.compatibility.StateflowTimeConstraint);

                aObj.addConstraint(slci.compatibility.StateflowContextSensitiveConstantConstraint);

                aObj.addConstraint(slci.compatibility.StateflowMixedTypeConstraint);

                aObj.addConstraint(slci.compatibility.StateflowInvalidOperandTypeConstraint);

                aObj.addConstraint(slci.compatibility.UniqueDefaultTransitionConstraint);
                if(slcifeature('SfLoopSupport')==0)


                    acyclicConstraint=slci.compatibility.AcyclicControlFlowConstraint;
                    aObj.addConstraint(acyclicConstraint);
                    structuredConstraint=slci.compatibility.StructuredControlFlowConstraint;
                    structuredConstraint.addPreRequisiteConstraint(acyclicConstraint);
                    aObj.addConstraint(structuredConstraint);
                end

                aObj.addConstraint(slci.compatibility.UnsupportedTransitionPathsConstraint);

                aObj.addConstraint(slci.compatibility.StateflowNumArgumentsConstraint);

                aObj.addConstraint(slci.compatibility.StateflowStateOutputMonitoringConstraint);

                aObj.addConstraint(slci.compatibility.StateflowDefaultTransitionConstraint);

                aObj.addConstraint(slci.compatibility.StateflowArrayIndexTypeConstraint);

                aObj.addConstraint(slci.compatibility.StateflowArrayDimensionsConstraint);

                aObj.addConstraint(slci.compatibility.StateflowGraphicalFunctionUnusedOutputConstraint);

                aObj.addConstraint(slci.compatibility.StateflowStateInlineOptionConstraint);


                aObj.addConstraint(slci.compatibility.StateflowSimulinkFunctionInputDimensionConstraint);


                aObj.addConstraint(slci.compatibility.StateflowSimulinkFunctionInputDatatypeConstraint);


                aObj.addConstraint(slci.compatibility.StateflowGraphicalFunctionInputDatatypeConstraint);

                aObj.addConstraint(slci.compatibility.StateflowGraphicalFunctionInputDimensionConstraint);


                aObj.addConstraint(slci.compatibility.StateflowTruthTableInputDatatypeConstraint);


                aObj.addConstraint(slci.compatibility.StateflowTruthTableInputDimensionConstraint);


                aObj.addConstraint(slci.compatibility.StateflowMisraXorConstraint);

                aObj.addConstraint(slci.compatibility.StateflowRecursiveStateConstraint);

                aObj.addConstraint(slci.compatibility.StateflowStateActivityLoggingConstraint);

                aObj.addConstraint(slci.compatibility.StateflowAtomicSubchartWithinStateConstraint);
            end
        end


        function out=needConstraints(aObj)
            out=aObj.fNeedConstraints;
        end

    end

    methods(Access=private)

        function populateStateProperties(aObj,aStateUDDObject)
            aObj.fProperties=slci.common.ObjectProp;


            aObj.fProperties.setProperty('Decomposition',...
            aStateUDDObject.Decomposition);

            aObj.fProperties.setProperty('Type',...
            aStateUDDObject.Type);
        end
    end
end


