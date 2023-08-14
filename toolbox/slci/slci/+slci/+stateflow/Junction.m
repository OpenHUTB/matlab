




classdef Junction<slci.common.BdObject

    properties(Access=private)
        fIncomingTransitions=[];
        fOutgoingTransitions=[];
        fFlag=0;
        fParent=[];
        fSfId=-1;
        fHistoryJunction=false;
        fEndsRegionFor=[];

        fIsLoopHeader=false;
        fIsSupportedLoop=false;

        fUnstructured=false;
        fEntryOrExitPort=false;
    end

    methods

        function out=getSfId(aObj)
            out=aObj.fSfId;
        end

        function setSfId(aObj,aSfId)
            aObj.fSfId=aSfId;
        end

        function out=getFlag(aObj)
            out=aObj.fFlag;
        end

        function setFlag(aObj,aFlag)
            aObj.fFlag=aFlag;
        end

        function out=getHistoryJunction(aObj)
            out=aObj.fHistoryJunction;
        end

        function out=getExitOrEntryPort(aObj)
            out=aObj.fEntryOrExitPort;
        end

        function setHistoryJunction(aObj,aValue)
            aObj.fHistoryJunction=aValue;
        end

        function out=getEndsRegionFor(aObj)
            out=aObj.fEndsRegionFor;
        end

        function AddEndsRegionFor(aObj,aEndsRegionFor)
            if isempty(aObj.fEndsRegionFor)
                aObj.fEndsRegionFor=aEndsRegionFor;
            else
                aObj.fEndsRegionFor(end+1)=aEndsRegionFor;
            end
        end


        function setLoopHeader(aObj,isLoopHeader)
            aObj.fIsLoopHeader=isLoopHeader;
        end


        function out=isLoopHeader(aObj)
            out=aObj.fIsLoopHeader;
        end


        function setSupportedLoop(aObj,isSupported)
            aObj.fIsSupportedLoop=isSupported;
        end


        function out=isSupportedLoop(aObj)
            out=aObj.fIsSupportedLoop;
        end


        function setUnstructured(aObj,unstructured)
            aObj.fUnstructured=unstructured;
        end


        function out=isUnstructured(aObj)
            out=aObj.fUnstructured;
        end

        function BuildTransitionLists(aObj)
            junctionObj=aObj.getUDDObject;
            transitionObjs=slci.internal.getSFActiveObjs(...
            junctionObj.sourcedTransitions);
            for idx=1:numel(transitionObjs)
                id=transitionObjs(idx).Id;
                assert(aObj.ParentChart.hasTransition(id),...
                'Transtion should have been populated');
                transition=aObj.ParentChart.getTransitionFromId(id);
                assert(~isempty(transition));
                aObj.AddOutgoingTransition(transition);
            end
            aObj.SortOutgoingTransitions;
        end

        function out=getIncomingTransitions(aObj)
            out=aObj.fIncomingTransitions;
        end

        function AddIncomingTransition(aObj,aIncomingTransition)
            if isempty(aObj.fIncomingTransitions)
                aObj.fIncomingTransitions=aIncomingTransition;
            else
                aObj.fIncomingTransitions(end+1)=aIncomingTransition;
            end
            aIncomingTransition(end).setDst(aObj);
        end

        function RemoveIncomingTransition(aObj,aIncomingTransition)
            for i=1:numel(aObj.fIncomingTransitions)
                if aObj.fIncomingTransitions(i)==aIncomingTransition;
                    aObj.fIncomingTransitions(i)=[];
                    return;
                end
            end
            assert(false,'Failed to remove incoming transition')
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
            aOutgoingTransition(end).setSrc(aObj);
        end

        function RemoveOutgoingTransition(aObj,aOutgoingTransition)
            for i=1:numel(aObj.fOutgoingTransitions)
                if aObj.fOutgoingTransitions(i)==aOutgoingTransition
                    aObj.fOutgoingTransitions(i)=[];
                    return;
                end
            end
            assert(false,'Failed to remove outgoing transition')
        end


        function out=getParent(aObj)
            out=aObj.fParent;
        end

        function out=ParentChart(aObj)
            if isa(aObj.fParent,'slci.stateflow.Chart')
                out=aObj.fParent;
            else
                out=aObj.fParent.ParentChart();
            end
        end

        function out=ParentState(aObj)
            if isa(aObj.fParent,'slci.stateflow.SFState')
                out=aObj.fParent;
            else
                out=[];
            end
        end

        function out=HasUnconditionalOutgoingTransition(aObj)
            out=false;
            outgoing=aObj.getOutgoingTransitions();
            for i=1:numel(outgoing)
                if~outgoing(i).HasCondition()
                    out=true;
                    return
                end
            end
        end

        function out=ParentBlock(aObj)
            out=aObj.ParentChart().ParentBlock();
        end

        function out=ParentModel(aObj)
            out=aObj.ParentBlock().ParentModel();
        end

        function aObj=Junction(aJunctionUDDObj,aParent,addConstraints)
            aObj.fClassName=DAStudio.message('Slci:compatibility:ClassNameJunction');
            aObj.fClassNames=DAStudio.message('Slci:compatibility:ClassNameJunctions');
            aObj.fParent=aParent;
            if isempty(aJunctionUDDObj)


                aObj.fSfId=0;
            else
                aObj.fSfId=aJunctionUDDObj.Id;



                if isprop(aJunctionUDDObj,'Type')
                    aObj.fHistoryJunction=strcmp(aJunctionUDDObj.Type,'HISTORY');
                elseif isprop(aJunctionUDDObj,'PortType')
                    aObj.fEntryOrExitPort=any(cellfun(@(x)any(strcmp(aJunctionUDDObj.PortType,x)),{'ExitJunction','ExitPort','EntryPort','EntryJunction'}));
                end

                parentPath=aObj.ParentChart().Path();

                if isa(aParent,'slci.stateflow.SFAtomicSubchart')
                    aObj.setSID(Simulink.ID.getStateflowSID(aJunctionUDDObj));

                else
                    aObj.setSID(Simulink.ID.getStateflowSID(aJunctionUDDObj,...
                    parentPath));
                end

                aObj.setUDDObject(aJunctionUDDObj);
            end
            if addConstraints
                if(slcifeature('SfLoopSupport')~=0)

                    sfLoopConstraint=slci.compatibility.StateflowSupportedLoopConstraint;
                    aObj.addConstraint(sfLoopConstraint);

                    structuredConstraint=slci.compatibility.StructuredControlFlowConstraint;
                    structuredConstraint.addPreRequisiteConstraint(sfLoopConstraint);
                    aObj.addConstraint(structuredConstraint);
                    loopExitConstraint=...
                    slci.compatibility.JunctionLoopExitConstraint;
                    aObj.addConstraint(loopExitConstraint);
                end


                aObj.addConstraint(slci.compatibility.StateflowBackTrackingConstraint);

                aObj.addConstraint(slci.compatibility.StateflowUnconditionalTransitionConstraint);

                aObj.addConstraint(slci.compatibility.StateflowHistoryJunctionConstraint);

                aObj.addConstraint(slci.compatibility.StateflowTerminatingJunctionSrcConstraint);

                aObj.addConstraint(slci.compatibility.StateflowEntryExitPortConstraint);
            end
        end

        function SortOutgoingTransitions(aObj)
            numTransitions=numel(aObj.fOutgoingTransitions);
            if numTransitions>0
                executionOrder=zeros(1,numTransitions);
                for i=1:numTransitions
                    executionOrder(i)=aObj.fOutgoingTransitions(i).getExecutionOrder();
                end
                [~,order]=sort(executionOrder);
                copyOfTransitions=aObj.fOutgoingTransitions;
                for i=1:numTransitions
                    aObj.fOutgoingTransitions(i)=copyOfTransitions(order(i));
                end
            end
        end

        function aDstObj=CopyForCfg(aSrcObj)

            aDstObj=slci.stateflow.Junction(aSrcObj.getUDDObject(),aSrcObj.fParent,false);
        end

    end
end
