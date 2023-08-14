




classdef Chart<slci.common.BdObject

    properties(Access=private)
        fCfg=[];
        fSfId=-1;
        fDefaultTransitions=[];
        fSFAsts={};
        fTransitions=[];
        fTransitionMap=[];
        fJunctions=[];
        fJunctionMap=[];
        fStates=[];
        fStateMap=[];
        fData=[];
        fNameIdMap=[];
        fDataMap=[];
        fEvents=[];
        fEventMap=[];
        fPath='';
        fBlock=[];
        fHasFatalIncompatibility=false;
        fHasIncompatibility=false;
        fSubstates=[];
        fSLFunctionsMap=[];
        fSLFuncSfIdMap=[];
        fGraphicalFunctions=[];
        fGraphicalFunctionsMap=[];
        fSFFuncNamesMap=[];
        fHasSameFuncName=false;
        fDummySFFunctions='';
        fTruthTables=[];
        fTruthTablesMap=[];
        fDataNameMap=[];
        fOutputDataNameMap=[];
        fEntryOrExitPort=[];
        fAtomicSubcharts=[];
        fParentAtomicSubcharts=[];
        fAtomicSubchartMap=[];
        fIsChartAnAtomicSubchart=false;


        fActionLanguage='';
        fExportChartFunctions=false;
        fExecuteAtInitialization=false;
        fSupportVariableSizing=false;
        fChartUpdate='';
        fSaturateOnIntegerOverflow=false;


        fSfFnCallMap=[];


        fCache=[];
        fTransToSendFuncDestMap=[];
        fSfSendFuncCallGraph=[];


        fCycles={};


        fJunctionToCfgMap=[];


        fInductionVariablesList={};


        fProperties=[];


        fHasUnstructuredGraph=false;



        fSFObjOrderMap;
        fSFObjOrder;
    end

    methods



        function out=getStateflowSID(aObj,sfObj,parentPath)
            if isa(aObj,'slci.stateflow.SFAtomicSubchart')
                out=Simulink.ID.getStateflowSID(sfObj);
            else
                out=Simulink.ID.getStateflowSID(sfObj,...
                parentPath);
            end
        end


        function out=hasLocalEvents(aObj)
            out=any(arrayfun(@(x)(x.isLocalEvent()),aObj.getEvents()));
        end


        function out=hasUnstructuredCfg(aObj)
            out=aObj.fHasUnstructuredGraph;
        end


        function setIsChartAnAtomicSubchart(aObj,aBlkHdl)
            chartId=sfprivate('block2chart',aBlkHdl);
            childChartUDDObj=idToHandle(sfroot,chartId);
            parentChartObj=childChartUDDObj.getParent();



            if isa(childChartUDDObj,class(parentChartObj))
                aObj.fIsChartAnAtomicSubchart=true;
            end
        end


        function out=isAtomicSubchart(aObj)
            out=aObj.fIsChartAnAtomicSubchart;
        end


        function out=getDecomposition(aObj)
            out=aObj.fProperties.getProperty('Decomposition');
        end


        function out=getSfCCResultsFileName(aObj)%#ok
            conf=Simulink.fileGenControl('getConfig');
            pathName=conf.CacheFolder;
            if isempty(pathName)
                pathName=pwd;
            end

            fileName='SfCompatibilityCheckData.mat';
            out=fullfile(pathName,fileName);
        end


        function out=getInductionVariablesList(aObj)
            out=aObj.fInductionVariablesList;
        end


        function out=getCfgFromJunctionToCfgMap(aObj,aSfId)
            out=aObj.fJunctionToCfgMap(aSfId);
        end


        function out=hasJunctionInJunctionCfgMap(aObj,aSfId)
            out=aObj.fJunctionToCfgMap.isKey(aSfId);
        end


        function mapJunctionAndCfg(aObj,aSfId,aCfg)
            if aObj.hasJunctionInJunctionCfgMap(aSfId)
                cfgs=aObj.fJunctionToCfgMap(aSfId);
                cfgs(end+1)=aCfg;
            else
                cfgs=aCfg;
            end

            aObj.fJunctionToCfgMap(aSfId)=cfgs;
        end

        function out=getSfId(aObj)
            out=aObj.fSfId;
        end


        function out=hasAtomicSubchart(aObj,aId)
            out=false;
            if~isempty(aObj.fAtomicSubchartMap)
                out=isKey(aObj.fAtomicSubchartMap,aId);
            end
        end


        function out=getAtomicSubchartFromId(aObj,aId)
            assert(aObj.hasAtomicSubchart(aId),...
            sprintf('Atomic Subchart %d: does not exist in fAtomicSubchartMap',aId));
            out=aObj.fAtomicSubchartMap(aId);
        end



        function setChartObjsOrderMap(aObj)
            sfObjId=sf('SubstatesOf',aObj.fSfId);
            for idx=1:numel(sfObjId)
                aObj.fSFObjOrderMap(sfObjId(idx))=idx;
            end
        end


        function out=getChartObjsOrderMap(aObj,aSfId)
            assert(isKey(aObj.fSFObjOrderMap,aSfId));
            out=aObj.fSFObjOrderMap(aSfId);

        end


        function out=getChartObjsOrder(aObj)
            out=aObj.fSFObjOrder;
        end


        function out=hasState(aObj,aId)
            out=isKey(aObj.fStateMap,aId);
        end

        function out=getStateFromId(aObj,aId)
            assert(aObj.hasState(aId),...
            sprintf('State %d: does not exist in fStateMap',aId));
            out=aObj.fStateMap(aId);
        end

        function out=hasTransition(aObj,aId)
            out=isKey(aObj.fTransitionMap,aId);
        end

        function out=getTransitionFromId(aObj,aId)
            assert(aObj.hasTransition(aId),...
            sprintf('Transition %d: does not exist in fTransitionMap',aId));
            out=aObj.fTransitionMap(aId);
        end

        function out=hasJunction(aObj,aId)
            out=isKey(aObj.fJunctionMap,aId);
        end

        function out=getJunctionFromId(aObj,aId)
            assert(aObj.hasJunction(aId),...
            sprintf('Junction %d: does not exist in fJunctionMap',aId));
            out=aObj.fJunctionMap(aId);
        end

        function out=getHasFatalIncompatibility(aObj)
            out=aObj.fHasFatalIncompatibility;
        end

        function setHasFatalIncompatibility(aObj,aHasFatalIncompatibility)
            aObj.fHasFatalIncompatibility=aHasFatalIncompatibility;
        end

        function out=getHasIncompatibility(aObj)
            out=aObj.fHasIncompatibility;
        end

        function setHasIncompatibility(aObj,aHasIncompatibility)
            aObj.fHasIncompatibility=aHasIncompatibility;
        end


        function out=hasCycles(aObj)
            out=~isempty(aObj.fCycles);
        end


        function out=getCycles(aObj)
            out=aObj.fCycles;
        end

        function out=checkCompatibility(aObj)
            out=[];
            out=[out,checkCompatibility@slci.common.BdObject(aObj)];
            for idx=1:numel(aObj.fStates)
                out=[out,aObj.fStates(idx).checkCompatibility()];%#ok
            end
            for idx=1:numel(aObj.fTransitions)
                out=[out,aObj.fTransitions(idx).checkCompatibility()];%#ok
            end
            for idx=1:numel(aObj.fJunctions)
                out=[out,aObj.fJunctions(idx).checkCompatibility()];%#ok
            end
            for idx=1:numel(aObj.fEvents)
                out=[out,aObj.fEvents(idx).checkCompatibility()];%#ok
            end
            for idx=1:numel(aObj.fData)
                out=[out,aObj.fData(idx).checkCompatibility()];%#ok
            end
            for idx=1:numel(aObj.fGraphicalFunctions)
                out=[out,aObj.fGraphicalFunctions(idx).checkCompatibility()];%#ok
            end
            for idx=1:numel(aObj.fTruthTables)
                out=[out,aObj.fTruthTables(idx).checkCompatibility()];%#ok
            end
        end

        function out=NonEmptyCfgs(aObj)
            out={};
            if~isempty(aObj.fCfg)
                out{end+1}=aObj.fCfg;
            end
        end

        function out=getCfg(aObj)
            out=aObj.fCfg;
        end

        function out=getExecuteAtInitialization(aObj)
            out=aObj.fExecuteAtInitialization;
        end

        function out=getActionLanguage(aObj)
            out=aObj.fProperties.getProperty('ActionLanguage');
        end

        function out=getExportChartFunctions(aObj)
            out=aObj.fExportChartFunctions;
        end

        function out=getSupportVariableSizing(aObj)
            out=aObj.fSupportVariableSizing;
        end

        function out=getChartUpdate(aObj)
            out=aObj.fChartUpdate;
        end

        function out=getSaturateOnIntegerOverflow(aObj)
            out=aObj.fSaturateOnIntegerOverflow;
        end


        function out=getSFAsts(aObj)
            out=aObj.fSFAsts;
        end

        function out=getTransitions(aObj)
            out=aObj.fTransitions;
        end

        function out=getStates(aObj)
            out=aObj.fStates;
        end

        function out=getSubstates(aObj)
            out=aObj.fSubstates;
        end


        function out=getAtomicSubcharts(aObj)
            out=aObj.fAtomicSubcharts;
        end


        function out=getParentAtomicSubcharts(aObj)
            out=aObj.fParentAtomicSubcharts;
        end


        function out=getJunctions(aObj)
            out=[aObj.fJunctions,aObj.fEntryOrExitPort];
        end

        function out=getData(aObj)
            out=aObj.fData;
        end


        function out=getNameIdMap(aObj)
            out=aObj.fNameIdMap;
        end


        function out=getDataNameMap(aObj)
            out=aObj.fDataNameMap;
        end


        function out=getOutputDataNameMap(aObj)
            out=aObj.fOutputDataNameMap;
        end


        function qualifiedName=findQualifiedName(aObj,key)
            qualifiedName='';
            dataNameMap=aObj.getDataNameMap;
            outputDataNameMap=aObj.getOutputDataNameMap;
            if isKey(outputDataNameMap,key)
                qualifiedName=outputDataNameMap(key);
            elseif isKey(dataNameMap,key)
                qualifiedName=dataNameMap(key);
            end
        end


        function out=getDataObject(aObj,aSfId)
            dataUDDObj=idToHandle(sfroot,aSfId);
            dataObjPath=aObj.fPath;
            dataSID=aObj.getStateflowSID(dataUDDObj,dataObjPath);
            out=aObj.fDataMap(dataSID);
        end


        function out=IsDataObject(aObj,aSfId)
            if(~isempty(aObj.fDataMap.keys))&&...
                (aSfId~=0)
                dataUDDObj=idToHandle(sfroot,aSfId);





                if dataUDDObj.SSIdNumber~=0
                    dataObjPath=aObj.fPath;
                    dataSID=aObj.getStateflowSID(dataUDDObj,dataObjPath);
                    out=aObj.fDataMap.isKey(dataSID);
                else
                    out=false;
                end
            else
                out=false;
            end
        end

        function out=getEvents(aObj)
            out=aObj.fEvents;
        end


        function out=getNumSLFunctions(aObj)
            out=numel(aObj.fSLFunctionsMap.keys);
        end

        function out=getSLFunction(aObj,aFnPath)
            key=get_param(aFnPath,'SID');
            out=aObj.fSLFunctionsMap(key);
        end


        function out=getSLFunctionUsingSID(aObj,aSID)
            out=aObj.fSLFunctionsMap(aSID);
        end


        function out=getSLFuncSfIdMap(aObj)
            out=aObj.fSLFuncSfIdMap;
        end


        function out=isSFSLFunction(aObj,aFnPath)
            if~isempty(aObj.fSLFunctionsMap.keys)
                fnSID=get_param(aFnPath,'SID');
                out=aObj.fSLFunctionsMap.isKey(fnSID);
            else
                out=false;
            end
        end

        function out=getGraphicalFunctions(aObj)
            out=aObj.fGraphicalFunctions;
        end


        function out=getGraphicalFunctionsMap(aObj)
            out=aObj.fGraphicalFunctionsMap;
        end


        function out=getTruthTablesMap(aObj)
            out=aObj.fTruthTablesMap;
        end

        function out=getSFFuncNamesMap(aObj)
            out=aObj.fSFFuncNamesMap;
        end


        function out=hasSameFuncName(aObj)
            out=aObj.fHasSameFuncName;
        end

        function out=getGraphicalFunctionObject(aObj,aFnSfId)
            gfnUDDObj=idToHandle(sfroot,aFnSfId);
            gfnSID=aObj.getStateflowSID(gfnUDDObj,...
            gfnUDDObj.Chart.Path);
            out=aObj.fGraphicalFunctionsMap(gfnSID);
        end


        function out=getDummySFFunctions(aObj)
            out=aObj.fDummySFFunctions;
        end




        function out=createDummySFFunction(aObj,fnObj)
            out=['function ',fnObj.LabelString,newline,'end',newline];
        end

        function out=IsGraphicalFunction(aObj,aFnSfId)
            if(~isempty(aObj.fGraphicalFunctionsMap.keys))&&...
                (aFnSfId~=0)
                gfnUDDObj=idToHandle(sfroot,aFnSfId);
                gfnSID=aObj.getStateflowSID(gfnUDDObj,...
                gfnUDDObj.Chart.Path);
                out=aObj.fGraphicalFunctionsMap.isKey(gfnSID);
            else
                out=false;
            end
        end

        function setAdjacentFunction(aObj,aParentGfSfId,aChildGfSfId)
            aObj.fSfFnCallMap.addDirectedEdge(aParentGfSfId,aChildGfSfId);
        end


        function addSendFunctionCallEdge(aObj,aCallerSfId,aCalleeSfId)
            aObj.fSfSendFuncCallGraph.addDirectedEdge(aCallerSfId,aCalleeSfId);
        end


        function mapTransToSendFnDest(aObj,aTransSfId,aStateSfId)
            if(aObj.fTransToSendFuncDestMap.isKey(aTransSfId))
                val=aObj.fTransToSendFuncDestMap(aTransSfId);
                val(end+1)=aStateSfId;
                aObj.fTransToSendFuncDestMap(aTransSfId)=unique(val);
            else
                aObj.fTransToSendFuncDestMap(aTransSfId)=aStateSfId;
            end
        end



        function out=getTruthTables(aObj)
            out=aObj.fTruthTables;
        end


        function out=getTruthTableObject(aObj,aTblSfId)
            tblUDDObj=idToHandle(sfroot,aTblSfId);
            tblSID=aObj.getStateflowSID(tblUDDObj,...
            tblUDDObj.Chart.Path);
            out=aObj.fTruthTablesMap(tblSID);
        end


        function out=IsTruthTable(aObj,aTblSfId)
            out=false;
            if(~isempty(aObj.fTruthTablesMap.keys))&&...
                (aTblSfId~=0)
                tblUDDObj=idToHandle(sfroot,aTblSfId);
                tblSID=aObj.getStateflowSID(tblUDDObj,...
                tblUDDObj.Chart.Path);
                out=aObj.fTruthTablesMap.isKey(tblSID);
            end
        end


        function addSFAst(aObj,aSFAst)
            aObj.fSFAsts=[aObj.fSFAsts,{aSFAst}];
        end



        function AddAtomicSubchart(aObj,aAtomicSubchart)
            if isempty(aObj.fAtomicSubcharts)
                aObj.fAtomicSubcharts=aAtomicSubchart;
            else
                aObj.fAtomicSubcharts(end+1)=aAtomicSubchart;
            end
            aObj.fAtomicSubchartMap(aAtomicSubchart.getAtomicSubchartSfId)=aAtomicSubchart;
        end

        function AddTransition(aObj,aTransition)
            if isempty(aObj.fTransitions)
                aObj.fTransitions=aTransition;
            else
                aObj.fTransitions(end+1)=aTransition;
            end
            aObj.fTransitionMap(aTransition.getSfId)=aTransition;
        end

        function AddState(aObj,aState)
            if isempty(aObj.fStates)
                aObj.fStates=aState;
            else
                aObj.fStates(end+1)=aState;
            end
            aObj.fStateMap(aState.getSfId)=aState;
        end

        function AddSubstate(aObj,aSubstate)
            if isempty(aObj.fSubstates)
                aObj.fSubstates=aSubstate;
            else
                aObj.fSubstates(end+1)=aSubstate;
            end
        end

        function AddJunction(aObj,aJunction)
            if isempty(aObj.fJunctions)
                aObj.fJunctions=aJunction;
            else
                aObj.fJunctions(end+1)=aJunction;
            end
            aObj.fJunctionMap(aJunction.getSfId)=aJunction;
        end

        function AddSFPort(aObj,aSFPort)
            if isempty(aObj.fEntryOrExitPort)
                aObj.fEntryOrExitPort=aSFPort;
            else
                aObj.fEntryOrExitPort(end+1)=aSFPort;
            end
        end

        function AddDatum(aObj,aDatum)
            if isempty(aObj.fData)
                aObj.fData=aDatum;
            else
                aObj.fData(end+1)=aDatum;
            end
            aObj.fNameIdMap(aDatum.getQualifiedName)=aDatum.getSfId;
        end

        function AddEvent(aObj,aEvent)
            if isempty(aObj.fEvents)
                aObj.fEvents=aEvent;
            else
                aObj.fEvents(end+1)=aEvent;
            end
            aObj.fEventMap(aEvent.getName)=aEvent;
        end


        function event=getEventByName(aObj,eventName)
            event=[];
            if aObj.isEvent(eventName)
                event=aObj.fEventMap(eventName);
            end
        end


        function out=isEvent(aObj,name)
            out=~isempty(aObj.fEventMap)&&isKey(aObj.fEventMap,name);
        end

        function SetFlags(aObj,aValue)
            junctions=aObj.fJunctions;
            for i=1:numel(junctions)
                junction=junctions(i);
                junction.setFlag(aValue);
            end
            transitions=aObj.fTransitions;
            for i=1:numel(transitions)
                transition=transitions(i);
                transition.setFlag(aValue);
            end
            states=aObj.fStates;
            for i=1:numel(states)
                state=states(i);
                state.setFlag(aValue);
            end
        end

        function out=Path(aObj)
            out=aObj.fPath;
        end

        function out=ParentBlock(aObj)
            out=aObj.fBlock;
        end

        function out=ParentModel(aObj)
            out=aObj.ParentBlock().ParentModel();
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
            aDefaultTransition(end).setSrc(aObj);
        end


        function CreateCfgForChart(aObj)
            if aObj.hasDefaultTransitions()...
                ||~isempty(aObj.getSubstates())
                aObj.fCfg=slci.stateflow.Cfg(aObj,'default');
            end
        end


        function CreateCfgForAtomicSubcharts(aObj)
            for idx=1:numel(aObj.fAtomicSubcharts)
                aObj.fAtomicSubcharts(idx).CreateCfgsForAtomicSubcharts();
            end
        end


        function CreateCfgForStates(aObj)
            for idx=1:numel(aObj.fStates)
                aObj.fStates(idx).CreateCfgs();
            end
        end


        function CreateCfgForGraphicalFunctions(aObj)
            for idx=1:numel(aObj.fGraphicalFunctions)
                aObj.fGraphicalFunctions(idx).CreateCfgs();
            end
        end


        function CreateCfgForTruthTables(aObj)
            for idx=1:numel(aObj.fTruthTables)
                aObj.fTruthTables(idx).CreateCfgs();
            end
        end



        function CreateCfgs(aObj)
            aObj.CreateCfgForChart();
            aObj.CreateCfgForAtomicSubcharts();
            aObj.CreateCfgForStates();
            aObj.CreateCfgForGraphicalFunctions();
            aObj.CreateCfgForTruthTables();
        end

        function BuildTransitionListForChart(aObj)
            transitionObjs=aObj.getUDDObject.defaultTransitions;
            for idx=1:numel(transitionObjs)
                id=transitionObjs(idx).Id;
                assert(isKey(aObj.fTransitionMap,id));
                aObj.AddDefaultTransition(aObj.fTransitionMap(id));
            end
        end


        function BuildTransitionLists(aObj)
            aObj.BuildTransitionListForChart();
            for idx=1:numel(aObj.fAtomicSubcharts)
                aObj.fAtomicSubcharts(idx).BuildTransitionListsAtomicSubcharts(aObj);
            end
            for idx=1:numel(aObj.fStates)
                aObj.fStates(idx).BuildTransitionLists();
            end
            for idx=1:numel(aObj.fJunctions)
                aObj.fJunctions(idx).BuildTransitionLists();
            end
            for idx=1:numel(aObj.fGraphicalFunctions)
                aObj.fGraphicalFunctions(idx).BuildTransitionLists();
            end
            for idx=1:numel(aObj.fTruthTables)
                aObj.fTruthTables(idx).BuildTransitionLists();
            end
        end












        function BuildGlobalStates(aObj)
            for idx=1:numel(aObj.fGraphicalFunctions)
                aObj.fGraphicalFunctions(idx).BuildGlobalStates();
            end


            for idx=1:numel(aObj.fTruthTables)
                if strcmp(aObj.fTruthTables(idx).getLanguage(),'C')
                    aObj.fTruthTables(idx).BuildGlobalStates();
                end
            end
        end

        function out=ParentForObj(aObj,aUDDObj)
            parentObj=aUDDObj.getParent();
            if isa(parentObj,'Stateflow.Chart')
                out=aObj;
            elseif aObj.hasState(parentObj.Id)
                out=aObj.getStateFromId(parentObj.Id);
            elseif aObj.IsGraphicalFunction(parentObj.Id)
                out=aObj.getGraphicalFunctionObject(parentObj.Id);
            elseif aObj.IsTruthTable(parentObj.Id)
                out=aObj.getTruthTableObject(parentObj.Id);
            else
                out=aObj.ParentForObj(parentObj);
            end
        end

        function SortSubstates(aObj)
            numSubstates=numel(aObj.fSubstates);
            if numSubstates>0
                aObj.fSubstates=aObj.getSortedStates(aObj.fSubstates,...
                aObj.getUDDObject);
                for i=1:numSubstates
                    sfObjIndex=aObj.fSFObjOrderMap(aObj.fSubstates(i).getSfId());
                    aObj.fSubstates(i).setSubstateIndex(sfObjIndex);
                end
            end
        end


        function BuildSubstatesLists(aObj)
            for idx=1:numel(aObj.fStates)
                state=aObj.fStates(idx);
                stateObj=state.getUDDObject;
                parentObj=stateObj.getParent();
                parent=aObj.getSupportedParent(parentObj);
                assert(~isempty(parent),'parent state should not be empty.');
                parent.AddSubstate(state);
                state.setParent(parent);



                parentPath=state.ParentChart().Path();
                state.setSID(aObj.getStateflowSID(stateObj,...
                parentPath));

            end
            aObj.SortSubstates();
            for idx=1:numel(aObj.fStates)
                aObj.fStates(idx).SortSubstates()
            end
        end


        function out=getSupportedParent(aObj,stateObj)
            if isa(stateObj,'Stateflow.Chart')
                out=aObj;
            elseif aObj.hasState(stateObj.Id)
                out=aObj.getStateFromId(stateObj.Id);
            else
                parentObj=stateObj.getParent();
                out=aObj.getSupportedParent(parentObj);
            end
        end


        function setRecursiveStateflowFunction(aObj)



            for i=1:numel(aObj.fGraphicalFunctions)
                gfn=aObj.fGraphicalFunctions(i);
                gfn.setRecursive(aObj.fSfFnCallMap);
            end


            for i=1:numel(aObj.fTruthTables)
                tbl=aObj.fTruthTables(i);
                tbl.setRecursive(aObj.fSfFnCallMap);
            end
        end


        function[hasSrcState,stateIds]=...
            getSourceStateIds(aObj,aTransUddObj)
            src=aTransUddObj.Source;


            if isempty(src)
                hasSrcState=false;
                stateIds=[];
                return;
            end

            if(isa(src,'Stateflow.State'))
                hasSrcState=true;
                stateIds=src.Id;
                return;
            else
                if(aObj.fCache.isKey(src.Id))
                    hasSrcState=true;
                    stateIds=aObj.fCache(src.Id);
                    return;
                end

                hasSrcState=false;
                stateIds=[];
                tmpTransUddObjs=src.sinkedTransitions;
                for i=1:numel(tmpTransUddObjs)
                    if(aObj.fCache.isKey(tmpTransUddObjs(i).Id))
                        continue;
                    else
                        aObj.fCache(tmpTransUddObjs(i).Id)=[];
                    end
                    [tHasSrcState,tStateIds]=...
                    aObj.getSourceStateIds(tmpTransUddObjs(i));
                    if~tHasSrcState
                        continue;
                    end

                    hasSrcState=true;
                    stateIds=[stateIds,tStateIds];%#ok
                end
            end

            if(aObj.fCache.isKey(src.Id))
                val=aObj.fCache(src.Id);
                val=[val,stateIds];
                aObj.fCache(src.Id)=unique(val);
            else
                aObj.fCache(src.Id)=stateIds;
            end

        end



        function augmentSendFunctionCallGraph(aObj)
            keys=aObj.fTransToSendFuncDestMap.keys;
            aObj.fCache=containers.Map('KeyType','double',...
            'ValueType','any');
            for i=1:numel(keys)
                aKey=keys{i};
                if(aObj.hasTransition(aKey))
                    t=aObj.getTransitionFromId(aKey);
                    tUddObj=t.getUDDObject();
                    [hasSrcStates,srcStateIds]=...
                    aObj.getSourceStateIds(tUddObj);

                    if~hasSrcStates
                        continue;
                    end

                    destStateIds=aObj.fTransToSendFuncDestMap(aKey);
                    for j=1:numel(srcStateIds)
                        for k=1:numel(destStateIds)
                            aObj.addSendFunctionCallEdge(...
                            srcStateIds(j),destStateIds(k));
                        end
                    end
                end
            end
        end


        function setRecursiveStates(aObj)



            aObj.augmentSendFunctionCallGraph();


            for i=1:numel(aObj.fStates)
                aState=aObj.fStates(i);
                aState.setRecursive(aObj.fSfSendFuncCallGraph);
            end
        end


        function out=hasRecursiveSendFunctionCall(aObj)
            out=any(arrayfun(@(x)(x.isRecursive()),aObj.fStates));
        end



        function out=analyzeLoops(aObj)

            out=0;%#ok
            slciLibName=slci.internal.getSLCILibName();


            inBat=exist('qeinbat','file')&&qeinbat;
            if~inBat&&~slci.internal.isCompilerInstalled()
                DAStudio.error('Slci:slci:ERROR_COMPILER')
            end


            slci.internal.loadSlciLibrary(slciLibName);


            try



                out=calllib(slciLibName,'slciSfMain',aObj);
            catch ME
                aObj.HandleException(ME);
                out=[];
            end


            slci.internal.unloadSlciLibrary(slciLibName);
        end


        function aObj=Chart(aBlkHdl,aBlock,aModel)

            aObj.fBlock=aBlock;
            aObj.fClassName=DAStudio.message('Slci:compatibility:ClassNameChart');
            aObj.fClassNames=DAStudio.message('Slci:compatibility:ClassNameCharts');
            aObj.fStateMap=containers.Map('KeyType','double','ValueType','any');
            aObj.fTransitionMap=containers.Map('KeyType','double','ValueType','any');
            aObj.fJunctionMap=containers.Map('KeyType','double','ValueType','any');
            aObj.fJunctionToCfgMap=containers.Map('KeyType','double','ValueType','any');
            aObj.fTransToSendFuncDestMap=containers.Map('KeyType','double','ValueType','any');
            aObj.fSFObjOrderMap=containers.Map('KeyType','double','ValueType','any');
            if isa(aBlkHdl,'Stateflow.AtomicSubchart')
                chartPath=[aBlkHdl.Path,'/',aBlkHdl.Name];
                chartId=aBlkHdl.Id;
                aObj.setParentAtomicSubchartSfId(chartId);
                atomicSubchartUDDObj=idToHandle(sfroot,chartId);
                chartUDDObj=atomicSubchartUDDObj.Subchart;
                chartSID=Simulink.ID.getSID(chartUDDObj);
            else
                chartObj=get_param(aBlkHdl,'Object');
                if strcmpi(chartObj.CompiledIsActive,'off')

                    return;
                end
                chartPath=getfullname(aBlkHdl);
                chartId=sfprivate('block2chart',aBlkHdl);
                chartUDDObj=idToHandle(sfroot,chartId);
                chartSID=aBlock.getSID();
            end
            aObj.fPath=chartPath;
            assert(~isempty(chartUDDObj),'Chart not found');
            aObj.setUDDObject(chartUDDObj);
            aObj.setSID(chartSID);
            aObj.fActionLanguage=chartUDDObj.ActionLanguage;
            aObj.fSfId=chartUDDObj.Id;
            aObj.fExportChartFunctions=chartUDDObj.ExportChartFunctions;
            aObj.fExecuteAtInitialization=chartUDDObj.ExecuteAtInitialization;
            aObj.fSupportVariableSizing=chartUDDObj.SupportVariableSizing;
            aObj.fChartUpdate=chartUDDObj.ChartUpdate;
            aObj.fSaturateOnIntegerOverflow=chartUDDObj.SaturateOnIntegerOverflow;
            aObj.fSfFnCallMap=slci.internal.StateflowFunctionCallGraph();
            aObj.fSfSendFuncCallGraph=slci.internal.StateflowFunctionCallGraph();
            aObj.fSFObjOrder=sf('SubstatesOf',aObj.fSfId);
            aObj.setChartObjsOrderMap();
            aObj.setIsChartAnAtomicSubchart(aBlkHdl);

            aObj.populateChartProperties(chartUDDObj);


            if~isLibrary(chartUDDObj.getParent())

                aObj.fParentAtomicSubcharts=slci.internal.getSFActiveObjs(...
                chartUDDObj.find('-isa','Stateflow.AtomicSubchart'));

                aObj.fAtomicSubchartMap=containers.Map('KeyType','double','ValueType','any');
                for i=1:numel(aObj.fParentAtomicSubcharts)
                    atomicSubchartObj=aObj.fParentAtomicSubcharts(i);
                    subChartParent=atomicSubchartObj.Subchart.getParent;
                    isSubchartParentFromLib=isLibrary(subChartParent);




                    if~isSubchartParentFromLib
                        atomicSubchartObj=aObj.fParentAtomicSubcharts(i);
                        atomicSubchartSID=Simulink.ID.getSID(atomicSubchartObj.Subchart);
                        atomicSubchartBlkHan=get_param(atomicSubchartSID,...
                        'handle');
                        atomicSubchart=slci.stateflow.SFAtomicSubchart(...
                        atomicSubchartObj,atomicSubchartBlkHan,...
                        aModel,aObj);
                        atomicSubchart.setParentAtomicSubchartSfId(atomicSubchartObj.Id);
                        aObj.AddAtomicSubchart(atomicSubchart);
                    end
                end
            end

            stateObjs=slci.internal.getSFActiveObjs(...
            chartUDDObj.find('-isa','Stateflow.State'));
            for i=1:numel(stateObjs)
                stateObj=stateObjs(i);
                state=slci.stateflow.SFState(stateObj,true);
                aObj.AddState(state);
            end


            aObj.BuildSubstatesLists();


            for i=1:numel(aObj.fStates)
                aObj.fStates(i).setStateScopeSLFunctions();
            end


            for i=1:numel(aObj.fStates)
                aObj.fStates(i).buildSendFunctionCallGraph();
            end


            aObj.fSFFuncNamesMap=containers.Map('KeyType','char','ValueType','char');

            aObj.fSLFuncSfIdMap=containers.Map('KeyType','char','ValueType','double');
            slFunctions=slci.internal.getSFActiveObjs(...
            chartUDDObj.find('-isa','Stateflow.SLFunction'));
            aObj.fSLFunctionsMap=containers.Map('KeyType','char','ValueType','any');
            for i=1:numel(slFunctions)
                slfnObj=slFunctions(i);
                aObj.fDummySFFunctions=[aObj.fDummySFFunctions,aObj.createDummySFFunction(slfnObj)];
                path=aObj.fPath;
                name=sf('get',slfnObj.Id,'.simulink.blockName');
                fnName=[path,'/',name];

                fnName=strrep(fnName,'\n',sprintf('\n'));



                name=strsplit(name,'.');
                name=name{end};

                key=get_param(fnName,'SID');
                value=get_param(fnName,'Handle');
                aObj.fSLFunctionsMap(key)=value;
                aObj.fHasSameFuncName=aObj.fHasSameFuncName||isKey(aObj.fSFFuncNamesMap,name);
                aObj.fSFFuncNamesMap(name)=key;
                aObj.fSLFuncSfIdMap(key)=slfnObj.Id;
            end


            gfnObjs=slci.internal.getSFActiveObjs(...
            chartUDDObj.find('-isa','Stateflow.Function'));
            aObj.fGraphicalFunctionsMap=containers.Map('KeyType','char','ValueType','any');
            for i=1:numel(gfnObjs)
                gfnObj=gfnObjs(i);
                aObj.fDummySFFunctions=[aObj.fDummySFFunctions,aObj.createDummySFFunction(gfnObj)];
                gfn=slci.stateflow.SFFunction(gfnObj,aObj,true);
                key=aObj.getStateflowSID(gfnObj,gfnObj.Chart.Path);
                aObj.fGraphicalFunctions=[aObj.fGraphicalFunctions,gfn];
                aObj.fGraphicalFunctionsMap(key)=gfn;
                aObj.fHasSameFuncName=aObj.fHasSameFuncName||isKey(aObj.fSFFuncNamesMap,gfn.getName);
                aObj.fSFFuncNamesMap(gfn.getName)=key;
            end


            truthTableObjs=slci.internal.getSFActiveObjs(...
            chartUDDObj.find('-isa','Stateflow.TruthTable'));
            aObj.fTruthTablesMap=containers.Map('KeyType','char','ValueType','any');
            for i=1:numel(truthTableObjs)
                truthTableObj=truthTableObjs(i);
                truthTable=slci.stateflow.TruthTable(truthTableObj,aObj,true);
                key=aObj.getStateflowSID(truthTableObj,truthTableObj.Chart.Path);
                aObj.fTruthTables=[aObj.fTruthTables,truthTable];
                aObj.fTruthTablesMap(key)=truthTable;
                aObj.fHasSameFuncName=aObj.fHasSameFuncName||isKey(aObj.fSFFuncNamesMap,truthTable.getName);
                aObj.fSFFuncNamesMap(truthTable.getName)=key;
            end


            dataObjs=chartUDDObj.find('-isa','Stateflow.Data');
            aObj.fDataMap=containers.Map('KeyType','char','ValueType','any');
            aObj.fNameIdMap=containers.Map('KeyType','char','ValueType','double');
            aObj.fDataNameMap=containers.Map('KeyType','char','ValueType','char');
            aObj.fOutputDataNameMap=containers.Map('KeyType','char','ValueType','char');
            for i=1:numel(dataObjs)
                dataObj=dataObjs(i);


                if~slci.internal.isSFActiveData(dataObj)
                    continue;
                end
                data=slci.stateflow.SFData(...
                dataObj,aObj.ParentForObj(dataObj));
                dataObjPath=aObj.fPath;



                key=aObj.getStateflowSID(dataObj,dataObjPath);

                if isa(dataObj.getParent(),'Stateflow.SLFunction')
                    if(strcmpi(data.getScope(),'Constant')...
                        ||strcmpi(data.getScope(),'Local')...
                        ||strcmpi(data.getScope(),'Parameter')...
                        ||strcmpi(data.getScope(),'Data Store Memory'))
                        aObj.AddDatum(data);
                    elseif~isnan(data.getPort())
                        aObj.AddDatum(data);
                    end
                else
                    aObj.AddDatum(data);
                end
                aObj.fDataMap(key)=data;


                dataObjName=strsplit(slci.internal.getFullSFObjectName(data.getSID),'.');

                dataObjName(end)=[];

                mtreeName=aObj.fPath;

                for j=1:numel(dataObjName)
                    mtreeName=fullfile(mtreeName,dataObjName{j});
                end

                mtreeName=fullfile(mtreeName,[aObj.getSID,':',data.getName]);

                mtreeName=strrep(mtreeName,newline,' ');
                if strcmpi(dataObj.Scope,'Output')
                    aObj.fOutputDataNameMap(mtreeName)=data.getQualifiedName;
                else
                    aObj.fDataNameMap(mtreeName)=data.getQualifiedName;
                end
            end


            eventObjs=chartUDDObj.find('-isa','Stateflow.Event');
            aObj.fEventMap=containers.Map;
            for i=1:numel(eventObjs)
                eventObj=eventObjs(i);
                event=slci.stateflow.SFEvent(...
                eventObj,aObj.ParentForObj(eventObj));
                aObj.AddEvent(event);
            end


            aObj.createASTForStates();


            aObj.createASTForTruthTables();


            junctionObjs=slci.internal.getSFActiveObjs(...
            chartUDDObj.find('-isa','Stateflow.Junction'));
            for i=1:numel(junctionObjs)
                junctionObj=junctionObjs(i);
                junction=slci.stateflow.Junction(...
                junctionObj,aObj.ParentForObj(junctionObj),true);
                aObj.AddJunction(junction);
            end


            sfPortObjs=slci.internal.getSFActiveObjs(...
            chartUDDObj.find('-isa','Stateflow.Port'));
            for i=1:numel(sfPortObjs)
                sfPortObj=sfPortObjs(i);
                sfPorts=slci.stateflow.Junction(...
                sfPortObj,aObj.ParentForObj(sfPortObj),true);
                aObj.AddSFPort(sfPorts);
            end


            transitionObjs=slci.internal.getSFActiveObjs(...
            chartUDDObj.find('-isa','Stateflow.Transition'));
            for i=1:numel(transitionObjs)
                transitionObj=transitionObjs(i);
                transition=slci.stateflow.Transition(...
                transitionObj,aObj.ParentForObj(transitionObj),true);
                aObj.AddTransition(transition);
            end


            aObj.BuildTransitionLists();



            aObj.BuildGlobalStates();


            aObj.CreateCfgs();


            aObj.setRecursiveStateflowFunction();



            aObj.setRecursiveStates();

            if(slcifeature('SfLoopSupport')~=0)





                resultFileName=aObj.getSfCCResultsFileName();
                errors=aObj.analyzeLoops();%#ok
                results=load(resultFileName);

                cycleStart=results.SfAnalysisResults.Cycles;
                aObj.fCycles=cycleStart;

                for i=1:numel(cycleStart)
                    if isempty(cycleStart{i})
                        continue;
                    end
                    aLoop=cycleStart{i};
                    header=aLoop{1};
                    junctionSfId=str2double(header);
                    if(aObj.hasJunction(junctionSfId))
                        j=aObj.getJunctionFromId(junctionSfId);
                        [tInit,tCond,tAfter]...
                        =aObj.getLoopHeaderTransitions(j,aLoop);
                        if~isempty(tCond)...
                            &&~isempty(tInit)...
                            &&~isempty(tAfter)


                            tInit=aObj.getTransitionFromId(tInit.getSfId());
                            tInit.setIsLoopInitTransition(true);


                            tCond=aObj.getTransitionFromId(tCond.getSfId());
                            tCond.setIsLoopCondTransition(true);


                            tAfter=aObj.getTransitionFromId(tAfter.getSfId());
                            tAfter.setIsLoopAfterTransition(true);

                            [hasInduction,inductionVar]...
                            =aObj.checkAndGetInductionVar(tCond);



                            excludedTransitions={num2str(tCond.getSfId()),...
                            num2str(tAfter.getSfId())};

                            aObj.setLoopBodyTransitions(...
                            aLoop,...
                            excludedTransitions,...
                            hasInduction,...
                            inductionVar);

                            if hasInduction
                                tInit.setInductionVariable(inductionVar);
                                tAfter.setInductionVariable(inductionVar);
                                tCond.setInductionVariable(inductionVar);
                                aObj.fInductionVariablesList{end+1}=inductionVar;
                            end



isSupportedLoop...
                            =aObj.isSupportedLoopHeader(j);

                        else
                            isSupportedLoop=false;
                        end

                        j.setLoopHeader(true);
                        j.setSupportedLoop(isSupportedLoop);
                    end
                end


                unstructuredStart=results.SfAnalysisResults.UnstructuredCtrlFlow;

                for i=1:numel(unstructuredStart)
                    if isempty(unstructuredStart{i})
                        continue;
                    end
                    junctionSfId=str2double(unstructuredStart{i}{1});


                    if junctionSfId==0
                        if isempty(aObj.fCfg)
                            continue;
                        end

                        virtualJunction=aObj.fCfg.getInitialJunction();
                        outgoing=virtualJunction.getOutgoingTransitions;
                        if(numel(outgoing)==1)...
                            &&(outgoing(1).getSfId()~=0)
                            transUDDObj=outgoing(1).getUDDObject;
                            if~isempty(transUDDObj.Source)
                                junctionSfId=transUDDObj.Source.Id;
                            end
                        else

                            continue;
                        end
                    end

                    if(aObj.hasJunction(junctionSfId))
                        j=aObj.getJunctionFromId(junctionSfId);
                        j.setUnstructured(true);
                        aObj.fHasUnstructuredGraph=true;
                    end
                end

            end







            aObj.addConstraint(slci.compatibility.SimpleStateflowConstraint);
            if(slcifeature('SfLoopSupport')==0)

                acyclicConstraint=slci.compatibility.AcyclicControlFlowConstraint;
                aObj.addConstraint(acyclicConstraint);
                structuredConstraint=slci.compatibility.StructuredControlFlowConstraint;
                structuredConstraint.addPreRequisiteConstraint(acyclicConstraint);
                aObj.addConstraint(structuredConstraint);
            end



            aObj.addConstraint(slci.compatibility.StateflowUniqueFunctionNameConstraint);

            aObj.addConstraint(slci.compatibility.StateflowExportChartFunctionsConstraint);

            aObj.addConstraint(slci.compatibility.StateflowExecOnInitConstraint);

            aObj.addConstraint(slci.compatibility.StateflowSaturateOnIntOverflowConstraint);

            aObj.addConstraint(slci.compatibility.StateflowChartUpdateMethodConstraint);

            aObj.addConstraint(slci.compatibility.StateflowVarSizesConstraint);

            aObj.addConstraint(slci.compatibility.UniqueDefaultTransitionConstraint);


            aObj.addConstraint(slci.compatibility.StateflowChartOutputMonitoringConstraint);


            aObj.addConstraint(slci.compatibility.StateflowEnableSuperStepConstraint);

            aObj.addConstraint(slci.compatibility.StateflowStateMachineTypeConstraint);

            aObj.addConstraint(slci.compatibility.StateflowDefaultTransitionConstraint);

            aObj.addConstraint(slci.compatibility.StateflowLinkedAtomicSubchartConstraint);

        end


        function sortedStates=getSortedStates(aObj,inputStates,uddObj)
            sortedStateIds=sf('SubstatesOfInSortedOrder',uddObj.id);
            inputStateIds=arrayfun(@(x)x.getSfId(),inputStates);


            sortedStateIds=intersect(sortedStateIds,inputStateIds,'stable');
            assert(numel(sortedStateIds)==numel(inputStateIds),...
            'Invalid number of substates');
            sortedStates=inputStates;
            for i=1:numel(sortedStateIds)
                sortedStates(i)=aObj.getStateFromId(sortedStateIds(i));
            end
        end
    end


    methods(Access=private)


        function[initTransition,condTransition,stepTransition]...
            =getLoopHeaderTransitions(aObj,j,loopElementList)

            jCfg=aObj.getJunctionFromCfg(j);

            outgoing=jCfg.getOutgoingTransitions();
            condTransition=[];
            for i=1:numel(outgoing)
                t=outgoing(i);
isFirstTransition...
                =cellfun(@(x)(t.getSfId()==str2double(x)),...
                loopElementList);
                if any(isFirstTransition)
                    condTransition=t;
                    break;
                end
            end

            incoming=jCfg.getIncomingTransitions();
            initTransition=[];
            stepTransition=[];
            if(numel(incoming)==2)
                for i=1:numel(incoming)
                    t=incoming(i);
                    jn=t.getSrc();
isSrcInLoop...
                    =any(cellfun(@(x)(jn.getSfId()==str2double(x)),...
                    loopElementList));
                    if isSrcInLoop

                        stepTransition=t;
                    else

                        initTransition=t;
                    end
                end
            end
        end





        function out=isSupportedLoopHeader(aObj,headerJn)

            jCfg=aObj.getJunctionFromCfg(headerJn);
            nIncoming=numel(jCfg.getIncomingTransitions());
            nOutgoing=numel(jCfg.getOutgoingTransitions());

            out=(nIncoming==2)...
            &&(nOutgoing==2);
        end


        function out=getJunctionFromCfg(aObj,aJunction)
            out=[];
            aSfId=aJunction.getSfId();
            cfgs=aObj.getCfgFromJunctionToCfgMap(aSfId);
            for i=1:numel(cfgs)
                junctions=cfgs(i).getJunctions();
                jIdx=arrayfun(@(x)(x.getSfId()==aSfId),junctions);
                if any(jIdx)
                    out=junctions(jIdx);
                    return;
                end
            end
            if isempty(out)
                out=aJunction;
            end
        end


        function[hasInduction,inductionVar]...
            =checkAndGetInductionVar(aObj,tCond)
            hasInduction=false;
            inductionVar=[];
            if~tCond.HasCondition()
                return;
            end
            rootAst=tCond.getConditionAST().getChildren();

            if(numel(rootAst)~=1)
                return;
            end


            isValidOperator=false;
            if isa(rootAst{1},'slci.ast.SFAstLesserThan')...
                ||isa(rootAst{1},'slci.ast.SFAstLesserThanOrEqual')
                isValidOperator=true;
            end

            isValidLhs=false;
            children=rootAst{1}.getChildren();
            if(numel(children)==2)

isValidAstNode...
                =isa(children{1},'slci.ast.SFAstIdentifier');
                if(isValidAstNode)
                    if aObj.IsDataObject(children{1}.fId)
                        dataObj=aObj.getDataObject(children{1}.fId);
                        isValidDataScope=strcmpi(dataObj.getScope(),'Local')...
                        ||strcmpi(dataObj.getScope(),'Temporary');
                        if(isValidDataScope)
                            isValidLhs=true;
                            inductionVar=children{1}.getQualifiedName();
                        end
                    end
                end
                if(isValidOperator&&isValidLhs)
                    hasInduction=true;
                end
            end
        end


        function setLoopBodyTransitions(aObj,...
            aLoop,...
            excludedTransitions,...
            hasInduction,...
            inductionVar)
            loopNodes=setdiff(aLoop,excludedTransitions);
            for i=1:numel(loopNodes)
                if(aObj.hasTransition(str2double(loopNodes{i})))
                    t=aObj.getTransitionFromId(str2double(loopNodes{i}));
                    isInitAfterCond=t.isLoopInitTransition...
                    ||t.isLoopAfterTransition...
                    ||t.isLoopCondTransition;
                    if~isInitAfterCond
                        t.setIsLoopBodyTransition(true);
                        if hasInduction
                            t.setInductionVariable(inductionVar);
                        end
                    else
                        t.setIsLoopBodyTransition(false);
                    end
                end
            end
        end


        function createASTForStates(aObj)
            states=aObj.getStates;
            for idx=1:numel(states)
                states(idx).createAST;
            end
        end



        function createASTForTruthTables(aObj)
            truthTables=aObj.getTruthTables;
            for idx=1:numel(truthTables)
                truthTables(idx).createAST();
            end
        end
    end

    methods(Access=private)

        function populateChartProperties(aObj,aUDDObject)
            aObj.fProperties=slci.common.ObjectProp;


            aObj.fProperties.setProperty('Decomposition',...
            aUDDObject.Decomposition);

            aObj.fProperties.setProperty('ActionLanguage',...
            aUDDObject.ActionLanguage);

            aObj.fProperties.setProperty('SfId',...
            aUDDObject.Id);

            aObj.fProperties.setProperty('ExportChartFunctions',...
            aUDDObject.ExportChartFunctions);

            aObj.fProperties.setProperty('ExecuteAtInitialization',...
            aUDDObject.ExecuteAtInitialization);

            aObj.fProperties.setProperty('SupportVariableSizing',...
            aUDDObject.SupportVariableSizing);

            aObj.fProperties.setProperty('ChartUpdate',...
            aUDDObject.ChartUpdate);

            aObj.fProperties.setProperty('SaturateOnIntegerOverflow',...
            aUDDObject.SaturateOnIntegerOverflow);

        end
    end
end

function out=ObjInsideTruthTable(obj)
    if isa(obj,'Stateflow.Chart')
        out=false;
    elseif isa(obj,'Stateflow.TruthTable')
        out=true;
    else
        out=ObjInsideTruthTable(obj.getParent());
    end
end


