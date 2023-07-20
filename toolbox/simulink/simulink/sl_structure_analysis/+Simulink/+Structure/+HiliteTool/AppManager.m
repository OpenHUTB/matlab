classdef AppManager<handle








    properties(Access=private)
BDMap
listenerMap
    end



    methods(Access=private)
        function obj=AppManager
            obj.BDMap=containers.Map('KeyType','double','ValueType','any');
            obj.listenerMap=containers.Map('KeyType','double','ValueType','any');
        end
    end



    methods(Static,Access=private)
        function manager=getInstance
            import Simulink.Structure.HiliteTool.*
            persistent obj
            if(isempty(obj)||~isvalid(obj))
                obj=AppManager;
                manager=obj;
            else
                manager=obj;
            end
        end
    end



    methods(Static,Access=public)
        function tracerObj=getExistingTracerForBD(BD)
            import Simulink.Structure.HiliteTool.*
            manager=AppManager.getInstance;
            if(isKey(manager.BDMap,BD)&&isvalid(manager.BDMap(BD)))
                tracerObj=manager.BDMap(BD);
            else
                tracerObj=[];
            end
        end
    end



    methods(Static,Access=private)
        function tracerObj=createNewTracerForBD(seg,isHiliteToSrc,BD,varargin)
            import Simulink.Structure.HiliteTool.*
            manager=AppManager.getInstance;
            AppManager.cleanUpExistingTraceForBD(BD);


            tracerObj=tracer(seg,isHiliteToSrc,varargin{:});
            manager.BDMap(BD)=tracerObj;
            manager.listenerMap(BD)=Simulink.listener(BD,'CloseEvent',...
            @(~,~)AppManager.removeAdvancedHighlighting(BD));
        end
    end



    methods(Static,Access=private)
        function tracerObj=createNewTracerForBDFromBlock(block,BD)
            import Simulink.Structure.HiliteTool.*
            manager=AppManager.getInstance;
            AppManager.cleanUpExistingTraceForBD(BD);


            tracerObj=tracer(block);
            manager.BDMap(BD)=tracerObj;
            manager.listenerMap(BD)=Simulink.listener(BD,'CloseEvent',...
            @(~,~)AppManager.removeAdvancedHighlighting(BD));
        end
    end



    methods(Static,Access=private)
        function cleanUpExistingTraceForBD(BD)
            import Simulink.Structure.HiliteTool.*
            owner=graphManager.findOwner(BD);
            if(~isempty(owner))
                delete(AppManager.getExistingTracerForBD(owner));
            end
        end
    end



    methods(Static,Access=public)
        function tracerObj=HighlightSignalToSource(seg)
            import Simulink.Structure.HiliteTool.*
            import Simulink.Structure.HiliteTool.internal.*

            assert(isValidSegment(seg),...
            message('Simulink:HiliteTool:ExpectedSegmentHandle'));

            BD=getBlockDiagram(seg);
            try
                AppManager.showSignalHierarchyViewer(BD,seg);
                scopedBlocker=SLM3I.ScopedHighlightToolCancelBlocker(BD);%#ok<NASGU> 
                tracerObj=AppManager.createNewTracerForBD(seg,true,BD);
                tracerObj=AppManager.stepToSrc(tracerObj);
            catch err
                if isempty(err)
                    err=MException(message('Simulink:HiliteTool:FirstCallFailure'));
                end
                AppManager.processError(BD,err);
            end
        end
    end






    methods(Static,Access=public)
        function tracerObj=HighlightSignalToAllSources(seg,varargin)
            import Simulink.Structure.HiliteTool.*
            import Simulink.Structure.HiliteTool.internal.*

            assert(isValidSegment(seg),...
            message('Simulink:HiliteTool:ExpectedSegmentHandle'));

            BD=getBlockDiagram(seg);
            try


                tracerObj=AppManager.createNewTracerForBD(seg,true,BD,false);
                if(~isempty(tracerObj))
                    scopedBlocker=SLM3I.ScopedHighlightToolCancelBlocker(BD);%#ok<NASGU> 
                    if(tracerObj.hiliteObj.isHiliteToSrc)
                        tracerObj.traceToAllSources(varargin{:});
                    else
                        tracerObj.undoTraceAllStyling;
                    end
                end
            catch
                err=MException(message('Simulink:HiliteTool:FirstCallFailure'));
                AppManager.processError(BD,err);
            end
        end
    end







    methods(Static,Access=public)
        function tracerObj=HighlightSignalToAllDestinations(seg,varargin)
            import Simulink.Structure.HiliteTool.*
            import Simulink.Structure.HiliteTool.internal.*

            assert(isValidSegment(seg),...
            message('Simulink:HiliteTool:ExpectedSegmentHandle'));

            BD=getBlockDiagram(seg);
            try




                tracerObj=AppManager.createNewTracerForBD(seg,false,BD,false);
                if(~isempty(tracerObj))
                    scopedBlocker=SLM3I.ScopedHighlightToolCancelBlocker(BD);%#ok<NASGU> 
                    if(~tracerObj.hiliteObj.isHiliteToSrc)
                        tracerObj.traceToAllDestinations(varargin{:});
                    else
                        tracerObj.undoTraceAllStyling;
                    end
                end
            catch
                err=MException(message('Simulink:HiliteTool:FirstCallFailure'));
                AppManager.processError(BD,err);
            end
        end
    end



    methods(Static,Access=public)
        function HighlightFromBlock(blockPath)

            import Simulink.Structure.HiliteTool.*
            import Simulink.Structure.HiliteTool.internal.*



            assert(isequal(class(blockPath),'Simulink.BlockPath'),...
            message('Simulink:HiliteTool:ExpectBlockPathForTracingFromBlock'));
            bpParent=blockPath.getParent();



            if ischar(bpParent)
                open_system(bpParent,'force','tab');
                blockHandle=get_param(blockPath.getBlock(1),'Handle');
            else
                bpParent.open('opentype','NEW_TAB','force','on');

                len=blockPath.getLength;
                blockHandle=get_param(blockPath.getBlock(len),'Handle');
            end

            assert(isValidBlock(blockHandle),...
            message('Simulink:HiliteTool:ExpectedBlockHandle'));

            BD=getBlockDiagram(blockHandle);

            try
                [~]=AppManager.createNewTracerForBDFromBlock(blockHandle,BD);
            catch ME






                errId=ME.identifier;
                switch errId
                case{'Simulink:HiliteTool:UnconnectedBlockPorts'
                    'Simulink:HiliteTool:ModelNotOpened'}

                    rethrow(ME);
                otherwise

                    err=MException(message('Simulink:HiliteTool:FirstCallFailure'));
                    AppManager.processError(BD,err);
                end
            end
        end
    end



    methods(Static,Access=public)
        function tracerObj=HighlightSignalToDestination(seg)

            import Simulink.Structure.HiliteTool.*
            import Simulink.Structure.HiliteTool.internal.*

            assert(isValidSegment(seg),...
            message('Simulink:HiliteTool:ExpectedSegmentHandle'));

            BD=getBlockDiagram(seg);
            try
                AppManager.showSignalHierarchyViewer(BD,seg);
                tracerObj=AppManager.createNewTracerForBD(seg,false,BD);
                scopedBlocker=SLM3I.ScopedHighlightToolCancelBlocker(BD);%#ok<NASGU> 
                tracerObj=AppManager.stepToDst(tracerObj);
            catch
                err=MException(message('Simulink:HiliteTool:FirstCallFailure'));
                AppManager.processError(BD,err);
            end
        end
    end



    methods(Static,Access=private)
        function tracerObj=stepToDst(tracerObj)
            if(~tracerObj.hiliteObj.isHiliteToSrc)
                tracerObj.traceToDestination;
            else
                tracerObj.undoTrace;
            end
        end
    end



    methods(Static,Access=private)
        function tracerObj=stepToSrc(tracerObj)
            if(tracerObj.hiliteObj.isHiliteToSrc)
                tracerObj.traceToSource;
            else
                tracerObj.undoTrace;
            end
        end
    end



    methods(Static,Access=public,Hidden=true)
        function continueTraceToSource(BD)
            import Simulink.Structure.HiliteTool.*
            assert(isHandleToBD(BD),...
            message('Simulink:HiliteTool:ExpectedBDHandle'));

            BD=graphManager.findOwner(BD);
            try
                tracerObj=AppManager.getExistingTracerForBD(BD);

                if(~isempty(tracerObj))
                    AppManager.showSignalHierarchyViewer(BD,tracerObj);
                    AppManager.stepToSrc(tracerObj);
                end
            catch err
                AppManager.processError(BD,err);
            end
        end
    end



    methods(Static,Access=public,Hidden=true)
        function continueTraceToAllSources(BD)
            import Simulink.Structure.HiliteTool.*
            assert(isHandleToBD(BD),...
            message('Simulink:HiliteTool:ExpectedBDHandle'));

            BD=graphManager.findOwner(BD);
            try
                tracerObj=AppManager.getExistingTracerForBD(BD);

                if(~isempty(tracerObj))
                    if(tracerObj.hiliteObj.isHiliteToSrc)
                        tracerObj.traceToAllSources;
                    else
                        tracerObj.undoTraceAllStyling;
                    end
                end
            catch err
                AppManager.processError(BD,err);
            end
        end
    end



    methods(Static,Access=public,Hidden=true)
        function continueTraceToDestination(BD)
            import Simulink.Structure.HiliteTool.*
            assert(isHandleToBD(BD),...
            message('Simulink:HiliteTool:ExpectedBDHandle'));

            BD=graphManager.findOwner(BD);
            try
                tracerObj=AppManager.getExistingTracerForBD(BD);

                if(~isempty(tracerObj))
                    AppManager.showSignalHierarchyViewer(BD,tracerObj);
                    AppManager.stepToDst(tracerObj);
                end
            catch err
                AppManager.processError(BD,err);
            end
        end
    end



    methods(Static,Access=public,Hidden=true)
        function continueTraceToAllDestinations(BD)
            import Simulink.Structure.HiliteTool.*
            assert(isHandleToBD(BD),...
            message('Simulink:HiliteTool:ExpectedBDHandle'));

            BD=graphManager.findOwner(BD);
            try
                tracerObj=AppManager.getExistingTracerForBD(BD);

                if(~isempty(tracerObj))
                    if(~tracerObj.hiliteObj.isHiliteToSrc)
                        tracerObj.traceToAllDestinations;
                    else
                        tracerObj.undoTraceAllStyling;
                    end
                end
            catch err
                AppManager.processError(BD,err);
            end
        end
    end



    methods(Static,Access=public,Hidden=true)
        function toggleUp(BD)
            import Simulink.Structure.HiliteTool.*
            assert(isHandleToBD(BD),...
            message('Simulink:HiliteTool:ExpectedBDHandle'));

            BD=graphManager.findOwner(BD);
            try
                tracerObj=AppManager.getExistingTracerForBD(BD);

                if(~isempty(tracerObj))
                    toggleUp(tracerObj);
                end
            catch err
                AppManager.processError(BD,err);
            end
        end
    end



    methods(Static,Access=public,Hidden=true)
        function toggleDown(BD)
            import Simulink.Structure.HiliteTool.*
            assert(isHandleToBD(BD),...
            message('Simulink:HiliteTool:ExpectedBDHandle'));

            BD=graphManager.findOwner(BD);
            try
                tracerObj=AppManager.getExistingTracerForBD(BD);

                if(~isempty(tracerObj))
                    toggleDown(tracerObj);
                end
            catch err
                AppManager.processError(BD,err);
            end
        end
    end



    methods(Static,Access=public,Hidden=true)
        function togglePortDisplay(BD,togglePortsOnTraceAllPath)
            import Simulink.Structure.HiliteTool.*
            assert(isHandleToBD(BD),...
            message('Simulink:HiliteTool:ExpectedBDHandle'));
            assert(islogical(togglePortsOnTraceAllPath));

            BD=graphManager.findOwner(BD);
            try
                tracerObj=AppManager.getExistingTracerForBD(BD);

                if(~isempty(tracerObj))
                    scopedBlocker=SLM3I.ScopedHighlightToolCancelBlocker(BD);%#ok<NASGU> 
                    togglePortDisplay(tracerObj,togglePortsOnTraceAllPath);
                end
            catch err
                AppManager.processError(BD,err);
            end
        end
    end



    methods(Static,Access=public,Hidden=true)
        function removeAdvancedHighlighting(BD)
            import Simulink.Structure.HiliteTool.*
            assert(isHandleToBD(BD),...
            message('Simulink:HiliteTool:ExpectedBDHandle'));

            manager=AppManager.getInstance;
            try
                if(bdIsLoaded(get_param(BD,'name')))
                    BD=graphManager.findOwner(BD);
                end
            catch

            end

            if(isKey(manager.BDMap,BD))
                delete(manager.BDMap(BD));
                remove(manager.BDMap,BD);
            end

            if(isKey(manager.listenerMap,BD))
                delete(manager.listenerMap(BD));
                remove(manager.listenerMap,BD);
            end
        end
    end






    methods(Static,Access=public,Hidden=true)
        function dismissHighlightingCommand(bd,editor)
            editorDomain=editor.getStudio.getActiveDomain();
            editorDomain.createParamChangesCommand(...
            editor,...
            'Simulink:HiliteTool:DismissHighlightsDescription',...
            DAStudio.message('Simulink:HiliteTool:DismissHighlightsDescription'),...
            @loc_doUndoableRemoveAdvancedHighlighting,...
            {bd},...
            true,...
            false,...
            false,...
            true,...
            true);
        end
    end



    methods(Static,Access=public,Hidden=true)
        function bool=isBDInAdvancedHighlightingMode(BD)
            import Simulink.Structure.HiliteTool.*
            assert(isHandleToBD(BD),...
            message('Simulink:HiliteTool:ExpectedBDHandle'));

            bool=false;
            BD=graphManager.findOwner(BD);
            tracerObj=AppManager.getExistingTracerForBD(BD);

            if(~isempty(tracerObj))
                bool=true;
            end
        end
    end



    methods(Static,Access=private)
        function processError(BD,err)
            import Simulink.Structure.HiliteTool.*
            AppManager.cleanUpExistingTraceForBD(BD);
            switch err.identifier
            case 'Simulink:HiliteTool:InvalidOwner'
                rethrow(err);
            case{'Simulink:Commands:InvSimulinkObjSpecifierSegment',...
                'Simulink:Commands:InvSimulinkObjHandle',...
                'Simulink:Commands:FindSystemInvalidElement'}
                error(message('Simulink:HiliteTool:InvalidCachedHandle'));
            case 'Simulink:HiliteTool:ModelNotOpened'
                rethrow(err);
            otherwise
                error(message('Simulink:HiliteTool:UnhandledError'));
            end
        end
    end





    methods(Static)
        function showSignalHierarchyViewer(varargin)



            warnID='Simulink:Bus:EditTimeBusPropFailureOutputPort';
            os=warning('off',warnID);
            c=onCleanup(@()warning(os.state,warnID));

            BD=varargin{1};
            if isobject(varargin{2})
                tracerObj=varargin{2};
                seg=tracerObj.hiliteObj.CurrentSegment;
            else
                seg=varargin{2};
            end



            srcPort=get_param(seg,'SrcPortHandle');
            sig=get_param(srcPort,'SignalHierarchy');
            if~isempty(sig)&&~isempty(sig.Children)&&BD~=0


                selectedSegs=find_system(BD,'findAll','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'type','line','selected','on');


                if~isempty(selectedSegs)
                    for i=1:length(selectedSegs)
                        set_param(selectedSegs(i),'Selected','off');
                    end
                end
                set_param(seg,'Selected','on');
                show(Simulink.BusHierarchyViewerWindowMgr.getDialog(getfullname(BD)));
            end
        end
    end
end



function[success,noop]=loc_doUndoableRemoveAdvancedHighlighting(bd)
    noop=false;
    success=true;
    Simulink.Structure.HiliteTool.AppManager.removeAdvancedHighlighting(bd);
end
