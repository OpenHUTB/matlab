




classdef Cfg<handle

    properties(Access=private)
        fMode='';
        fJunctions=[];
        fTransitions=[];
        fInitialJunction=[];
        fTerminatingJunction=[];
        fParent=[];
        fVirtualTransition=[];
        fIsEmpty=true;
    end

    methods

        function out=ParentChart(aObj)

            if isa(aObj.fParent,'slci.stateflow.Chart')
                out=aObj.fParent;
            else
                out=aObj.fParent.ParentChart;
            end
        end


        function out=ParentState(aObj)
            if isa(aObj.fParent,'slci.stateflow.SFState')
                out=aObj.fParent;
            else
                out=[];
            end
        end


        function out=ParentAtomicSubchart(aObj)
            atomicSubchart=aObj.fParent;
            out=aObj.ParentChart.getAtomicSubchartFromId(atomicSubchart.getSfId);
        end


        function SetFlags(aObj,aValue)
            for i=1:numel(aObj.fJunctions)
                aObj.fJunctions(i).setFlag(aValue);
            end
            for i=1:numel(aObj.fTransitions)
                aObj.fTransitions(i).setFlag(aValue);
            end
        end





        function[ast,srcObj]=getSourceOfTransition(aObj,aTransition)
            ast='';
            srcObj='';
            transObj=aTransition.getUDDObject();

            if isa(transObj.Source,'Stateflow.State')
                ast=aTransition.AppendConditionAction(...
                'slci.ast.SFAstTransOutOfState');
                srcObj=aObj.ParentState();
                ast.setState(srcObj);

            elseif isa(transObj.Source,'Stateflow.AtomicSubchart')
                ast=aTransition.AppendConditionAction(...
                'slci.ast.SFAstTransOutOfAtomicSubchart');
                srcObj=aObj.ParentAtomicSubchart();
                ast.setAtomicSubchart(srcObj);

            elseif isa(transObj.Source,'Stateflow.Junction')
                if isa(transObj.Destination,'Stateflow.State')
                    ast=aTransition.AppendConditionAction(...
                    'slci.ast.SFAstTransOutOfState');
                    srcObj=aObj.ParentState();
                    ast.setState(srcObj);
                elseif isa(transObj.Destination,'Stateflow.AtomicSubchart')
                    ast=aTransition.AppendConditionAction(...
                    'slci.ast.SFAstTransOutOfAtomicSubchart');
                    srcObj=aObj.ParentAtomicSubchart();
                    ast.setAtomicSubchart(srcObj);
                end

            else
                assert(true,'Transition not supported.');

            end

        end


        function out=getJunctions(aObj)
            out=aObj.fJunctions;
        end


        function addJunction(aObj,aJunction)
            if isempty(aObj.fJunctions)
                aObj.fJunctions=aJunction;
            else
                aObj.fJunctions(end+1)=aJunction;
            end
        end


        function RemoveJunction(aObj,aJunction)
            for i=1:numel(aObj.fJunctions)
                if aObj.fJunctions(i)==aJunction
                    aObj.fJunctions(i)=[];
                    return
                end
            end
            assert(false,'Should not get here')
        end

        function out=getTransitions(aObj)
            out=aObj.fTransitions;
        end

        function AddTransition(aObj,aTransition)
            if isempty(aObj.fTransitions)
                aObj.fTransitions=aTransition;
            else
                aObj.fTransitions(end+1)=aTransition;
            end
        end

        function RemoveTransition(aObj,aTransition)
            for i=1:numel(aObj.fTransitions)
                if aObj.fTransitions(i)==aTransition
                    aObj.fTransitions(i)=[];
                    return;
                end
            end
            assert(false,'Should not get here')
        end

        function out=getInitialJunction(aObj)
            out=aObj.fInitialJunction;
        end

        function out=getTerminatingJunction(aObj)
            out=aObj.fTerminatingJunction;
        end


        function[newJunction,outgoingTransitions]=ConvertStateToJunction(...
            aObj,aState,aSrc)
            newJunction=slci.stateflow.Junction(...
            [],aObj.fParent,false);
            if aSrc
                newJunction.setSfId(0);
            else
                newJunction.setSfId(aState.getSfId);
            end
            outgoingTransitions=[];
            if aSrc
                switch aObj.fMode
                case 'default'
                    outgoingTransitions=[];
                case 'inner'
                    outgoingTransitions=aObj.fParent.getInnerTransitions();
                case 'outer'
                    outgoingTransitions=aObj.fParent.getOuterTransitions();
                end
            end
        end


        function[newJunction,outgoingTransitions]=ConvertAtomicSubchartToJunction(...
            aObj,aAtomicSubchart,aSrc)
            newJunction=slci.stateflow.Junction(...
            [],aObj.fParent,false);

            if aSrc
                newJunction.setSfId(0);
            else
                newJunction.setSfId(...
                aAtomicSubchart.getSfId);
            end
            outgoingTransitions=[];
            if aSrc
                switch aObj.fMode
                case 'default'
                    outgoingTransitions=[];
                case{'inner','incoming'}
                    outgoingTransitions=aAtomicSubchart.getIncomingTransitions();
                case{'outer','outgoing'}
                    outgoingTransitions=aAtomicSubchart.getOutgoingTransitions();
                end
            end
        end




        function TraverseFlow(aObj,aNode)


            if aObj.isVisited(aNode)
                return
            end




            if isempty(aNode)
                switch aObj.fMode
                case 'default'
                    if aObj.fParent.hasDefaultTransitions()

                        newJunction=slci.stateflow.Junction(...
                        [],aObj.fParent,false);
                        outgoingTransitions=aObj.fParent.getDefaultTransitions();
                    else

                        isParallelDecomposition=...
                        (isa(aObj.fParent,'slci.stateflow.Chart')...
                        ||isa(aObj.fParent,'slci.stateflow.SFState'))...
                        &&strcmp(aObj.fParent.getDecomposition(),'PARALLEL_AND');
                        isJunctionCreated=false;
                        if isParallelDecomposition
                            subStates=aObj.fParent.getSubstates;
                            numSubstates=numel(subStates);
                            if(numSubstates>0)

                                newJunction=slci.stateflow.Junction(...
                                [],aObj.fParent,false);

                                defaultTransition=slci.stateflow.Transition(...
                                [],aObj.fParent,false);
                                defaultTransition.setDstId(...
                                subStates(1).getSfId());
                                outgoingTransitions=defaultTransition;

                                isJunctionCreated=true;
                            end
                        end

                        if~isJunctionCreated
                            newJunction=slci.stateflow.Junction(...
                            [],aObj.fParent,false);
                            outgoingTransitions=[];
                        end
                    end
                case{'inner','outer'}
                    if isa(aObj.fParent,'slci.stateflow.SFState')

                        [newJunction,outgoingTransitions]=...
                        aObj.ConvertStateToJunction(aObj.fParent,true);
                    elseif isa(aObj.fParent,'slci.stateflow.SFAtomicSubchart')

                        [newJunction,outgoingTransitions]=...
                        aObj.ConvertAtomicSubchartToJunction(aObj.fParent,true);
                    end
                end
                aObj.fInitialJunction=newJunction;



            else
                if isa(aNode,'slci.stateflow.Junction')
                    newJunction=aNode.CopyForCfg();
                    outgoingTransitions=aNode.getOutgoingTransitions();
                elseif isa(aNode,'slci.stateflow.SFAtomicSubchart')
                    [newJunction,outgoingTransitions]=...
                    aObj.ConvertAtomicSubchartToJunction(aNode,false);
                else
                    [newJunction,outgoingTransitions]=...
                    aObj.ConvertStateToJunction(aNode,false);
                end
            end


            aObj.addJunction(newJunction);

            if(newJunction.getSfId()~=0)
                aObj.ParentChart().mapJunctionAndCfg(...
                newJunction.getSfId(),...
                aObj);
            end


            if~isempty(aNode)
                aNode.setFlag(1);
            end



            for i=1:numel(outgoingTransitions)
                transitionOrig=outgoingTransitions(i);



                if(transitionOrig.getSfId()~=0)
                    newTransition=transitionOrig.CopyForCfg();
                else
                    newTransition=transitionOrig;
                end


                if isempty(aNode)
                    newTransition.setSrcId(0)
                end
                aObj.AddTransition(newTransition);



                if~isempty(newTransition.getASTs())
                    aObj.fIsEmpty=false;
                end

                dstId=transitionOrig.getDstId;
                if dstId>0
                    if aObj.ParentChart.hasJunction(dstId)
                        dstNode=aObj.ParentChart.getJunctionFromId(dstId);
                        aObj.TraverseFlow(dstNode);
                    elseif aObj.ParentChart.hasState(dstId)
                        dstNode=aObj.ParentChart.getStateFromId(dstId);
                        aObj.TraverseFlow(dstNode);
                    elseif aObj.ParentChart.hasAtomicSubchart(dstId)
                        dstNode=aObj.ParentChart.getAtomicSubchartFromId(dstId);
                        aObj.TraverseFlow(dstNode);
                    end
                end
            end

        end



        function AddTransActions(aObj)
            for i=1:numel(aObj.fJunctions)
                junction=aObj.fJunctions(i);
                sfId=junction.getSfId;
                if aObj.ParentChart.hasState(sfId)
                    aObj.AddStateTransActions(junction,sfId);
                elseif(aObj.ParentChart.hasAtomicSubchart(sfId))
                    aObj.AddAtomicSubchartTransActions(junction,sfId);
                end
            end
        end




        function AddAtomicSubchartTransActions(aObj,junction,sfId)
            atomicSubchart=aObj.ParentChart.getAtomicSubchartFromId(sfId);


            incomingTransitions=junction.getIncomingTransitions;
            for j=1:numel(incomingTransitions)
                transition=incomingTransitions(j);
                if~isequal(aObj.fMode,'default')

                    [ast,~]=aObj.getSourceOfTransition(transition);

                    ast.setCfgMode(aObj.fMode);

                end

                ast=transition.AppendConditionAction(...
                'slci.ast.SFAstTransIntoAtomicSubchart');
                ast.setAtomicSubchart(atomicSubchart);
            end
        end




        function AddStateTransActions(aObj,junction,sfId)
            state=aObj.ParentChart.getStateFromId(sfId);


            incomingTransitions=junction.getIncomingTransitions;
            for j=1:numel(incomingTransitions)
                transition=incomingTransitions(j);
                hasSrcStateExit=false;
                srcSFObj='';
                if~strcmpi(aObj.fMode,'default')
                    [ast,srcSFObj]=aObj.getSourceOfTransition(transition);
                    ast.setCfgMode(aObj.fMode);
                end
                ast=transition.AppendConditionAction(...
                'slci.ast.SFAstTransIntoState');
                ast.setState(state);

                if isa(srcSFObj,"slci.stateflow.SFState")
                    hasSrcStateExit=...
                    ~isempty(srcSFObj.getExitActionAST());


                    if strcmpi(aObj.fMode,'outer')...
                        &&(~isempty(srcSFObj.ParentState())...
                        &&(srcSFObj.ParentState().getSfId()==state.getSfId()))
                        ast.setIsEntryInternal(true);
                        ast.setIsEntryInternalFromSubstate(true);
                    end
                end

                if(strcmpi(aObj.fMode,'default'))
                    ast.setIsEntryInternal(true);
                elseif(hasSrcStateExit)
                    ast.setNeedsProtectionCode(true);
                end

            end


        end


        function Optimize(aObj)



            eliminatedJunction=true;
            while(eliminatedJunction)
                eliminatedJunction=false;
                jIdx=1;
                numJunctions=numel(aObj.fJunctions);
                while(jIdx<=numJunctions)
                    junction=aObj.fJunctions(jIdx);
                    if((slcifeature('SfLoopSupport')~=0)...
                        &&(junction.getSfId()==0))
                        jIdx=jIdx+1;
                        continue;
                    end
                    transitions=junction.getOutgoingTransitions();
                    if numel(transitions)==1&&transitions.IsTrivial()

                        junction.RemoveOutgoingTransition(transitions);

                        aObj.RemoveTransition(transitions);

                        dst=transitions.getDst();

                        if~isempty(dst)
                            aObj.RemoveJunction(dst);
                            eliminatedJunction=true;


                            dstOut=dst.getOutgoingTransitions();
                            for tIdx=1:numel(dstOut)
                                junction.AddOutgoingTransition(dstOut(tIdx));
                            end



                            dstIn=dst.getIncomingTransitions();
                            for tIdx=1:numel(dstIn)
                                if dstIn(tIdx)~=transitions
                                    junction.AddIncomingTransition(dstIn(tIdx));
                                end
                            end
                            numJunctions=numel(aObj.fJunctions);
                        else


                            jIdx=jIdx+1;
                        end
                    else


                        jIdx=jIdx+1;
                    end
                end
            end

            jIdx=1;
            numJunctions=numel(aObj.fJunctions);
            while(jIdx<=numJunctions)
                junction=aObj.fJunctions(jIdx);
                transitions=junction.getOutgoingTransitions();
                if isempty(transitions)



                    if isempty(aObj.fTerminatingJunction)
                        aObj.fTerminatingJunction=junction;
                        jIdx=jIdx+1;



                    else
                        incoming=junction.getIncomingTransitions();
                        for tIdx=1:numel(incoming)
                            aObj.fTerminatingJunction.AddIncomingTransition(incoming(tIdx));
                        end
                        aObj.RemoveJunction(junction);
                        numJunctions=numel(aObj.fJunctions);
                    end
                else
                    jIdx=jIdx+1;
                end
            end



            if~isempty(aObj.fTerminatingJunction)&&...
                ~isequal(aObj.fTerminatingJunction,aObj.fInitialJunction)&&...
                ~aObj.fInitialJunction.HasUnconditionalOutgoingTransition()
                defaultTransition=slci.stateflow.Transition(...
                [],aObj.fParent,false);
                aObj.AddTransition(defaultTransition)
                aObj.fVirtualTransition=defaultTransition;
                aObj.fInitialJunction.AddOutgoingTransition(defaultTransition);
                aObj.fTerminatingJunction.AddIncomingTransition(defaultTransition);
                switch aObj.fMode
                case 'default'
                case 'inner'
                    ast=defaultTransition.AppendConditionAction(...
                    'slci.ast.SFAstInnerCfgElse');
                    sfId=aObj.ParentState.getSfId;
                    assert(aObj.ParentChart.hasState(sfId),...
                    'State should have been populated.');
                    state=aObj.ParentChart.getStateFromId(sfId);
                    ast.setState(state);
                case 'outer'
                    ast=defaultTransition.AppendConditionAction(...
                    'slci.ast.SFAstOuterCfgElse');
                    if isa(aObj.fParent,'slci.stateflow.SFAtomicSubchart')
                        atomicSubchartObj=aObj.fParent;
                        sfId=atomicSubchartObj.getSfId;
                        ast.setSFObjIsAtomicSubchart(true);
                        assert(aObj.ParentChart.hasAtomicSubchart(sfId),...
                        'Atomic Subchart should have been populated.');
                        sfObj=aObj.ParentChart.getAtomicSubchartFromId(sfId);
                    else
                        sfId=aObj.ParentState.getSfId;
                        assert(aObj.ParentChart.hasState(sfId),...
                        'State should have been populated.');
                        sfObj=aObj.ParentChart.getStateFromId(sfId);

                    end

                    ast.setSFObject(sfObj);
                end
            end
        end


        function out=IsEmpty(aObj)
            out=aObj.fIsEmpty;
        end


        function out=isVisited(aObj,aNode)
            out=false;
            if~isempty(aNode)
                aFlag=aNode.getFlag();
                out=(aFlag==1)&&...
                (isa(aObj.fParent,class(aNode))||...
                isa(aNode,'slci.stateflow.Junction'));
            end
        end

        function aObj=Cfg(aParent,aMode)
            aObj.fParent=aParent;
            aObj.fMode=aMode;


            aObj.ParentChart.SetFlags(0);



            aObj.TraverseFlow([]);


            slci.stateflow.SFUtil.LinkTransitionsAndJunctions(...
            aObj.getTransitions(),aObj.getJunctions());




            aObj.AddTransActions();


            aObj.Optimize();


            aObj.SetFlags(0);
        end

    end
end


