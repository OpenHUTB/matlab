
classdef SFAtomicSubchart<slci.simulink.StateflowBlock



    properties(Access=private)
        fAtomicSubchart=[];
        fParentChart='';
        fSfId='';
        fFlag=false;
        fOuterCfg;
        fInnerDefaultCfg;
        fOuterDefaultCfg;
        fIncomingTransitions=[];
        fOutgoingTransitions=[];
        fInnerDefaultTransitions=[];
        fOuterDefaultTransitions=[]
        fParentAtomicSubchartSfId;
        fInnerTransToStateOrAtomicSubchart;
        fBlockInputSubchartMap=[];
        fBlockOutputSubchartMap=[];
        fInnerDefaultTransitionType;
        fAtomicSubchartIDToSubchartIDMap;
    end
    methods

        function out=getAtomicSubchart(aObj)
            out=aObj.fAtomicSubchart;
        end


        function out=getChartSFunHandle(aObj)
            sfunSID=find_system(aObj.getSID(),"LookUnderMasks",'on',...
            'AllBlocks','on','LookUnderReadProtectedSubsystems','on',...
            'Type','block','BlockType','S-Function');
            out=Simulink.ID.getHandle(sfunSID{1});
        end


        function out=getJunctionFromId(aObj,aId)
            parentChart=aObj.getChartObj();
            assert(parentChart.hasJunction(aId),...
            sprintf('Junction %d: does not exist in fJunctionMap',aId));
            out=parentChart.fJunctionMap(aId);
        end


        function out=getParentAtomicSubchartSfId(aObj)
            out=aObj.fParentAtomicSubchartSfId;
        end


        function setParentAtomicSubchartSfId(aObj,Id)
            aObj.fParentAtomicSubchartSfId=Id;
        end



        function setInnerDefaultTransitionToStateOrAtomicSubchart(aObj)
            if~isempty(aObj.fInnerDefaultTransitions)&&~isa(aObj.fInnerDefaultTransitions.Destination,'Stateflow.Junction')
                dstObj=aObj.fInnerDefaultTransitions.Destination;
                aObj.fInnerTransToStateOrAtomicSubchart=aObj.getChartObj().getChartObjsOrderMap(dstObj.Id);
            end
        end


        function out=getChartObj(aObj)
            out=aObj.fChart;
        end


        function out=getInnerDefaultTransitionToStateOrAtomicSubchart(aObj)
            out=aObj.fInnerTransToStateOrAtomicSubchart;
        end


        function out=isAtomicSubchart(~)
            out=true;
        end


        function out=getSfId(aObj)
            out=aObj.fSfId;
        end


        function out=getAtomicSubchartIDFromSubchart(aObj,subchartID)
            assert(isKey(aObj.fAtomicSubchartIDToSubchartIDMap,subchartID));
            out=aObj.fAtomicSubchartIDToSubchartIDMap(subchartID);
        end


        function out=hasDefaultTransitions(aObj)
            out=~isempty(aObj.fChart.hasDefaultTransitions());
        end


        function out=getDefaultTransitions(aObj)
            out=aObj.fChart.getDefaultTransitions();
        end


        function aObj=SFAtomicSubchart(aAtomicSubchart,atomicSubchartBlkH,aModel,parentChart)
            aObj=aObj@slci.simulink.StateflowBlock(atomicSubchartBlkH,aModel);
            aObj.fAtomicSubchartIDToSubchartIDMap=containers.Map('KeyType','double','ValueType','double');
            aObj.fAtomicSubchart=aAtomicSubchart;
            aObj.fSfId=aAtomicSubchart.Id;
            aObj.fParentChart=parentChart;
            atomicSubchartId=aAtomicSubchart.Id;
            atomicSubchartUDDObj=idToHandle(sfroot,atomicSubchartId);
            topAtomicSubchartUDDObj=atomicSubchartUDDObj.Subchart;
            aObj.fAtomicSubchartIDToSubchartIDMap(atomicSubchartUDDObj.Id)=topAtomicSubchartUDDObj.Id;
            aObj.createBlockOutputSubchartMapWithParentChart();
            aObj.createBlockInputSubchartMapWithParentChart();




            aObj.addConstraint(slci.compatibility.StateflowAtomicSubchartFunctionPackagingConstraint);
        end


        function out=getAtomicSubchartSfId(aObj)
            out=aObj.fSfId;
        end

        function out=getAtomicSubchartInputMap(aObj)
            out=aObj.fBlockInputSubchartMap;
        end


        function out=getAtomicSubchartOutputMap(aObj)
            out=aObj.fBlockOutputSubchartMap;
        end


        function out=ParentChart(aObj)
            if isa(aObj.fParentChart,'slci.stateflow.SFAtomicSubchart')
                out=aObj.fParent.ParentChart();
            elseif isa(aObj.fParentChart,'slci.stateflow.Chart')
                out=aObj.fParentChart;
            else

                out=aObj.getChartObj();
            end
        end



        function BuildTransitionListsAtomicSubcharts(aObj,ParentChartObj)
            if isempty(aObj.fAtomicSubchart)
                return
            end

            atomicSubchartObj=aObj.fAtomicSubchart;
            subchartparent=atomicSubchartObj.getParent;


            incomingTransitionObjs=subchartparent.find('-isa','Stateflow.Transition','Destination',atomicSubchartObj);

            if~isempty(incomingTransitionObjs)
                defaultTransPos=arrayfun(@(x)(atomicSubchartObj.Chart.defaultTransitions==x),incomingTransitionObjs)==1;
                if numel(incomingTransitionObjs)>1&&any(defaultTransPos)
                    transId=incomingTransitionObjs(defaultTransPos).Id;
                else
                    transId=incomingTransitionObjs.Id;
                end
                aObj.fOuterDefaultTransitions=ParentChartObj.getTransitionFromId...
                (transId);
            end


            innerSubchart=atomicSubchartObj.Subchart;
            if~isempty(defaultTransitions(innerSubchart))

                aObj.fInnerDefaultTransitions=defaultTransitions(innerSubchart);

                setInnerDefaultTransitionToStateOrAtomicSubchart(aObj);

            end


            outgoingTransitionObjs=subchartparent.find('-isa','Stateflow.Transition','Source',atomicSubchartObj);
            for idx=1:numel(outgoingTransitionObjs)
                id=outgoingTransitionObjs(idx).Id;
                transition=ParentChartObj.getTransitionFromId(id);
                assert(~isempty(transition));
                aObj.AddOutgoingTransition(transition);
            end
        end


        function out=getIncomingTransitions(aObj)
            out=aObj.fIncomingTransitions;
        end


        function AddIncomingTransition(aObj,aIncomingTransition)
            aObj.fIncomingTransitions(end+1)=aIncomingTransition;
        end


        function out=getOutgoingTransitions(aObj)
            out=aObj.fOutgoingTransitions;
        end


        function AddOutgoingTransition(aObj,aOutgoingTransition)
            if isempty(aObj.fOutgoingTransitions)
                aObj.fOutgoingTransitions=aOutgoingTransition;
            else
                aObj.fOutgoingTransitions(end+1)=aOutgoingTransition;
            end
        end


        function CreateCfgsForAtomicSubcharts(aObj)
            if~isempty(aObj.fInnerDefaultTransitions)...
                &&isempty(aObj.getInnerDefaultTransitionToStateOrAtomicSubchart)
                aObj.fInnerDefaultCfg=slci.stateflow.Cfg(aObj,'default');
            end
            transitions=aObj.getOutgoingTransitions();
            if~isempty(transitions)
                aObj.fOuterCfg=slci.stateflow.Cfg(aObj,'outer');
            end
        end


        function out=getOuterCfg(aObj)
            out=aObj.fOuterCfg;
        end


        function out=getInnerDefaultCfg(aObj)
            out=aObj.fInnerDefaultCfg;
        end


        function out=getFlag(aObj)
            out=aObj.fFlag;
        end



        function setFlag(aObj,aFlag)
            aObj.fFlag=aFlag;
        end





        function createBlockInputSubchartMapWithParentChart(aObj)
            parentUDDObj=aObj.fParentChart.getUDDObject();
            subchartMan=Stateflow.SLINSF.SubchartMan(aObj.fSfId);


            atomicSubchartMappingObj=subchartMan.mappingsMan;
            inputMap=atomicSubchartMappingObj.subsysInportIds;

            for idx=1:numel(inputMap)
                parentChartContainerID=subchartMan.mappingsMan.subsysIdToContainerIdMap(inputMap{idx});
                sfData=parentUDDObj.find('-isa','Stateflow.Data','Id',parentChartContainerID);
                if isempty(aObj.fBlockInputSubchartMap)
                    aObj.fBlockInputSubchartMap(idx)=(sfData.Port-1);
                else
                    aObj.fBlockInputSubchartMap(end+1)=(sfData.Port-1);
                end
            end
        end





        function createBlockOutputSubchartMapWithParentChart(aObj)
            parentUDDObj=aObj.fParentChart.getUDDObject();
            subchartMan=Stateflow.SLINSF.SubchartMan(aObj.fSfId);


            atomicSubchartMappingObj=subchartMan.mappingsMan;
            outputMap=atomicSubchartMappingObj.subsysOutportIds;

            for idx=1:numel(outputMap)
                parentChartContainerID=subchartMan.mappingsMan.subsysIdToContainerIdMap(outputMap{idx});
                sfData=parentUDDObj.find('-isa','Stateflow.Data','Id',parentChartContainerID);
                if isempty(aObj.fBlockOutputSubchartMap)
                    aObj.fBlockOutputSubchartMap(idx)=(sfData.Port-1);
                else
                    aObj.fBlockOutputSubchartMap(end+1)=(sfData.Port-1);
                end

            end
        end
    end
end


