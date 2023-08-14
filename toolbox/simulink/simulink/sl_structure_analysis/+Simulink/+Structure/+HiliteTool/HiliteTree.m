classdef HiliteTree<handle
















































    properties(Constant,Access=private,Hidden=true)
        NoDebug=0;
        DebugBasic=1;
        DebugVerbose=2;
        DebugLevel=0;
    end


    properties(Constant,Access=private,Hidden=true)
        HighlightToSource=true;
        HighlightToDestination=false;
        UpdateWithoutNewEelements=0;
        UpdateWithNewElements=1;
        UpdateWithTraceAllElements=2;
        doesRequireValidation=true;
        doesNotRequireValidation=false;
        doesRequireEditorUpdate=true;
        doesNotRequireEditorUpdate=false;
        traceOriginiatedFromSeg=true;
        traceDidNotOriginateFromSeg=false;
    end


    properties(SetAccess=private,GetAccess=public,Hidden=true)

        traceOrigin;
        CurrentBlock;
        RootBlock;
        CurrentGraph;
        EditorHistory;
        RootGraph;
        CurrentSegment;
        LastSegment;
        RootSegment;
        CurrentBlockDiagram;
        RootBlockDiagram;
        RootBlockDiagramName;
        isHiliteToSrc;
        HandleHistory;
        TraceManager;
        StyleManager;
        PortsCellArray;
        PortDisplayState;
        isTerminated;
        isToggleDirUp;
        ValidGraphList;
        ValidGraphListIndex;
        DelayedActionMap;



        BlockPathManager={};
        EntryEditor;
        CurrentEditor;


signalTracingInfo
        isTraceFromGUI=true;
    end



    methods(Access=public,Hidden=true)
        function HiliteObj=HiliteTree(varargin)
            assert(~isempty(varargin));
            startElement=varargin{1};


            elementType=get_param(startElement,'Type');
            assert(isequal(class(startElement),'double')&&...
            (isequal(elementType,'line')||isequal(elementType,'block')));

            startBDName=get_param(startElement,'Parent');
            startBDHandle=get_param(startBDName,'Handle');




            activeEditor=getActiveEditor;
            prtEditors=getEditorByBDHandle(startBDHandle);






            if isempty(activeEditor)||isempty(prtEditors)
                error(message('Simulink:HiliteTool:ModelNotOpened',elementType,startBDName));
            end

            Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(activeEditor);

            HiliteObj.EntryEditor=activeEditor;
            HiliteObj.CurrentEditor=activeEditor;
            HiliteObj.BlockPathManager=Simulink.Structure.HiliteTool.BlockPathManager;





            entrySystem=getBlockPathToEditor(HiliteObj.CurrentEditor);
            HiliteObj.BlockPathManager.pushToStack(entrySystem);

            if Simulink.Structure.HiliteTool.internal.isValidSegment(startElement)
                assert(~isempty(varargin{2})&&islogical(varargin{2}));
                HiliteTreeStartFromSeg(HiliteObj,startElement,varargin{2});
            elseif(Simulink.Structure.HiliteTool.isValidBlock(startElement))
                HiliteTreeStartFromBlock(HiliteObj,startElement);
            else
                error(message('Simulink:HiliteTool:InvalidStartElement'));
            end

            if nargin>2
                HiliteObj.isTraceFromGUI=varargin{3};
            else
                HiliteObj.isTraceFromGUI=true;
            end
        end
    end



    methods(Access=public,Hidden=true)
        function HiliteObj=HiliteTreeStartFromSeg(HiliteObj,startSeg,isHiliteToSrc)
            HiliteObj.traceOrigin=HiliteObj.traceOriginiatedFromSeg;
            HiliteObj.RootSegment=startSeg;
            HiliteObj.isHiliteToSrc=isHiliteToSrc;
            defineDelayedActionMap(HiliteObj);
            resetDirectionIndependentPropertiesWithRootSegment(HiliteObj);
            addBadgeStyling(HiliteObj);
        end
    end



    methods(Access=public,Hidden=true)
        function HiliteObj=HiliteTreeStartFromBlock(HiliteObj,startBlock)
            import Simulink.Structure.HiliteTool.*
            import Simulink.Structure.HiliteTool.internal.*

            HiliteObj.traceOrigin=HiliteObj.traceDidNotOriginateFromSeg;
            BlockDiagram=getBlockDiagram(startBlock);
            HiliteObj.RootBlock=BlockManager(startBlock,...
            HiliteObj.isHiliteToSrc,...
            BlockDiagram);




            HiliteObj.setInitialTracingDirection(startBlock);

            defineDelayedActionMap(HiliteObj);
            resetDirectionIndependentPropertiesWithRootBlock(HiliteObj);
            addBadgeStyling(HiliteObj);
        end
    end



    methods(Access=private,Hidden=true)
        function setInitialTracingDirection(HiliteObj,startBlock)
            import Simulink.Structure.HiliteTool.*
            blkPortInfo=getBlockPortInfo(startBlock);
            blkName=get_param(startBlock,'Name');

            if~blkPortInfo.blockHasInputPort
                if blkPortInfo.blockHasOutputConnection
                    HiliteObj.isHiliteToSrc=false;
                else

                    error(message('Simulink:HiliteTool:UnconnectedBlockPorts',blkName));
                end
            else
                if blkPortInfo.blockHasInputConnection
                    HiliteObj.isHiliteToSrc=true;
                elseif blkPortInfo.blockHasOutputConnection
                    HiliteObj.isHiliteToSrc=false;
                else

                    error(message('Simulink:HiliteTool:UnconnectedBlockPorts',blkName));
                end
            end
        end
    end




    methods(Access=private,Hidden=true)
        function resetDirectionIndependentPropertiesWithRootSegment(HiliteObj)
            import Simulink.Structure.HiliteTool.*
            import Simulink.Structure.HiliteTool.internal.*

            BD=getBlockDiagram(HiliteObj.RootSegment);
            assert(isHandleToBD(BD));

            HiliteObj.RootBlockDiagram=BD;
            HiliteObj.CurrentSegment=HiliteObj.RootSegment;
            HiliteObj.CurrentBlock=[];
            rootParentGraph=get_param(HiliteObj.RootSegment,'Parent');
            HiliteObj.CurrentGraph=get_param(rootParentGraph,'handle');
            HiliteObj.RootGraph=HiliteObj.CurrentGraph;
            resetDirectionIndependentCommon(HiliteObj);
        end
    end




    methods(Access=private,Hidden=true)
        function resetDirectionIndependentPropertiesWithRootBlock(HiliteObj)
            import Simulink.Structure.HiliteTool.*
            import Simulink.Structure.HiliteTool.internal.*

            rootBlockHandle=getBlockHandle(HiliteObj.RootBlock);
            BD=getBlockDiagram(rootBlockHandle);
            assert(isHandleToBD(BD));

            HiliteObj.RootBlockDiagram=BD;
            HiliteObj.CurrentSegment=[];
            HiliteObj.CurrentBlock=HiliteObj.RootBlock;
            rootParentGraph=get_param(rootBlockHandle,'Parent');
            HiliteObj.CurrentGraph=get_param(rootParentGraph,'handle');
            HiliteObj.RootGraph=HiliteObj.CurrentGraph;
            resetDirectionIndependentCommon(HiliteObj);
            addStartTokenAndUpdate(HiliteObj);
        end
    end


    methods(Access=private)
        function resetDirectionIndependentCommon(HiliteObj)
            import Simulink.Structure.HiliteTool.*



            assert(~isempty(HiliteObj.isHiliteToSrc)&&...
            islogical(HiliteObj.isHiliteToSrc));

            HiliteObj.RootBlockDiagramName=getfullname(HiliteObj.RootBlockDiagram);
            HiliteObj.StyleManager=Simulink.Structure.HiliteTool.styleManager;
            HiliteObj.PortDisplayState=false;
            HiliteObj.CurrentBlockDiagram=HiliteObj.RootBlockDiagram;
            HiliteObj.RootGraph=HiliteObj.CurrentGraph;
            HiliteObj.TraceManager=LineTraceManager(HiliteObj.isHiliteToSrc);
            HiliteObj.ValidGraphList=[];
            HiliteObj.isTerminated=false;
            HiliteObj.isToggleDirUp=false;
            HiliteObj.PortsCellArray={};
            HiliteObj.HandleHistory=0;
            HiliteObj.EditorHistory=struct('graphHandles',...
            HiliteObj.CurrentGraph,...
            'traceType',...
            HiliteTree.UpdateWithNewElements);

            graphManager.removeFromMap(HiliteObj.RootBlockDiagram);
            graphManager.addToGraphList(HiliteObj.RootBlockDiagram,...
            HiliteObj.RootBlockDiagram);
        end
    end




    methods(Access=public)
        function delete(HiliteObj)
            if isvalid(HiliteObj.CurrentEditor)
                Simulink.Editor.HighlightToolInterface.disableKeybindsForEditor(HiliteObj.CurrentEditor);
            end


            if~isempty(HiliteObj.RootBlockDiagram)
                editors=SLM3I.SLDomain.getAllEditorsForBlockDiagram(HiliteObj.RootBlockDiagram);
                otherEditorIndices=editors~=HiliteObj.CurrentEditor;
                otherEditorIndices=find(otherEditorIndices>0);
                for otherEditorIndex=otherEditorIndices
                    editor=editors(otherEditorIndex);
                    Simulink.Editor.HighlightToolInterface.disableKeybindsForEditor(editor);
                end
            end


            clearStylingAndResetDirectionIndepentProperties(HiliteObj);


            Simulink.Structure.HiliteTool.graphManager.removeFromMap(...
            HiliteObj.RootBlockDiagram);
        end
    end




    methods(Access=public)
        function clearStylingAndResetDirectionIndepentProperties(HiliteObj)


            try
                setPortLabels(HiliteObj,'off');
            catch

            end

            try
                if(HiliteObj.traceOrigin==HiliteObj.traceOriginiatedFromSeg)
                    resetDirectionIndependentPropertiesWithRootSegment(HiliteObj);
                else
                    resetDirectionIndependentPropertiesWithRootBlock(HiliteObj);
                end
            catch

            end
        end
    end



    methods(Access=private)
        function setPortLabelsInEditor(HiliteObj,portsCellArray,option)
            assert(any(strcmpi(option,{'on','off'})));
            isEditorModified=false;


            try
                for j=1:length(portsCellArray)
                    port=portsCellArray(j);
                    if~strcmp(get_param(port,'ShowValueLabel'),option)
                        set_param(port,'ShowValueLabel',option);
                        isEditorModified=true;
                    end
                end
            catch

            end
            if isEditorModified&&strcmpi(option,'on')
                Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(HiliteObj.CurrentEditor);
            end
        end
    end




    methods(Access=private)
        function setPortLabels(HiliteObj,option)
            assert(any(strcmpi(option,{'on','off'})));
            for i=1:length(HiliteObj.PortsCellArray)
                ports=HiliteObj.PortsCellArray{i};
                HiliteObj.setPortLabelsInEditor(ports,option);
            end
        end
    end



    methods(Access=public)
        function togglePortDisplay(HiliteObj,togglePortsOnTraceAllPath)
            if(HiliteObj.PortDisplayState)
                if(HiliteObj.StyleManager.isTraceAllActive())
                    HiliteObj.StyleManager.turnOffPortLablesOnTraceAllPath(HiliteObj.PortsCellArray);

                    Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(HiliteObj.CurrentEditor);
                end
                setPortLabels(HiliteObj,'off');
            else
                setPortLabels(HiliteObj,'on');
                if(togglePortsOnTraceAllPath&&...
                    HiliteObj.StyleManager.isTraceAllActive())

                    HiliteObj.StyleManager.turnOnPortLablesOnTraceAllPath(HiliteObj.PortsCellArray);

                    Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(HiliteObj.CurrentEditor);
                end
            end
            HiliteObj.PortDisplayState=~HiliteObj.PortDisplayState;
        end
    end



    methods(Access=private)
        function scrollToVisibileBlock(HiliteObj)

            if(~isempty(HiliteObj.CurrentBlock))

                Simulink.scrollToVisible(HiliteObj.CurrentBlock.blockHandle,...
                'ensureFit','off',...
                'panMode','minimal');
            end

        end
    end



    methods(Access=public)
        function traceToAllSrcsOrDsts(HiliteObj,toSrc,varargin)
            try
                proceedWhenBDisLoaded(getfullname(HiliteObj.CurrentBlockDiagram));




                if(~HiliteObj.isTerminated&&...
                    HiliteObj.isHiliteToSrc==toSrc)
                    if HiliteObj.isTraceFromGUI
                        traceAll(HiliteObj,toSrc);
                    else
                        if isempty(varargin)
                            traceToAll(HiliteObj,toSrc);
                        else
                            traceToAll(HiliteObj,toSrc,varargin{1});
                        end
                    end
                end
            catch err
                processError(HiliteObj,err);
            end
        end
    end



    methods(Access=private)
        function traceAll(HiliteObj,toSrc)




            segment=HiliteObj.CurrentSegment;
            if(isempty(segment))
                segment=HiliteObj.LastSegment;
            end

            oldTraceAllPortLabelState=getTraceAllPortDisplayState(HiliteObj.StyleManager);
            HiliteObj.removeTraceAllStyling();
            HiliteObj.StyleManager.applyTraceAllStyling(segment,...
            HiliteObj.CurrentBlockDiagram,...
            toSrc);
            if(oldTraceAllPortLabelState)
                HiliteObj.StyleManager.turnOnPortLablesOnTraceAllPath(HiliteObj.PortsCellArray);
            end

            updatePostTraceInternalState(HiliteObj,...
            HiliteObj.CurrentGraph,...
            HiliteObj.doesNotRequireValidation,...
            HiliteObj.doesRequireEditorUpdate,...
            HiliteObj.UpdateWithTraceAllElements);
        end
    end



    methods(Access=private)
        function traceToAll(HiliteObj,toSrc,varargin)
            import Simulink.Structure.HiliteTool.*
            proceedWhenBDisLoaded(getfullname(HiliteObj.CurrentBlockDiagram));
            hiliteInfo=Simulink.Structure.HiliteTool.internal.getHiliteInfo(toSrc,...
            HiliteObj.RootSegment,true,varargin{:});


            HiliteObj.signalTracingInfo=hiliteInfo;


            HiliteObj.LastSegment=HiliteObj.CurrentSegment;

            invalidateCurrentBlock(HiliteObj);

            createTokens(HiliteObj.TraceManager,...
            HiliteObj.CurrentSegment,...
            hiliteInfo);

            styleTraceElementsMap(HiliteObj,true);

            updatePortsCellArray(HiliteObj,false);

            updatePostTraceInternalState(HiliteObj,...
            HiliteObj.CurrentGraph,...
            HiliteObj.doesRequireValidation,...
            HiliteObj.doesRequireEditorUpdate,...
            HiliteObj.UpdateWithNewElements);

            applyStartElementStyling(HiliteObj);
        end
    end



    methods(Access=public)
        function removeTraceAllStyling(HiliteObj)
            if(HiliteObj.StyleManager.isTraceAllActive())
                HiliteObj.StyleManager.turnOffPortLablesOnTraceAllPath(HiliteObj.PortsCellArray);
                HiliteObj.StyleManager.removeTraceAllStyling();


                Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(HiliteObj.CurrentEditor);
            end
        end
    end



    methods(Access=public)
        function hiliteToSrc(HiliteObj)
            try
                if(HiliteObj.isTerminated)
                    fadeTerminalBlocks(HiliteObj);
                    return;
                end

                if(~HiliteObj.isHiliteToSrc)
                    removeStylingAndFlipTraceDirection(HiliteObj);
                end


                if(shouldDispatchActionForCurrentBlock(HiliteObj))
                    dispatchDelayedAction(HiliteObj);
                else
                    trace(HiliteObj);
                end
                scrollToVisibileBlock(HiliteObj);
            catch err
                processError(HiliteObj,err);
            end
        end
    end



    methods(Access=public)
        function hiliteToDest(HiliteObj)
            try
                if(HiliteObj.isTerminated)
                    fadeTerminalBlocks(HiliteObj);
                    return;
                end

                if(HiliteObj.isHiliteToSrc)
                    removeStylingAndFlipTraceDirection(HiliteObj);
                end


                if(shouldDispatchActionForCurrentBlock(HiliteObj))
                    dispatchDelayedAction(HiliteObj);
                else
                    trace(HiliteObj);
                end
                scrollToVisibileBlock(HiliteObj);
            catch err
                processError(HiliteObj,err);
            end
        end
    end



    methods(Access=private)
        function bool=shouldDispatchActionForCurrentBlock(HiliteObj)
            bool=~isempty(HiliteObj.CurrentBlock)&&...
            getIsBlockSpecial(HiliteObj.CurrentBlock);
        end
    end



    methods(Access=private,Hidden=true)
        function defineDelayedActionMap(HiliteObj)
            HiliteObj.DelayedActionMap=containers.Map('KeyType','char',...
            'ValueType','any');
            HiliteObj.DelayedActionMap('StepIn')=@HiliteObj.stepInInternal;
            HiliteObj.DelayedActionMap('StepOut')=@HiliteObj.stepOutInternal;
            HiliteObj.DelayedActionMap('moveToFrom')=@HiliteObj.moveToFrom;
            HiliteObj.DelayedActionMap('moveToMappedPortForCoSimInport')=@HiliteObj.moveToMappedPortForCoSimInport;
            HiliteObj.DelayedActionMap('moveToMappedPortForCoSimOutport')=@HiliteObj.moveToMappedPortForCoSimOutport;
        end
    end



    methods(Access=private)
        function dispatchDelayedAction(HiliteObj)
            action=getDelayedAction(getBlockHandle(HiliteObj.CurrentBlock));
            if(isKey(HiliteObj.DelayedActionMap,action))
                action=HiliteObj.DelayedActionMap(action);
                feval(action);
                togglePostDispatch(HiliteObj);
                HiliteObj.applyStartElementStyling;
            end
        end
    end



    methods(Access=private)
        function togglePostDispatch(HiliteObj)


            blockHandle=getBlockHandle(HiliteObj.CurrentBlock);
            stepInGraph=getGraphForStepIn(blockHandle);
            if(~isempty(stepInGraph))
                if(stepInGraph==HiliteObj.retreiveOldGraph&&...
                    canToggleToUniqueBlockInCurrentGraph(HiliteObj))
                    ToggleCurrentBlockInternal(HiliteObj);
                end
            end
        end
    end



    methods(Access=public)
        function undoPreviousTrace(HiliteObj)
            import Simulink.Structure.HiliteTool.*
            try
                discardTraceAllStyling(HiliteObj);
                LastTraceType=HiliteObj.EditorHistory.traceType(end);
                if(LastTraceType==HiliteTree.UpdateWithNewElements)
                    undoPreviousTraceInternal(HiliteObj);
                else
                    revertToPreviousGraph(HiliteObj);
                end
            catch err
                processError(HiliteObj,err);
            end
        end
    end



    methods(Access=private)
        function discardTraceAllStyling(HiliteObj)
            import Simulink.Structure.HiliteTool.*
            LastTraceType=HiliteObj.EditorHistory.traceType(end);
            if(LastTraceType==HiliteTree.UpdateWithTraceAllElements)
                undoTraceAllStyling(HiliteObj);
            end
        end
    end



    methods(Access=private)
        function undoTraceAllStyling(HiliteObj)
            removeTraceAllStyling(HiliteObj);
            eraseLastElementFromEditorHistory(HiliteObj);


        end
    end



    methods(Access=private)
        function revertToPreviousGraph(HiliteObj)


            oldGraph=retreiveOldGraph(HiliteObj);
            Token=getEndTokens(HiliteObj.TraceManager,...
            HiliteObj.CurrentGraph);
            markAsToVisit(Token);
            eraseLastElementFromEditorHistory(HiliteObj);


            updatePostTraceInternalState(HiliteObj,...
            oldGraph,...
            HiliteObj.doesRequireValidation,...
            HiliteObj.doesNotRequireEditorUpdate,...
            HiliteObj.UpdateWithoutNewEelements);

            resetValidGraphListAndIndex(HiliteObj);







            previousBP=HiliteObj.BlockPathManager.popFromStack;

            if ischar(previousBP)
                open_system(previousBP,'force','tab');
            else
                if~isempty(previousBP)
                    previousBP.open('opentype','NEW_TAB','force','on');
                end
            end
            HiliteObj.CurrentEditor=getActiveEditor;
            Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(HiliteObj.CurrentEditor);

            applyStartElementStyling(HiliteObj);
        end
    end



    methods(Access=private)
        function undoPreviousTraceInternal(HiliteObj)

            nTokens=getStackLength(HiliteObj.TraceManager,...
            HiliteObj.CurrentGraph);

            restorePropertiesAndSylingState(HiliteObj);
            oldGraph=retreiveOldGraph(HiliteObj);

            if(nTokens>1)
                eraseLastElementFromEditorHistory(HiliteObj);
                styleTraceElementsMap(HiliteObj,true);


                updatePostTraceInternalState(HiliteObj,...
                oldGraph,...
                HiliteObj.doesRequireValidation,...
                HiliteObj.doesNotRequireEditorUpdate,...
                HiliteObj.UpdateWithoutNewEelements);

                applyStartElementStyling(HiliteObj);
                scrollToVisibileBlock(HiliteObj);
            else
                handleEmptyTokenCaseAfterUndo(HiliteObj);
            end
        end
    end



    methods(Access=private)
        function handleEmptyTokenCaseAfterUndo(HiliteObj)
            removeStylingAndFlipTraceDirection(HiliteObj);
            addBadgeStyling(HiliteObj);




            if(HiliteObj.traceOrigin==HiliteObj.traceOriginiatedFromSeg)
                if(HiliteObj.isHiliteToSrc==HiliteObj.HighlightToSource)
                    hiliteToSrc(HiliteObj);
                else
                    hiliteToDest(HiliteObj);
                end
            end
        end
    end



    methods(Access=private)
        function oldGraph=retreiveOldGraph(HiliteObj)


            if(length(HiliteObj.EditorHistory.graphHandles)>1)
                oldGraph=HiliteObj.EditorHistory.graphHandles(end-1);
            else
                oldGraph=HiliteObj.EditorHistory.graphHandles(1);
            end
        end
    end



    methods(Access=private)
        function restorePropertiesAndSylingState(HiliteObj)
            import Simulink.Structure.HiliteTool.*
            removePortLabelsFromLastTrace(HiliteObj);

            [mapToRemove,mapToRetain]=...
            restoreTraceManagerToPrevState(HiliteObj.TraceManager);

            graphsToRemove=undoStyling(HiliteObj.StyleManager,...
            mapToRemove,...
            mapToRetain);

            BD=HiliteObj.RootBlockDiagram;
            graphManager.removeFromMap(BD,graphsToRemove);
        end
    end



    methods(Access=private)
        function removePortLabelsFromLastTrace(HiliteObj)
            if(~isempty(HiliteObj.PortsCellArray))
                ports=HiliteObj.PortsCellArray{end};
                HiliteObj.PortsCellArray(end)=[];
            end



            if(HiliteObj.PortDisplayState&&...
                ~HiliteObj.StyleManager.isTraceAllActive())
                HiliteObj.setPortLabelsInEditor(ports,'off');
            end
        end
    end



    methods(Access=private)
        function removeStylingAndFlipTraceDirection(HiliteObj)

            if(HiliteObj.isHiliteToSrc)
                HiliteObj.isHiliteToSrc=false;
            else
                HiliteObj.isHiliteToSrc=true;
            end
            clearStylingAndResetDirectionIndepentProperties(HiliteObj);
        end
    end



    methods(Access=public)
        function toggleUp(HiliteObj)
            try
                if(HiliteObj.isTerminated)
                    fadeTerminalBlocks(HiliteObj);
                    return;
                end

                if(~HiliteObj.isToggleDirUp)
                    HiliteObj.isToggleDirUp=true;
                end
                toggleMain(HiliteObj);
            catch err
                processError(HiliteObj,err);
            end
        end
    end



    methods(Access=public)
        function toggleDown(HiliteObj)
            try
                if(HiliteObj.isTerminated)
                    fadeTerminalBlocks(HiliteObj);
                    return;
                end

                if(HiliteObj.isToggleDirUp)
                    HiliteObj.isToggleDirUp=false;
                end
                toggleMain(HiliteObj);
            catch err
                processError(HiliteObj,err);
            end
        end
    end



    methods(Access=private)
        function toggleMain(HiliteObj)

            if(HiliteObj.isTerminated||isempty(HiliteObj.CurrentBlock))

            elseif(canToggleToUniquePortForCurrentBlock(HiliteObj))
                ToggleBlockPort(HiliteObj);
            elseif(canToggleToUniqueBlockInCurrentGraph(HiliteObj))
                ToggleBlock(HiliteObj);
            elseif(canToggleToValidBlockInAnotherGraph(HiliteObj))
                ToggleGraph(HiliteObj,HiliteObj.doesNotRequireEditorUpdate);
            end
            scrollToVisibileBlock(HiliteObj);
        end
    end



    methods(Access=private)
        function bool=canToggleToUniquePortForCurrentBlock(HiliteObj)
            bool=false;
            block=HiliteObj.CurrentBlock;
            nValidPorts=getNumValidPorts(block);
            token=getEndTokens(HiliteObj.TraceManager,HiliteObj.CurrentGraph);
            nValidBlocks=getNumValidBlocks(token);
            canToggleBlock=nValidBlocks>1;
            if(nValidPorts>1)
                atStartPortOfBlock=isCurrentPortSmallestValidPort(block);
                atEndPortOfBlock=isCurrentPortLargestValidPort(block);

                willCycleFromTop=(atStartPortOfBlock&&...
                HiliteObj.isToggleDirUp&&...
                canToggleBlock);

                willCycleFromBottom=(atEndPortOfBlock&&...
                ~HiliteObj.isToggleDirUp&&...
                canToggleBlock);


                bool=~(willCycleFromTop||willCycleFromBottom);
            end
        end
    end



    methods(Access=private)
        function ToggleBlockPort(HiliteObj)
            ToggleBlockPortInternal(HiliteObj);
            applyStartElementStyling(HiliteObj);
        end
    end



    methods(Access=private)
        function bool=canToggleToUniqueBlockInCurrentGraph(HiliteObj)

            token=getEndTokens(HiliteObj.TraceManager,HiliteObj.CurrentGraph);
            nValidBlocks=getNumValidBlocks(token);
            canToggleGraph=canToggleToValidBlockInAnotherGraph(HiliteObj);
            if(nValidBlocks<2)
                bool=false;
            else
                atStartBlockOfToken=isActiveTokenBlockFirstValidBlock(token);
                atEndBlockOfToken=isActiveTokenBlockLastValidBlock(token);


                willCycleFromTop=(atStartBlockOfToken&&...
                HiliteObj.isToggleDirUp&&...
                canToggleGraph);

                willCycleFromBottom=(atEndBlockOfToken&&...
                ~HiliteObj.isToggleDirUp&&...
                canToggleGraph);


                bool=~(willCycleFromTop||willCycleFromBottom);
            end
        end
    end



    methods(Access=private)
        function ToggleBlock(HiliteObj)
            ToggleCurrentBlockInternal(HiliteObj);
            resetCurrentBlockPort(HiliteObj);
            applyStartElementStyling(HiliteObj);
        end
    end



    methods(Access=private)
        function resetCurrentBlockPort(HiliteObj)
            block=HiliteObj.CurrentBlock;
            if(HiliteObj.isToggleDirUp)
                resetToLastValidPort(block);
            else
                resetToFirstValidPort(block);
            end
            updatePostTraceInternalState(HiliteObj,...
            HiliteObj.CurrentGraph,...
            HiliteObj.doesNotRequireValidation,...
            HiliteObj.doesNotRequireEditorUpdate,...
            HiliteObj.UpdateWithoutNewEelements);
        end
    end



    methods(Access=private)
        function tGraph=ToggleGraph(HiliteObj,requiresEditorUpdate)
            tGraph=-1;
            validGraphs=HiliteObj.ValidGraphList;
            if(~isempty(validGraphs))
                incrementValidGraphIndex(HiliteObj);
                tGraph=HiliteObj.ValidGraphList(HiliteObj.ValidGraphListIndex);
                updatePostTraceInternalState(HiliteObj,...
                tGraph,...
                HiliteObj.doesNotRequireValidation,...
                requiresEditorUpdate,...
                HiliteObj.UpdateWithoutNewEelements);

                resetCurrentTokenBlock(HiliteObj);
                applyStartElementStyling(HiliteObj);
            end
        end
    end



    methods(Access=private)
        function incrementValidGraphIndex(HiliteObj)
            validGraphs=HiliteObj.ValidGraphList;
            N=length(validGraphs);
            check=rem(HiliteObj.ValidGraphListIndex+1,N);
            if(check>0)
                HiliteObj.ValidGraphListIndex=check;
            elseif(check==0)
                HiliteObj.ValidGraphListIndex=N;
            end
        end
    end



    methods(Access=private)
        function resetCurrentTokenBlock(HiliteObj)
            token=getEndTokens(HiliteObj.TraceManager,HiliteObj.CurrentGraph);
            if(HiliteObj.isToggleDirUp)
                resetToLastValidBlock(token);
            else
                resetToFirstValidBlock(token);
            end
            updatePostTraceInternalState(HiliteObj,...
            HiliteObj.CurrentGraph,...
            HiliteObj.doesNotRequireValidation,...
            HiliteObj.doesNotRequireEditorUpdate,...
            HiliteObj.UpdateWithoutNewEelements);

            resetCurrentBlockPort(HiliteObj);
        end
    end



    methods(Access=private)
        function addStartTokenAndUpdate(HiliteObj)

            rBlockHandle=getBlockHandle(HiliteObj.RootBlock);
            hiliteInfo=getHiliteInfoFromBlock(rBlockHandle);

            createTokens(HiliteObj.TraceManager,...
            rBlockHandle,...
            hiliteInfo);

            styleTraceElementsMap(HiliteObj,true);

            updatePostTraceInternalState(HiliteObj,...
            HiliteObj.CurrentGraph,...
            HiliteObj.doesRequireValidation,...
            HiliteObj.doesRequireEditorUpdate,...
            HiliteObj.UpdateWithNewElements);

            applyStartElementStyling(HiliteObj);
        end
    end



    methods(Access=private)
        function trace(HiliteObj)
            import Simulink.Structure.HiliteTool.*
            proceedWhenBDisLoaded(getfullname(HiliteObj.CurrentBlockDiagram));

            hiliteInfo=Simulink.Structure.HiliteTool.internal.getHiliteInfo(...
            HiliteObj.isHiliteToSrc,...
            HiliteObj.CurrentSegment);

            HiliteObj.signalTracingInfo=hiliteInfo;


            HiliteObj.LastSegment=HiliteObj.CurrentSegment;

            invalidateCurrentBlock(HiliteObj);

            createTokens(HiliteObj.TraceManager,...
            HiliteObj.CurrentSegment,...
            hiliteInfo);

            styleTraceElementsMap(HiliteObj,true);

            updatePortsCellArray(HiliteObj,false);

            updatePostTraceInternalState(HiliteObj,...
            HiliteObj.CurrentGraph,...
            HiliteObj.doesRequireValidation,...
            HiliteObj.doesRequireEditorUpdate,...
            HiliteObj.UpdateWithNewElements);

            applyStartElementStyling(HiliteObj);
        end
    end



    methods(Access=private)
        function invalidateCurrentBlock(HiliteObj)
            if(doTokensExist(HiliteObj,HiliteObj.CurrentGraph))
                LastToken=getEndTokens(HiliteObj.TraceManager,...
                HiliteObj.CurrentGraph);
                invalidateActiveBlock(LastToken);
            end
        end
    end



    methods(Access=private)
        function bool=doTokensExist(HiliteObj,graph)
            stackLen=getStackLength(HiliteObj.TraceManager,graph);
            bool=stackLen>0;
        end
    end



    methods(Access=private)
        function updatePostTraceInternalState(HiliteObj,...
            terminalGraph,...
            requiresRevalidation,...
            requiresEditorUpdate,...
            isUpdateWithNewElements)

            if(requiresEditorUpdate)
                updateEditorHistory(HiliteObj,terminalGraph,isUpdateWithNewElements);
            end

            if(requiresRevalidation)
                setOldGraph(HiliteObj.TraceManager,HiliteObj.retreiveOldGraph);
                validateAllTokens(HiliteObj);
            end

            updateCurrentBlkSegAndGraph(HiliteObj,terminalGraph);
            HiliteObj.isTerminated=false;
        end
    end








    methods(Access=private)
        function updateEditorHistory(HiliteObj,termGraph,traceType)

            HiliteObj.EditorHistory.graphHandles=...
            [HiliteObj.EditorHistory.graphHandles,termGraph];

            HiliteObj.EditorHistory.traceType=...
            [HiliteObj.EditorHistory.traceType,traceType];

            if(HiliteObj.DebugLevel==HiliteObj.DebugVerbose)
                fprintf(1,'\n --- EDITOR PARAMS : ADD ---');
                fprintf(1,'\n Graph added to history : %s',...
                get_param(termGraph,'name'));
                fprintf(1,'\n Trace stype : %f\n',traceType);
            end
        end
    end




    methods(Access=private)
        function eraseLastElementFromEditorHistory(HiliteObj)
            if(length(HiliteObj.EditorHistory.graphHandles)>1)

                if(HiliteObj.DebugLevel==HiliteObj.DebugVerbose)
                    fprintf(1,'\n --- EDITOR PARAMS : REMOVE ---');
                    termGraph=HiliteObj.EditorHistory.graphHandles(end);
                    traceType=HiliteObj.EditorHistory.traceType(end);
                    fprintf(1,'\n Graph removed from history : %s',...
                    get_param(termGraph,'name'));
                    fprintf(1,'\n Trace stype : %f\n',traceType);
                end

                HiliteObj.EditorHistory.graphHandles(end)=[];
                HiliteObj.EditorHistory.traceType(end)=[];
            end
        end
    end




    methods(Access=private)
        function validateAllTokens(HiliteObj)
            graphs=getGraphsFromCurrentTimeStamp(HiliteObj.TraceManager);
            for i=1:length(graphs)
                nextGraph=graphs{i};
                Token=getEndTokens(HiliteObj.TraceManager,nextGraph);
                validateToken(Token,HiliteObj.TraceManager);
            end
        end
    end




    methods(Access=private)
        function updateValidGraphIndex(HiliteObj)
            locIndex=HiliteObj.CurrentGraph==HiliteObj.ValidGraphList;
            HiliteObj.ValidGraphListIndex=find(locIndex);
            if(isempty(HiliteObj.ValidGraphListIndex))
                HiliteObj.ValidGraphListIndex=0;
            end
        end
    end




    methods(Access=private)
        function updatePortsCellArray(HiliteObj,inPlace)

            traceElementsMap=getElementsMapForCurrentTrace(HiliteObj.TraceManager);
            mapKeys=traceElementsMap.keys;

            portsForAllKeys=[];
            for i=1:length(mapKeys)
                key=mapKeys{i};
                allElements=traceElementsMap(key);


                segs=find_system(allElements,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'type','line');
                ports=get_param(segs,'SrcPortHandle');

                if(iscell(ports))
                    ports=cell2mat(ports);
                end

                ports=unique(ports);

                if(HiliteObj.PortDisplayState)
                    HiliteObj.setPortLabelsInEditor(ports,'on');
                end
                portsForAllKeys=[portsForAllKeys;ports];%#ok
            end

            if(inPlace)
                HiliteObj.PortsCellArray{end}=portsForAllKeys;
            else
                HiliteObj.PortsCellArray{end+1}=portsForAllKeys;
            end
        end
    end




    methods(Access=private)
        function updateCurrentBlkSegAndGraph(HiliteObj,HiliteGraph)

            assert(~isempty(HiliteGraph));
            HiliteObj.CurrentGraph=HiliteGraph;


            LastToken=getEndTokens(HiliteObj.TraceManager,...
            HiliteObj.CurrentGraph);

            checkRecursiveUpdateState(HiliteObj);


            Navigate(HiliteObj,LastToken);

            segIsValid=isCurrentSegmentValid(LastToken);

            if(segIsValid)
                HiliteObj.CurrentSegment=LastToken.getActiveBlockSegment;
            else
                HiliteObj.CurrentSegment=[];
            end

            HiliteObj.CurrentBlock=LastToken.getActiveBlock;
            HiliteObj.CurrentBlockDiagram=LastToken.BlockDiagram;


            HiliteObj.HandleHistory=0;
        end
    end




    methods(Access=private)
        function checkRecursiveUpdateState(HiliteObj)




            uniqueFactor=length(unique(HiliteObj.HandleHistory))...
            /length(HiliteObj.HandleHistory);

            if(~isempty(HiliteObj.HandleHistory)&&uniqueFactor<0.1)
                HiliteObj.CurrentSegment=[];
                HiliteObj.CurrentBlock=[];
                error(message('Simulink:HiliteTool:BadRecursion'));
            else
                if(isempty(HiliteObj.CurrentSegment))
                    HiliteObj.HandleHistory=[HiliteObj.HandleHistory,-1];
                else
                    HiliteObj.HandleHistory=[HiliteObj.HandleHistory...
                    ,HiliteObj.CurrentSegment];
                end
            end

        end
    end




    methods(Access=private)
        function Navigate(HiliteObj,LastToken)

            if(HiliteObj.DebugLevel~=HiliteObj.NoDebug)
                logNavigationStates(HiliteObj,LastToken);
            end


            TokenIsValid=isTokenValid(LastToken);
            CurrentBlockIsValid=isActiveBlockValid(LastToken);
            validPorts=getNumValidPortsForActiveBlock(LastToken);

            if(~isTokenStateValid(LastToken))
                if(isActiveBlockSpecial(LastToken))

                    handleSpecialBlock(HiliteObj,LastToken);

                elseif(~TokenIsValid)

                    handleInvalidToken(HiliteObj);

                elseif(CurrentBlockIsValid&&validPorts>0)

                    ToggleBlockPortInternal(HiliteObj);

                else
                    ToggleCurrentBlockInternal(HiliteObj);
                end
            end
        end
    end



    methods(Access=private)
        function logNavigationStates(HiliteObj,LastToken)
            fprintf(1,' \n ---- UPDATE INFORMATION --- \n\n')
            printGraph(HiliteObj);
            printBlock(HiliteObj);
            fprintf(1,' \n -------------------------------------------- \n')
            printValidationParams(LastToken);
        end

        function printGraph(HiliteObj)
            gName=get_param(HiliteObj.CurrentGraph,'name');
            fprintf(1,' \n Current  Graph : %s\n',gName)
        end

        function printBlock(HiliteObj)
            if(~isempty(HiliteObj.CurrentBlock))
                bH=getBlockHandle(HiliteObj.CurrentBlock);
                bName=get_param(bH,'name');
                bName=bName(bName~=newline);
                fprintf(1,' \n Current  Block: %s\n',bName);
                printValidationParams(HiliteObj.CurrentBlock);
            else
                fprintf(1,' \n Current  Block: %s\n','Empty Block');
            end
        end
    end




    methods(Access=private)
        function handleInvalidToken(HiliteObj)

            if(canToggleToValidBlockInAnotherGraph(HiliteObj))
                ToggleGraph(HiliteObj,HiliteObj.doesRequireEditorUpdate);
            else
                error('Simulink:HiliteTool:TerminateTrace','');
            end
        end
    end



    methods(Access=private)
        function handleSpecialBlock(HiliteObj,TokenObj)
            prevGraph=HiliteObj.retreiveOldGraph;
            if(isActiveSplTokenBlockTerminal(TokenObj,prevGraph))
                error('Simulink:HiliteTool:TerminateTrace','');
            end
        end
    end



    methods(Access=private)
        function bool=canToggleToValidBlockInAnotherGraph(HiliteObj)
            bool=false;
            if(~doesTraceHaveGraphicalDiscontinuity(HiliteObj.TraceManager))
                return;
            end
            validGraphs=HiliteObj.ValidGraphList;
            validGraphs=validGraphs(validGraphs~=HiliteObj.CurrentGraph);
            bool=logical(length(validGraphs));
        end
    end



    methods(Access=private)
        function styleTraceElementsMap(HiliteObj,shouldRemoveCStyling)
            import Simulink.Structure.HiliteTool.*

            if(shouldRemoveCStyling)
                removeCurrentTraceStyling(HiliteObj);
            end
            traceElementsMap=getElementsMapForCurrentTrace(HiliteObj.TraceManager);
            mapKeys=traceElementsMap.keys;
            for i=1:length(mapKeys)
                key=mapKeys{i};

                graphManager.addToGraphList(HiliteObj.RootBlockDiagram,key);

                applyGeneralStyling(HiliteObj,traceElementsMap(key),key);
            end

        end
    end



    methods(Access=private)
        function applyGeneralStyling(HiliteObj,allElements,TraceBD)

            applyGeneralStyling(HiliteObj.StyleManager,TraceBD,allElements);
            applyCurrentTraceStyling(HiliteObj.StyleManager,allElements,TraceBD);
        end
    end



    methods(Access=private)
        function applyStartElementStyling(HiliteObj)

            TraceBD=HiliteObj.CurrentBlockDiagram;
            startBlock=[];
            token=getEndTokens(HiliteObj.TraceManager,HiliteObj.CurrentGraph);
            validBlocks=getValidBlockHandles(token);
            nValidBlocks=length(validBlocks);
            nValidPorts=getNumValidPorts(HiliteObj.CurrentBlock);
            canToggleGraph=canToggleToValidBlockInAnotherGraph(HiliteObj);

            if(nValidBlocks>1||canToggleGraph)
                startBlock=getBlockHandle(HiliteObj.CurrentBlock);
            end

            startSegments=[];
            if(nValidPorts>1)
                startSegments=styleSegmentsInternal(HiliteObj,HiliteObj.CurrentSegment);
            end

            startElements=[startBlock,startSegments];
            applySelectionStyling(HiliteObj.StyleManager,startElements,TraceBD);
            applySubSystemStyling(HiliteObj.StyleManager,...
            HiliteObj.CurrentBlockDiagram,...
            getBlockHandles(token));
        end
    end



    methods(Access=private)
        function addBadgeStyling(HiliteObj)
            if(HiliteObj.traceOrigin==HiliteObj.traceOriginiatedFromSeg)
                addPortBadge(HiliteObj);
            else
                addBlockBadge(HiliteObj);
            end
        end
    end



    methods(Access=private)
        function addPortBadge(HiliteObj)
            if(~isempty(HiliteObj.CurrentSegment))
                port=get_param(HiliteObj.CurrentSegment,'SrcPortHandle');
                if(HiliteObj.isHiliteToSrc==HiliteObj.HighlightToSource)
                    addBadgeToPortForTraceToSrc(HiliteObj.StyleManager,port);
                else
                    addBadgeToPortForTraceToDst(HiliteObj.StyleManager,port);
                end
            end
        end
    end



    methods(Access=private)
        function addBlockBadge(HiliteObj)
            if(~isempty(HiliteObj.CurrentBlock))
                block=getBlockHandle(HiliteObj.CurrentBlock);
                if(HiliteObj.isHiliteToSrc==HiliteObj.HighlightToSource)
                    addBadgeToBlockForTraceToSrc(HiliteObj.StyleManager,block);
                else
                    addBadgeToBlockForTraceToDst(HiliteObj.StyleManager,block);
                end
            end
        end
    end



    methods(Access=private)
        function removeStartElementStyling(HiliteObj)
            removeSelectionStyling(HiliteObj.StyleManager);
        end
    end



    methods(Access=private)
        function removeCurrentTraceStyling(HiliteObj)
            removeCurrentTraceStyling(HiliteObj.StyleManager);
        end
    end



    methods(Access=private)
        function startSegments=styleSegmentsInternal(HiliteObj,startSegments)

            if(HiliteObj.isHiliteToSrc)
                startSegments=getLineSegmentsToSrc(startSegments);
            else
                srcPorts=get_param(startSegments,'SrcPortHandle');
                startSegments=get_param(srcPorts,'line');
                startSegments=getLineSegmentsToDst(startSegments);
            end

        end
    end





    methods(Access=private)
        function ToggleCurrentBlockInternal(HiliteObj)

            if(doTokensExist(HiliteObj,HiliteObj.CurrentGraph))

                LastToken=getEndTokens(HiliteObj.TraceManager,HiliteObj.CurrentGraph);
                value=1+-2*double(HiliteObj.isToggleDirUp);
                updateBlockListIndex(LastToken,value);

                updatePostTraceInternalState(HiliteObj,...
                HiliteObj.CurrentGraph,...
                HiliteObj.doesNotRequireValidation,...
                HiliteObj.doesNotRequireEditorUpdate,...
                HiliteObj.UpdateWithoutNewEelements);
            end

        end
    end





    methods(Access=private)
        function ToggleBlockPortInternal(HiliteObj)

            if(doTokensExist(HiliteObj,HiliteObj.CurrentGraph))

                LastToken=getEndTokens(HiliteObj.TraceManager,HiliteObj.CurrentGraph);
                value=1+-2*double(HiliteObj.isToggleDirUp);
                updatePortToggle(LastToken,value);

                updatePostTraceInternalState(HiliteObj,...
                HiliteObj.CurrentGraph,...
                HiliteObj.doesNotRequireValidation,...
                HiliteObj.doesNotRequireEditorUpdate,...
                HiliteObj.UpdateWithoutNewEelements);
            end
        end
    end




    methods(Access=private)
        function stepInInternal(HiliteObj)

            sourceType=getBlockType(HiliteObj.CurrentBlock);

            if(strcmpi(sourceType,'Subsystem'))
                stepIntoASubSystem(HiliteObj);
            elseif(strcmpi(sourceType,'modelreference'))
                stepIntoAModelReference(HiliteObj);
            end
        end
    end




    methods(Access=private)
        function stepIntoASubSystem(HiliteObj)

            block=getBlockHandle(HiliteObj.CurrentBlock);
            stepInGraph=getGraphForStepIn(block);

            if(doTokensExist(HiliteObj,stepInGraph))



                bp=Simulink.BlockPath.fromHierarchyIdAndHandle(...
                HiliteObj.CurrentEditor.getHierarchyId,HiliteObj.CurrentBlock.blockHandle);


                assert(~ischar(bp));
                bp.open('opentype','NEW_TAB','force','on');

                HiliteObj.BlockPathManager.pushToStack(bp);
                HiliteObj.CurrentEditor=getActiveEditor;
                Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(HiliteObj.CurrentEditor);

                updatePostTraceInternalState(HiliteObj,...
                stepInGraph,...
                HiliteObj.doesRequireValidation,...
                HiliteObj.doesRequireEditorUpdate,...
                HiliteObj.UpdateWithoutNewEelements);
            else
                error('Simulink:HiliteTool:TerminateTrace','');
            end
        end
    end




    methods(Access=private)
        function stepIntoAModelReference(HiliteObj)




            bp=Simulink.BlockPath.fromHierarchyIdAndHandle(...
            HiliteObj.CurrentEditor.getHierarchyId,HiliteObj.CurrentBlock.blockHandle);

            assert(~ischar(bp));



            bp.open('opentype','NEW_TAB','force','on');
            HiliteObj.BlockPathManager.pushToStack(bp);


            HiliteObj.CurrentEditor=getActiveEditor;
            Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(HiliteObj.CurrentEditor);

            block=getBlockHandle(HiliteObj.CurrentBlock);
            stepInGraph=getGraphForStepIn(block);
            LastToken=getEndTokens(HiliteObj.TraceManager,...
            HiliteObj.CurrentGraph);
            segments=getSegmentList(LastToken);
            blocks=getBlockHandles(LastToken);
            elements=[segments,blocks];
            refHiliteInfo=getHiliteInfoForModelRefs(block,...
            elements,...
            HiliteObj.isHiliteToSrc,...
            true);

            if(~isempty(refHiliteInfo))

                addBDModelRefPair(HiliteObj.TraceManager,...
                stepInGraph,block);

                appendTraceInfoForModelRefAndUpdate(HiliteObj,...
                refHiliteInfo,...
                stepInGraph);
            else
                error('Simulink:HiliteTool:TerminateTrace','');
            end
        end
    end



    methods(Access=private)
        function appendTraceInfoForModelRefAndUpdate(HiliteObj,...
            refHiliteInfos,...
            termGraph)

            block=getBlockHandle(HiliteObj.CurrentBlock);

            appendTokens(HiliteObj.TraceManager,...
            block,...
            refHiliteInfos);

            styleTraceElementsMap(HiliteObj,false);
            updatePortsCellArray(HiliteObj,true);



            updatePostTraceInternalState(HiliteObj,...
            termGraph,...
            HiliteObj.doesRequireValidation,...
            HiliteObj.doesRequireEditorUpdate,...
            HiliteObj.UpdateWithoutNewEelements);

            applyStartElementStyling(HiliteObj);
        end
    end




    methods(Access=private)
        function stepOutInternal(HiliteObj)

            parentGraph=get_param(HiliteObj.CurrentGraph,'Parent');


            if(isempty(parentGraph))
                stepOutOfModelReference(HiliteObj);
            else
                stepOutOfSubSystem(HiliteObj);
            end
        end
    end



    methods(Access=private)
        function stepOutOfSubSystem(HiliteObj)
            parentGraph=get_param(HiliteObj.CurrentGraph,'Parent');
            parentHandle=get_param(parentGraph,'Handle');
            pBlock=HiliteObj.CurrentGraph;

            if(doTokensExist(HiliteObj,parentHandle))







                parent=HiliteObj.BlockPathManager.getTopFromStack.getParent;

                if ischar(parent)
                    open_system(parent,'force','tab');
                else
                    parent.open('opentype','NEW_TAB','force','on');
                end


                HiliteObj.CurrentEditor=getActiveEditor;
                Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(HiliteObj.CurrentEditor);
                HiliteObj.BlockPathManager.pushToStack(parent);

                HiliteObj.StyleManager.fadeBlock(pBlock);

                updatePostTraceInternalState(HiliteObj,...
                parentHandle,...
                HiliteObj.doesRequireValidation,...
                HiliteObj.doesRequireEditorUpdate,...
                HiliteObj.UpdateWithoutNewEelements);
            end
        end
    end




    methods(Access=private)
        function stepOutOfModelReference(HiliteObj)

            currentBlockPath=HiliteObj.BlockPathManager.getTopFromStack;
            bpLength=currentBlockPath.getLength;

            if bpLength~=0


                parentBlock=currentBlockPath.getBlock(bpLength);
                parentBlockHandle=get_param(parentBlock,'Handle');
                assert(ishandle(parentBlockHandle)&&...
                isequal(get_param(parentBlockHandle,'Type'),'block'));



                parentBlockPath=HiliteObj.BlockPathManager.getTopFromStack.getParent;

                if ischar(parentBlockPath)
                    open_system(parentBlockPath,'force','tab');
                else
                    parentBlockPath.open('opentype','NEW_TAB','force','on');
                end


                HiliteObj.BlockPathManager.pushToStack(parentBlockPath);
                HiliteObj.CurrentEditor=getActiveEditor;
                Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(HiliteObj.CurrentEditor);

                stepOutToChoiceModelReference(HiliteObj,parentBlockHandle);

            else
                error('Simulink:HiliteTool:TerminateTrace','');
            end
        end
    end


    methods(Access=private)
        function stepOutToChoiceModelReference(HiliteObj,choiceBlock)

            refHiliteInfo=...
            getHiliteInfoForSteppingOutToChoiceModelReference(HiliteObj,...
            choiceBlock);

            parentName=get_param(choiceBlock,'Parent');

            if(~isempty(parentName))
                parentHandle=get_param(parentName,'handle');
                HiliteObj.StyleManager.fadeBlock(choiceBlock);

                appendTraceInfoForModelRefAndUpdate(HiliteObj,...
                refHiliteInfo,...
                parentHandle);
            end
        end
    end


    methods(Access=private)
        function refHiliteInfo=...
            getHiliteInfoForSteppingOutToChoiceModelReference(HiliteObj,choiceBlock)

            sourceType=getBlockType(HiliteObj.CurrentBlock);
            blockHandle=getBlockHandle(HiliteObj.CurrentBlock);
            if(strcmpi(sourceType,'inport'))
                refHiliteInfo=...
                getHiliteInfoForChoiceModelRefInports(choiceBlock,blockHandle);
            else
                refHiliteInfo=...
                getHiliteInfoForChoiceModelRefOutports(choiceBlock,blockHandle);
            end
        end
    end



    methods(Access=private)
        function moveToFrom(HiliteObj)
            updateValidGraphListForGoToFrom(HiliteObj);
            targetGraph=ToggleGraph(HiliteObj,HiliteObj.doesRequireEditorUpdate);

            if~ishandle(targetGraph)
                return;
            end
            open_system(targetGraph,'force','tab');

            HiliteObj.CurrentEditor=getActiveEditor;
            Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(HiliteObj.CurrentEditor);

            bp=Simulink.BlockPath.fromHierarchyIdAndHandle(...
            HiliteObj.CurrentEditor.getHierarchyId,HiliteObj.CurrentBlock.blockHandle);
            HiliteObj.BlockPathManager.pushToStack(bp.getParent);
        end
    end



    methods(Access=private)
        function moveToMappedPortForCoSimInport(HiliteObj)
            obsvdBlkChain=updateValidGraphListForCoSimInport(HiliteObj);
            targetGraph=ToggleGraph(HiliteObj,HiliteObj.doesRequireEditorUpdate);

            if~ishandle(targetGraph)
                return;
            end
            bpcell=arrayfun(@(x)getfullname(x),obsvdBlkChain,'UniformOutput',false);
            bp=Simulink.BlockPath(bpcell);
            bp=bp.getParent;
            if ischar(bp)
                open_system(bp,'force','tab');
            else
                bp.open('opentype','NEW_TAB','force','on');
            end
            HiliteObj.CurrentEditor=getActiveEditor;
            Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(HiliteObj.CurrentEditor);
            HiliteObj.BlockPathManager.pushToStack(bp);

            styleTraceElementsMap(HiliteObj,false);
        end
    end



    methods(Access=private)
        function moveToMappedPortForCoSimOutport(HiliteObj)
            obsvdBlkChain=updateValidGraphListForCoSimOutport(HiliteObj);
            targetGraph=ToggleGraph(HiliteObj,HiliteObj.doesRequireEditorUpdate);

            if~ishandle(targetGraph)
                return;
            end
            bpcell=arrayfun(@(x)getfullname(x),obsvdBlkChain,'UniformOutput',false);
            bp=Simulink.BlockPath(bpcell);
            bp=bp.getParent;
            if ischar(bp)
                open_system(bp,'force','tab');
            else
                bp.open('opentype','NEW_TAB','force','on');
            end
            HiliteObj.CurrentEditor=getActiveEditor;
            Simulink.Editor.HighlightToolInterface.enableKeybindsForEditor(HiliteObj.CurrentEditor);
            HiliteObj.BlockPathManager.pushToStack(bp);

            styleTraceElementsMap(HiliteObj,false);
        end
    end



    methods(Access=private)
        function updateValidGraphListForGoToFrom(HiliteObj)
            resetValidGraphListAndIndex(HiliteObj);
            blockHandle=getBlockHandle(HiliteObj.CurrentBlock);
            blockType=getBlockType(HiliteObj.CurrentBlock);

            if(strcmpi(blockType,'From'))
                blockTypeToSearch='Goto';
            else
                blockTypeToSearch='From';
            end

            tag=get_param(blockHandle,'GoToTag');
            graphs=getGraphsFromCurrentTimeStamp(HiliteObj.TraceManager);
            HiliteObj.ValidGraphList=[];

            for i=1:length(graphs)
                nextGraph=graphs{i};
                blockFound=find_system(nextGraph,...
                'SearchDepth',1,...
                'BlockType',blockTypeToSearch,...
                'GoToTag',tag);

                if(~isempty(blockFound))
                    Token=getEndTokens(HiliteObj.TraceManager,nextGraph);
                    numValidBlocks=getNumValidBlocks(Token);

                    if(numValidBlocks>0&&...
                        nextGraph~=HiliteObj.CurrentGraph)
                        HiliteObj.ValidGraphList=...
                        [HiliteObj.ValidGraphList,nextGraph];
                    end
                end
            end
            updateValidGraphIndex(HiliteObj);
        end
    end



    methods(Access=private)
        function mappedBlkChain=updateValidGraphListForCoSimInport(HiliteObj)
            mappedBlkChain=[];
            resetValidGraphListAndIndex(HiliteObj);
            blockHandle=getBlockHandle(HiliteObj.CurrentBlock);
            if strcmp(get_param(blockHandle,'BlockType'),'ObserverPort')
                obsEntType=Simulink.observer.internal.getObservedEntityType(blockHandle);
                switch obsEntType
                case 'Outport'
                    mappedBlkChain=Simulink.observer.internal.getObservedBlockChainForceLoad(blockHandle);
                    if~isempty(mappedBlkChain)
                        observedPrtIdx=Simulink.observer.internal.getObservedPortIndex(blockHandle)+1;
                        portHandles=get_param(mappedBlkChain(end),'PortHandles');
                        if observedPrtIdx>=1&&observedPrtIdx<=length(portHandles.Outport)
                            HiliteObj.ValidGraphList=get_param(get_param(mappedBlkChain(end),'Parent'),'Handle');
                        end
                    end
                case{'SFState','SFData'}
                    mappedBlkChain=Simulink.observer.internal.getObservedBlockChainForceLoad(blockHandle);
                    if~isempty(mappedBlkChain)
                        parentSys=get_param(mappedBlkChain(end),'Parent');
                        if~strcmp(get_param(parentSys,'Open'),'on')
                            open_system(parentSys);
                        end
                        HiliteObj.ValidGraphList=get_param(parentSys,'Handle');
                    end
                otherwise

                end
            elseif strcmp(get_param(blockHandle,'BlockType'),'InjectorInport')
                if strcmp(Simulink.injector.internal.getInjectedEntityType(blockHandle),'Outport')
                    mappedBlkChain=Simulink.injector.internal.getInjectedBlockChainForceLoad(blockHandle);
                    if~isempty(mappedBlkChain)
                        injectedPrtIdx=Simulink.injector.internal.getInjectedPortIndex(blockHandle)+1;
                        portHandles=get_param(mappedBlkChain(end),'PortHandles');
                        if injectedPrtIdx>=1&&injectedPrtIdx<=length(portHandles.Outport)
                            HiliteObj.ValidGraphList=get_param(get_param(mappedBlkChain(end),'Parent'),'Handle');
                        end
                    end
                end
            end
            updateValidGraphIndex(HiliteObj);
        end

        function mappedBlkChain=updateValidGraphListForCoSimOutport(HiliteObj)
            mappedBlkChain=[];
            resetValidGraphListAndIndex(HiliteObj);
            blockHandle=getBlockHandle(HiliteObj.CurrentBlock);
            if strcmp(Simulink.injector.internal.getInjectedEntityType(blockHandle),'Outport')
                mappedBlkChain=Simulink.injector.internal.getInjectedBlockChainForceLoad(blockHandle);
                if~isempty(mappedBlkChain)
                    injectedPrtIdx=Simulink.injector.internal.getInjectedPortIndex(blockHandle)+1;
                    portHandles=get_param(mappedBlkChain(end),'PortHandles');
                    if injectedPrtIdx>=1&&injectedPrtIdx<=length(portHandles.Outport)
                        HiliteObj.ValidGraphList=get_param(get_param(mappedBlkChain(end),'Parent'),'Handle');
                    end
                end
            end
            updateValidGraphIndex(HiliteObj);
        end
    end



    methods(Access=private)
        function resetValidGraphListAndIndex(HiliteObj)
            HiliteObj.ValidGraphList=[];
            updateValidGraphIndex(HiliteObj);
        end
    end







    methods(Access=private)
        function processError(HiliteObj,err)
            HiliteObj.isTerminated=true;
            removeStartElementStyling(HiliteObj);
            switch err.identifier
            case 'Simulink:HiliteTool:TerminateTrace'

            otherwise
                rethrow(err);
            end

        end
    end



    methods(Access=private)
        function fadeTerminalBlocks(HiliteObj)
            if(HiliteObj.isTerminated&&...
                doTokensExist(HiliteObj,HiliteObj.CurrentGraph))
                token=getEndTokens(HiliteObj.TraceManager,HiliteObj.CurrentGraph);
                blockList=getBlockHandles(token);
                for i=1:length(blockList)
                    block=blockList(i);
                    HiliteObj.StyleManager.fadeBlock(block);
                end
            end
        end
    end
end
