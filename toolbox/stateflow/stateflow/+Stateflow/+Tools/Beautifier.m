
%

%   Copyright 2016-2021 The MathWorks, Inc.

classdef Beautifier < handle
    properties
        editor = [];
        subview = [];
        setOfTransitions;
        setOfTransitionIds;
        setOfTransitionParentIds;
        setOfTransitionM3IObjs;
        setOfIdToM3IObjMap;
        setOfOutTransMap;
        M3ITransInfoMap;
        setOfInitialTransPositionInfo;
        notificationStructMap;
        AllowNotificationDisplay = true;
    end

    properties (Constant)
        LABEL_PADDING = 7;
        LABEL_TO_TRANSITION_DISTANCE_PADDING = 3;
        BOUNDING_BOX_PADDING = 2;
        TRANSITION_BOUNDING_BOX_RATIO = 0.4;
        STATE_BOUNDARY_RATIO = 0.8;
        STATE_CORNER_EDGE = 4;
        NORTHEAST_OCLOCK = 1.5;
        SOUTHEAST_OCLOCK = 4.5;
        SOUTHWEST_OCLOCK = 7.5;
        NORTHWEST_OCLOCK = 10.5;
        STATE_BORDER_PADDING = 5;
        INNER_TRANSITION_PADDING = 30;
        MINIMAL_WIDTH_FOR_FCN = 105;
        MINIMAL_WIDTH_FOR_STATE = 90;
    end

    methods (Access = private)

        function self = Beautifier( editorH )
            self.editor = editorH;
        end

        function results = beautify( self )
            if sf('feature', 'Diagram Auto-Beautification') >= 1
                backendId = self.editor.getDiagram.backendId;
                subviewerId = double( backendId );
                self.subview = self.getHandleFromId( subviewerId );
                if isa(self.subview, 'Stateflow.Chart')
                    chartH = self.subview;
                else
                    chartH = self.subview.Chart;
                end
                if ~isa(self.subview, 'Stateflow.TruthTable') && isequal(chartH.ActionLanguage, 'C') && ~chartH.UserSpecifiedStateTransitionExecutionOrder
                    self.deliverInfoNotification('Stateflow:ArrangeLayout:ArrangeLayoutFailedNotification',...
                                                 message('Stateflow:studio:ArrangeLayoutFailedNotification').getString());
                    error('Stateflow:studio:UserSpecifiedExecOrderUnchecked', message('Stateflow:studio:UserSpecifiedExecOrderUnchecked').getString());
                end
                if isa(self.subview, 'Stateflow.Chart') || isa(self.subview, 'Stateflow.TruthTable') || ~isa(self.subview, 'Stateflow.Chart') && ~self.subview.IsGrouped
                    grapicalObjSetOnCurrentView = self.subview.find('-isa', 'Stateflow.DDObject', 'Subviewer', self.subview);
                    if ~isa(self.subview, 'Stateflow.Chart')
                        if ~isa(self.subview, 'Stateflow.AtomicSubchart')
                            grapicalObjSetOnCurrentView = [grapicalObjSetOnCurrentView; self.subview];
                        end
                    end
                    if isempty( grapicalObjSetOnCurrentView )
                        self.deliverInfoNotification('Stateflow:ArrangeLayout:ArrangeLayoutSucceededNotification',...
                                                     message('Stateflow:studio:ArrangeLayoutSucceededNotification').getString());
                        results = MException('Stateflow:ArrangeLayout:NoLayoutArrangement', message('Stateflow:studio:NoLayoutArrangement').getString());
                        return;
                    end

                    self.notificationStructMap = self.getNotificationStructMapOnCurrentView( grapicalObjSetOnCurrentView );
                    self.setOfIdToM3IObjMap = self.getIdToM3IObjMap( grapicalObjSetOnCurrentView );
                    self.setOfTransitions = self.getTransitionsOnCurrentView();
                    self.setOfTransitionIds = arrayfun( @(x) x.id, self.setOfTransitions );
                    self.setOfTransitionParentIds = sf('get', self.setOfTransitionIds, '.parent');
                    m3iSet = arrayfun(@(x) StateflowDI.Util.getDiagramElement(x.id), self.setOfTransitions, 'UniformOutput', false);
                    self.setOfTransitionM3IObjs = cellfun(@(x) x.temporaryObject, m3iSet, 'UniformOutput', false);
                    self.setOfInitialTransPositionInfo = self.getInitPositionOfTransOnCurrentView();
                    self.setOfOutTransMap = self.getOutTransMapForObjs( grapicalObjSetOnCurrentView );
                    undoId = 'Stateflow:studio:ArrangeLayoutUndoString';
                    undoStr = message(undoId).getString();

                    objToParentPairBefore = self.calParentForEachObj(grapicalObjSetOnCurrentView);
                    objBadIntersecBefore = self.calBadIntersectForEachObj(grapicalObjSetOnCurrentView);
                    straightTransIdsBefore = self.findStraightTransitions();
                    self.editor.createMCommand( undoId, undoStr, ...
                                                @self.implChartBeautifier, {});
                    objToParentPairAfter = self.calParentForEachObj(grapicalObjSetOnCurrentView);
                    objBadIntersecAfter = self.calBadIntersectForEachObj(grapicalObjSetOnCurrentView);
                    straightTransIdsAfter = self.findStraightTransitions();
                    if isprop(self.subview, 'Locked') && self.subview.Locked
                        results = MException('Stateflow:ArrangeLayout:ContentIsLocked', message('Stateflow:studio:ContentIsLocked').getString());
                        return;
                    elseif ~isequal( objToParentPairBefore, objToParentPairAfter )
                        self.undoBeautification();
                        firstObjIdChangedSemantics = self.findFirstObjIdChangedSemantics( objToParentPairBefore, objToParentPairAfter);
                        self.deliverInfoNotification('Stateflow:ArrangeLayout:ArrangeLayoutFailedNotification',...
                                                     message('Stateflow:studio:ArrangeLayoutFailedNotification').getString());
                        error('Stateflow:studio:ParentChangedForObject', message('Stateflow:studio:ParentChangedForObject', sf('GetHyperLinkedNameForObject', firstObjIdChangedSemantics)).getString());
                    elseif ~isequal( objBadIntersecBefore , objBadIntersecAfter )
                        self.undoBeautification();
                        firstObjHasBadIntersect = self.findFirstObjIdHasBadIntersection( objBadIntersecBefore, objBadIntersecAfter);
                        self.deliverInfoNotification('Stateflow:ArrangeLayout:ArrangeLayoutFailedNotification',...
                                                     message('Stateflow:studio:ArrangeLayoutFailedNotification').getString());
                        error('Stateflow:studio:BadIntersectionForObject', message('Stateflow:studio:BadIntersectionForObject', sf('GetHyperLinkedNameForObject', firstObjHasBadIntersect)).getString());
                    else
                        transIdsStraightened = setdiff(straightTransIdsAfter, straightTransIdsBefore);
                        results = self.collectResults(grapicalObjSetOnCurrentView, transIdsStraightened);
                        self.deliverInfoNotification('Stateflow:ArrangeLayout:ArrangeLayoutSucceededNotification',...
                                                     message('Stateflow:studio:ArrangeLayoutSucceededNotification').getString());
                    end
                else
                    self.deliverInfoNotification('Stateflow:ArrangeLayout:ArrangeLayoutFailedNotification',...
                                                 message('Stateflow:studio:ArrangeLayoutFailedNotification').getString());
                    error('Stateflow:studio:Grouped', message('Stateflow:studio:Grouped', sf('GetHyperLinkedNameForObject', self.subview.Id)).getString());
                end
            else
                self.deliverInfoNotification('Stateflow:ArrangeLayout:ArrangeLayoutFailedNotification',...
                                             message('Stateflow:studio:ArrangeLayoutFailedNotification').getString());
                error('Stateflow:studio:FeatureNotSwitchedOn', message('Stateflow:studio:FeatureNotSwitchedOn').getString());
            end
        end

        function deliverInfoNotification(self, varargin)
            if self.AllowNotificationDisplay
                self.editor.deliverInfoNotification(varargin{:});
            end
        end
        
        function val = isaInternalPort(~,obj) 
            val = false;
            if isa(obj, 'Stateflow.Port')
                val = strcmp(obj.PortType, 'ExitJunction') || strcmp(obj.PortType, 'EntryJunction');
            end
        end
        
        function val = isaJunctionOrInternalPort(self,obj)
           val = isa(obj, 'Stateflow.Junction') || isaInternalPort(self,obj);
        end

        function callStr = generateFcnCallForHyperlink(~, chartId, objIds)
            callStr = sprintf('sf(''Select'', %i,', chartId);
            objList = sprintf('%i, ', objIds(1:end-1));
            callStr = sprintf('%s [%s%i])', callStr, objList, objIds(end));
        end

        function results = collectResults( self, grapicalObjSetOnCurrentView, transIdsStraightened )
            numObjsResized = 0;
            numObjsAligned = 0;
            numTransLabelRepositioned = 0;
            objIdsResized = [];
            objIdsAligned = [];
            objIdsRepositioned = [];
            if isa(self.subview, 'Stateflow.Chart')
                chartId = self.subview.Id;
            else
                chartId = self.subview.Chart.Id;
            end
            for iter = 1:length(grapicalObjSetOnCurrentView)
                id = grapicalObjSetOnCurrentView(iter).Id;
                if self.notificationStructMap(id).isResized
                    numObjsResized = numObjsResized + 1;
                    objIdsResized = [objIdsResized id]; %#ok<AGROW>
                end
                if self.notificationStructMap(id).isAligned
                    numObjsAligned = numObjsAligned + 1;
                    objIdsAligned = [objIdsAligned id]; %#ok<AGROW>
                end
                if self.notificationStructMap(id).isRepositioned
                    numTransLabelRepositioned = numTransLabelRepositioned + 1;
                    objIdsRepositioned = [objIdsRepositioned id]; %#ok<AGROW>
                end
            end

            results = MException('Stateflow:ArrangeLayout:Successful', ...
                                 message('Stateflow:studio:ArrangeLayoutPassed').getString());

            if numObjsResized > 0
                callStrForResize = self.generateFcnCallForHyperlink(chartId, objIdsResized);
                hyperLinkStrForResize = sprintf('<a href="matlab:%s">%i</a>', callStrForResize, numObjsResized);
                msg = message('Stateflow:studio:NumObjectsResized', hyperLinkStrForResize).getString();
                results = results.addCause(MException('Stateflow:ArrangeLayout:NumObjectsResized', msg));
            end
            if numObjsAligned > 0
                callStrForAligned = self.generateFcnCallForHyperlink(chartId, objIdsAligned);
                hyperLinkStrForAligned = sprintf('<a href="matlab:%s">%i</a>', callStrForAligned, numObjsAligned);
                msg = message('Stateflow:studio:NumObjectsAligned', hyperLinkStrForAligned).getString();
                results = results.addCause(MException('Stateflow:ArrangeLayout:NumObjectsAligned', msg));
            end
            if ~isempty(transIdsStraightened)
                numTransStraightened = length(transIdsStraightened);
                callStrForStraightened = self.generateFcnCallForHyperlink(chartId, transIdsStraightened);
                hyperLinkStrForStraightened = sprintf('<a href="matlab:%s">%i</a>', callStrForStraightened, numTransStraightened);
                msg = message('Stateflow:studio:NumTransStraightened', hyperLinkStrForStraightened).getString();
                results = results.addCause(MException('Stateflow:ArrangeLayout:NumTransStraightened', msg));
            else
                numTransStraightened = 0;
            end
            if numTransLabelRepositioned > 0
                callStrForRepositioned = self.generateFcnCallForHyperlink(chartId, objIdsRepositioned);
                hyperLinkStrForRepositioned = sprintf('<a href="matlab:%s">%i</a>', callStrForRepositioned, numTransLabelRepositioned);
                msg = message('Stateflow:studio:NumTransLabelRepositioned', hyperLinkStrForRepositioned).getString();
                results = results.addCause(MException('Stateflow:ArrangeLayout:NumTransLabelRepositioned', msg));
            end
            % If nothing needs to be arranged
            if ~numObjsResized && ~numObjsAligned && ~numTransStraightened && ~numTransLabelRepositioned
                results = MException('Stateflow:ArrangeLayout:NoLayoutArrangement', message('Stateflow:studio:NoLayoutArrangement').getString());
            end
        end

        function objId = findFirstObjIdChangedSemantics( ~, objToParentPairBefore, objToParentPairAfter)
            keys = cell2mat(objToParentPairBefore.keys);
            if ~isempty( keys )
                for iter = 1:length(keys)
                    if objToParentPairBefore(keys(iter)) ~= objToParentPairAfter(keys(iter))
                        objId = keys(iter);
                        return;
                    end
                end
            end
            objId = [];
        end

        function objId = findFirstObjIdHasBadIntersection(self, objBadIntersecBefore, objBadIntersecAfter)
            objId = self.findFirstObjIdChangedSemantics( objBadIntersecBefore, objBadIntersecAfter);
        end

        function objM3I = getObjsFromIdsInM3ISet( self, objH )
            objM3I = [];
            if isKey(self.setOfIdToM3IObjMap, objH.Id)
                objM3I = self.setOfIdToM3IObjMap(objH.Id);
            end
        end

        function implChartBeautifier( self )
            groupingInfo = self.getGroupingInfoForObjs();
            self.implAdjustHorizontally( self.subview );
            self.implAdjustVertically( self.subview );
            self.M3ITransInfoMap = self.getTransitionInfoOnCurrentView();
            if sf('feature', 'Diagram Auto-Beautification') >= 4
                self.implStraightenTransitions();
            end
            self.implRepositionTransitionLabels( self.setOfTransitions );
            self.restoreGroupingIfNeeded( groupingInfo, self.subview );
        end

        function implStraightenTransitions(self)
            transIdxSet = false([length(self.setOfTransitions) 1]);
            for i = 1:length(self.setOfTransitions)
                x = self.setOfTransitions(i);
                if ~isempty(x.Source) && ~isempty(x.Destination) && (self.transitionIsHorizontal(x) || self.transitionIsVertical(x)) && ~self.transitionIsAlreadyStraight(x)
                    transIdxSet(i) = true;
                end
            end
            candidateTrans = self.setOfTransitions( transIdxSet );
            self.tryToStraightenTransitions(candidateTrans);
        end

        function tf = transitionShouldBeStraightened( self, trans )
            tf = 0;
            topPosY = min(trans.SourceEndpoint(2), min(trans.MidPoint(2), trans.DestinationEndpoint(2)));
            botPosY = max(trans.SourceEndpoint(2), max(trans.MidPoint(2), trans.DestinationEndpoint(2)));
            rectHeight = botPosY - topPosY;

            leftPosX = min(trans.SourceEndpoint(1), min(trans.MidPoint(1), trans.DestinationEndpoint(1)));
            rightPosX = max(trans.SourceEndpoint(1), max(trans.MidPoint(1), trans.DestinationEndpoint(1)));
            rectWidth = rightPosX - leftPosX;
            if self.transitionIsHorizontal( trans )
                if rectHeight / rectWidth < self.TRANSITION_BOUNDING_BOX_RATIO
                    tf = 1;
                end
            elseif self.transitionIsVertical( trans )
                if rectWidth / rectHeight < self.TRANSITION_BOUNDING_BOX_RATIO
                    tf = 1;
                end
            end
        end

        function count = transitionsBetweenTwoObjects(~, obj1, obj2)

            setOfSinkedTransForObj1  = sf('SinkedTransitionsOf', obj1.Id);
            setOfSinkedTransForObj2  = sf('SinkedTransitionsOf', obj2.Id);

            setOfSourcedTransForObj1 = sf('SourcedTransitionsOf', obj1.Id);
            setOfSourcedTransForObj2 = sf('SourcedTransitionsOf', obj2.Id);

            setOfCommonTransPart1 = intersect(setOfSinkedTransForObj1, setOfSourcedTransForObj2);
            setOfCommonTransPart2 = intersect(setOfSinkedTransForObj2, setOfSourcedTransForObj1);

            count = length( setOfCommonTransPart1 ) + length( setOfCommonTransPart2 );
        end

        function tryToStraightenTransitions(self, transitions)
            for trans = transitions(:)'
                m3iTrans = self.getObjsFromIdsInM3ISet( trans );
                [src, dst] = self.doesTransProjectOnBothSides( trans );
                p = self.getSrcDstPositionsForTrans( trans );
                if src && dst
                    if self.transitionIsHorizontal( trans )
                        if self.isaJunctionOrInternalPort(trans.Source) && self.isaJunctionOrInternalPort(trans.Destination)
                            if self.transitionsBetweenTwoObjects(trans.Source, trans.Destination) == 1
                                if m3iTrans.srcTangent(1) >=  0.9 && abs(m3iTrans.srcTangent(2)) <= 0.3 && m3iTrans.dstTangent(1) <= -0.9 && abs(m3iTrans.dstTangent(2)) <= 0.3
                                    m3iTrans.srcPosAbs = [trans.Source.Position.Center(1) + trans.Source.Position.Radius trans.Source.Position.Center(2)];
                                    m3iTrans.dstPosAbs = [trans.Destination.Position.Center(1) - trans.Destination.Position.Radius trans.Destination.Position.Center(2)];
                                    m3iTrans.srcTangent = [ 1 0];
                                    m3iTrans.dstTangent = [-1 0];
                                else
                                    m3iTrans.srcPosAbs = [trans.Source.Position.Center(1) - trans.Source.Position.Radius trans.Source.Position.Center(2)];
                                    m3iTrans.dstPosAbs = [trans.Destination.Position.Center(1) + trans.Destination.Position.Radius trans.Destination.Position.Center(2)];
                                    m3iTrans.srcTangent = [-1 0];
                                    m3iTrans.dstTangent = [ 1 0];
                                end
                                m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1)/2 + m3iTrans.dstPosAbs(1)/2;
                                m3iTrans.midPosAbs(2) = m3iTrans.srcPosAbs(2)/2 + m3iTrans.dstPosAbs(2)/2;
                            end
                        elseif self.isaJunctionOrInternalPort(trans.Source)
                            if self.transitionsBetweenTwoObjects(trans.Source, trans.Destination) == 1
                                if m3iTrans.srcTangent(1) >=  0.9 && abs(m3iTrans.srcTangent(2)) <= 0.3 && m3iTrans.dstTangent(1) <= -0.9 && abs(m3iTrans.dstTangent(2)) <= 0.3
                                    m3iTrans.srcPosAbs = [trans.Source.Position.Center(1) + trans.Source.Position.Radius trans.Source.Position.Center(2)];
                                    m3iTrans.dstPosAbs(2) = trans.Source.Position.Center(2);
                                    m3iTrans.srcTangent = [ 1 0];
                                    m3iTrans.dstTangent = [-1 0];
                                else
                                    m3iTrans.srcPosAbs = [trans.Source.Position.Center(1) - trans.Source.Position.Radius trans.Source.Position.Center(2)];
                                    m3iTrans.dstPosAbs(2) = trans.Source.Position.Center(2);
                                    m3iTrans.srcTangent = [-1 0];
                                    m3iTrans.dstTangent = [ 1 0];
                                end
                                m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1)/2 + m3iTrans.dstPosAbs(1)/2;
                                m3iTrans.midPosAbs(2) = m3iTrans.srcPosAbs(2)/2 + m3iTrans.dstPosAbs(2)/2;
                            end
                        elseif self.isaJunctionOrInternalPort(trans.Destination)
                            if self.transitionsBetweenTwoObjects(trans.Source, trans.Destination) == 1
                                if m3iTrans.srcTangent(1) >=  0.9 && abs(m3iTrans.srcTangent(2)) <= 0.3 && m3iTrans.dstTangent(1) <= -0.9 && abs(m3iTrans.dstTangent(2)) <= 0.3
                                    m3iTrans.srcPosAbs(2) = trans.Destination.Position.Center(2);
                                    m3iTrans.dstPosAbs = [trans.Destination.Position.Center(1) - trans.Destination.Position.Radius trans.Destination.Position.Center(2)];
                                    m3iTrans.srcTangent = [ 1 0];
                                    m3iTrans.dstTangent = [-1 0];
                                else
                                    m3iTrans.srcPosAbs(2) = trans.Destination.Position.Center(2);
                                    m3iTrans.dstPosAbs = [trans.Destination.Position.Center(1) + trans.Destination.Position.Radius trans.Destination.Position.Center(2)];
                                    m3iTrans.srcTangent = [-1 0];
                                    m3iTrans.dstTangent = [ 1 0];
                                end
                                m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1)/2 + m3iTrans.dstPosAbs(1)/2;
                                m3iTrans.midPosAbs(2) = m3iTrans.srcPosAbs(2)/2 + m3iTrans.dstPosAbs(2)/2;
                            end
                        else
                            if m3iTrans.srcTangent(1) >=  0.9 && abs(m3iTrans.srcTangent(2)) <= 0.3 && m3iTrans.dstTangent(1) <= -0.9 && abs(m3iTrans.dstTangent(2)) <= 0.3
                                m3iTrans.dstPosAbs(2) = m3iTrans.srcPosAbs(2);
                                m3iTrans.midPosAbs(2) = m3iTrans.srcPosAbs(2);
                                m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1)/2 + m3iTrans.dstPosAbs(1)/2;
                            else
                                m3iTrans.srcPosAbs(2) = m3iTrans.dstPosAbs(2);
                                m3iTrans.midPosAbs(2) = m3iTrans.dstPosAbs(2);
                                m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1)/2 + m3iTrans.dstPosAbs(1)/2;
                            end
                        end
                    elseif self.transitionIsVertical( trans )
                        if self.isaJunctionOrInternalPort(trans.Source) && self.isaJunctionOrInternalPort(trans.Destination)
                            if self.transitionsBetweenTwoObjects(trans.Source, trans.Destination) == 1
                                if m3iTrans.srcTangent(2) >=  0.9 && abs(m3iTrans.srcTangent(1)) <= 0.3 && m3iTrans.dstTangent(2) <= -0.9 && abs(m3iTrans.dstTangent(1)) <= 0.3
                                    m3iTrans.srcPosAbs = [trans.Source.Position.Center(1) trans.Source.Position.Center(2) + trans.Source.Position.Radius];
                                    m3iTrans.dstPosAbs = [trans.Destination.Position.Center(1) trans.Destination.Position.Center(2) - trans.Destination.Position.Radius];
                                    m3iTrans.srcTangent = [0  1];
                                    m3iTrans.dstTangent = [0 -1];
                                else
                                    m3iTrans.srcPosAbs = [trans.Source.Position.Center(1) trans.Source.Position.Center(2) - trans.Source.Position.Radius];
                                    m3iTrans.dstPosAbs = [trans.Destination.Position.Center(1) trans.Destination.Position.Center(2) + trans.Destination.Position.Radius];
                                    m3iTrans.srcTangent = [0 -1];
                                    m3iTrans.dstTangent = [0  1];
                                end
                                m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1)/2 + m3iTrans.dstPosAbs(1)/2;
                                m3iTrans.midPosAbs(2) = m3iTrans.srcPosAbs(2)/2 + m3iTrans.dstPosAbs(2)/2;
                            end
                        elseif self.isaJunctionOrInternalPort(trans.Source)
                            if self.transitionsBetweenTwoObjects(trans.Source, trans.Destination) == 1
                                if m3iTrans.srcTangent(2) >=  0.9 && abs(m3iTrans.srcTangent(1)) <= 0.3 && m3iTrans.dstTangent(2) <= -0.9 && abs(m3iTrans.dstTangent(1)) <= 0.3
                                    m3iTrans.srcPosAbs = [trans.Source.Position.Center(1) trans.Source.Position.Center(2) + trans.Source.Position.Radius];
                                    m3iTrans.dstPosAbs(1) = trans.Source.Position.Center(1);
                                    m3iTrans.srcTangent = [0  1];
                                    m3iTrans.dstTangent = [0 -1];
                                else
                                    m3iTrans.srcPosAbs = [trans.Source.Position.Center(1) trans.Source.Position.Center(2) - trans.Source.Position.Radius];
                                    m3iTrans.dstPosAbs(1) = trans.Source.Position.Center(1);
                                    m3iTrans.srcTangent = [0 -1];
                                    m3iTrans.dstTangent = [0  1];
                                end
                                m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1)/2 + m3iTrans.dstPosAbs(1)/2;
                                m3iTrans.midPosAbs(2) = m3iTrans.srcPosAbs(2)/2 + m3iTrans.dstPosAbs(2)/2;
                            end
                        elseif self.isaJunctionOrInternalPort(trans.Destination)
                            if self.transitionsBetweenTwoObjects(trans.Source, trans.Destination) == 1
                                if m3iTrans.srcTangent(2) >=  0.9 && abs(m3iTrans.srcTangent(1)) <= 0.3 && m3iTrans.dstTangent(2) <= -0.9 && abs(m3iTrans.dstTangent(1)) <= 0.3
                                    m3iTrans.srcPosAbs(1) = trans.Destination.Position.Center(1);
                                    m3iTrans.dstPosAbs = [trans.Destination.Position.Center(1) trans.Destination.Position.Center(2) - trans.Destination.Position.Radius];
                                    m3iTrans.srcTangent = [0  1];
                                    m3iTrans.dstTangent = [0 -1];
                                else
                                    m3iTrans.srcPosAbs(1) = trans.Destination.Position.Center(1);
                                    m3iTrans.dstPosAbs = [trans.Destination.Position.Center(1) trans.Destination.Position.Center(2) + trans.Destination.Position.Radius];
                                    m3iTrans.srcTangent = [0 -1];
                                    m3iTrans.dstTangent = [0  1];
                                end
                                m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1)/2 + m3iTrans.dstPosAbs(1)/2;
                                m3iTrans.midPosAbs(2) = m3iTrans.srcPosAbs(2)/2 + m3iTrans.dstPosAbs(2)/2;
                            end
                        else
                            midLine = max(p.srcLeftPosX , p.dstLeftPosX ) + ...
                                      (min(p.srcRightPosX, p.dstRightPosX) - max(p.srcLeftPosX, p.dstLeftPosX)) / 2;
                            if abs(midLine - trans.SourceEndpoint(1)) < abs(midLine - trans.DestinationEndpoint(1))
                                m3iTrans.dstPosAbs(1) = m3iTrans.srcPosAbs(1);
                                m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1);
                                m3iTrans.midPosAbs(2) = m3iTrans.srcPosAbs(2)/2 + m3iTrans.dstPosAbs(2)/2;
                            else
                                m3iTrans.srcPosAbs(1) = m3iTrans.dstPosAbs(1);
                                m3iTrans.midPosAbs(1) = m3iTrans.dstPosAbs(1);
                                m3iTrans.midPosAbs(2) = m3iTrans.srcPosAbs(2)/2 + m3iTrans.dstPosAbs(2)/2;
                            end
                        end
                    end
                elseif src
                    if self.transitionIsHorizontal( trans ) && ...
                            (~self.isaJunctionOrInternalPort( trans.Source) && ~self.isaJunctionOrInternalPort( trans.Destination)) || ...
                            self.transitionIsHorizontal( trans ) && ...
                            (self.isaJunctionOrInternalPort( trans.Source) || self.isaJunctionOrInternalPort( trans.Destination)) && ...
                            self.transitionsBetweenTwoObjects(trans.Source, trans.Destination) == 1
                        m3iTrans.dstPosAbs(2) = m3iTrans.srcPosAbs(2);
                        m3iTrans.midPosAbs(2) = m3iTrans.srcPosAbs(2);
                        m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1)/2 + m3iTrans.dstPosAbs(1)/2;
                    elseif self.transitionIsVertical( trans ) && ...
                            (~self.isaJunctionOrInternalPort( trans.Source ) && ~self.isaJunctionOrInternalPort( trans.Destination)) || ...
                            self.transitionIsVertical( trans ) && ...
                            (self.isaJunctionOrInternalPort( trans.Source) || self.isaJunctionOrInternalPort( trans.Destination)) && ...
                            self.transitionsBetweenTwoObjects(trans.Source, trans.Destination) == 1
                        m3iTrans.dstPosAbs(1) = m3iTrans.srcPosAbs(1);
                        m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1);
                        m3iTrans.midPosAbs(2) = m3iTrans.srcPosAbs(2)/2 + m3iTrans.dstPosAbs(2)/2;
                    end
                elseif dst
                    if self.transitionIsHorizontal( trans ) && ...
                            (~self.isaJunctionOrInternalPort( trans.Source) && ~self.isaJunctionOrInternalPort( trans.Destination)) || ...
                            self.transitionIsHorizontal( trans ) && ...
                            (self.isaJunctionOrInternalPort( trans.Source) || self.isaJunctionOrInternalPort( trans.Destination)) && ...
                            self.transitionsBetweenTwoObjects(trans.Source, trans.Destination) == 1
                        m3iTrans.srcPosAbs(2) = m3iTrans.dstPosAbs(2);
                        m3iTrans.midPosAbs(2) = m3iTrans.dstPosAbs(2);
                        m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1)/2 + m3iTrans.dstPosAbs(1)/2;
                    elseif self.transitionIsVertical( trans ) && ...
                            (~self.isaJunctionOrInternalPort( trans.Source) && ~self.isaJunctionOrInternalPort( trans.Destination)) || ...
                            self.transitionIsVertical( trans ) && ...
                            (self.isaJunctionOrInternalPort( trans.Source) || self.isaJunctionOrInternalPort( trans.Destination)) && ...
                            self.transitionsBetweenTwoObjects(trans.Source, trans.Destination) == 1
                        m3iTrans.srcPosAbs(1) = m3iTrans.dstPosAbs(1);
                        m3iTrans.midPosAbs(1) = m3iTrans.dstPosAbs(1);
                        m3iTrans.midPosAbs(2) = m3iTrans.srcPosAbs(2)/2 + m3iTrans.dstPosAbs(2)/2;
                    end
                end
            end
        end

        function position = getSrcDstPositionsForTrans( ~, trans )
            if isa(trans.Source, 'Stateflow.Junction') || isa(trans.Source, 'Stateflow.Port')
                position.srcTopPosY = trans.Source.Position.Center(2) - trans.Source.Position.Radius;
                position.srcBotPosY = trans.Source.Position.Center(2) + trans.Source.Position.Radius;

                position.srcLeftPosX = trans.Source.Position.Center(1) - trans.Source.Position.Radius;
                position.srcRightPosX = trans.Source.Position.Center(1) + trans.Source.Position.Radius;
            else
                position.srcTopPosY = trans.Source.Position(2);
                position.srcBotPosY = trans.Source.Position(2) + trans.Source.Position(4);

                position.srcLeftPosX = trans.Source.Position(1);
                position.srcRightPosX = trans.Source.Position(1) + trans.Source.Position(3);
            end

            if isa(trans.Destination, 'Stateflow.Junction') || isa(trans.Destination, 'Stateflow.Port')
                position.dstTopPosY = trans.Destination.Position.Center(2) - trans.Destination.Position.Radius;
                position.dstBotPosY = trans.Destination.Position.Center(2) + trans.Destination.Position.Radius;

                position.dstLeftPosX = trans.Destination.Position.Center(1) - trans.Destination.Position.Radius;
                position.dstRightPosX = trans.Destination.Position.Center(1) + trans.Destination.Position.Radius;
            else
                position.dstTopPosY = trans.Destination.Position(2);
                position.dstBotPosY = trans.Destination.Position(2) + trans.Destination.Position(4);

                position.dstLeftPosX = trans.Destination.Position(1);
                position.dstRightPosX = trans.Destination.Position(1) + trans.Destination.Position(3);
            end
        end

        function [src, dst] = doesTransProjectOnBothSides(self, trans)
            src = false;
            dst = false;
            p = self.getSrcDstPositionsForTrans( trans );

            if self.transitionIsHorizontal( trans )
                if self.isaJunctionOrInternalPort(trans.Source) && trans.SourceEndpoint(2) < min(p.srcBotPosY, p.dstBotPosY) && trans.SourceEndpoint(2) > max(p.srcTopPosY, p.dstTopPosY)
                    src = true;
                elseif trans.SourceEndpoint(2) < min(p.srcBotPosY, p.dstBotPosY) - self.STATE_CORNER_EDGE && ...
                        trans.SourceEndpoint(2) > max(p.srcTopPosY, p.dstTopPosY) + self.STATE_CORNER_EDGE
                    src = true;
                end
                if self.isaJunctionOrInternalPort(trans.Source) && trans.DestinationEndpoint(2) < min(p.srcBotPosY, p.dstBotPosY) && trans.DestinationEndpoint(2) > max(p.srcTopPosY, p.dstTopPosY)
                    dst = true;
                elseif trans.DestinationEndpoint(2) < min(p.srcBotPosY, p.dstBotPosY) - self.STATE_CORNER_EDGE && ...
                        trans.DestinationEndpoint(2) > max(p.srcTopPosY, p.dstTopPosY) + self.STATE_CORNER_EDGE
                    dst = true;
                end
            elseif self.transitionIsVertical( trans )
                if self.isaJunctionOrInternalPort(trans.Source) && trans.SourceEndpoint(1) < min(p.srcRightPosX, p.dstRightPosX) && trans.SourceEndpoint(1) > max(p.srcLeftPosX, p.dstLeftPosX)
                    src = true;
                elseif trans.SourceEndpoint(1) < min(p.srcRightPosX, p.dstRightPosX) - self.STATE_CORNER_EDGE && ...
                        trans.SourceEndpoint(1) > max(p.srcLeftPosX, p.dstLeftPosX)   + self.STATE_CORNER_EDGE
                    src = true;
                end
                if self.isaJunctionOrInternalPort(trans.Source) && trans.DestinationEndpoint(1) < min(p.srcRightPosX, p.dstRightPosX) && trans.DestinationEndpoint(1) > max(p.srcLeftPosX, p.dstLeftPosX)
                    dst = true;
                elseif trans.DestinationEndpoint(1) < min(p.srcRightPosX, p.dstRightPosX) - self.STATE_CORNER_EDGE && ...
                        trans.DestinationEndpoint(1) > max(p.srcLeftPosX, p.dstLeftPosX)   + self.STATE_CORNER_EDGE
                    dst = true;
                end
            end
        end

        function mapObj = getGroupingInfoForObjs( self )
        % This ensures we don't include any atomic-subchart/box.
            objSet = self.subview.find('-isa', 'Stateflow.State',    'Subviewer', self.subview, '-or', ...
                                       '-isa', 'Stateflow.Box',      'Subviewer', self.subview, '-or', ...
                                       '-isa', 'Stateflow.Function', 'Subviewer', self.subview);
            objIdxSet = arrayfun(@(x) x.Id, objSet);
            if isempty( objIdxSet )
                mapObj = [];
            else
                isGrouped = cell(1, length(objIdxSet));
                isGroupContainer = cell(1, length(objIdxSet));
                for iter = 1:length(objIdxSet)
                    isGrouped{iter} = self.getObjsFromIdsInM3ISet(objSet(iter)).isGrouped;
                    isGroupContainer{iter} = self.getObjsFromIdsInM3ISet(objSet(iter)).isGroupContainer;
                end
                groupInfoStuct = struct('isGrouped'           ,    isGrouped, ...
                                        'isGroupContainer'    ,    isGroupContainer       );
                if length( objIdxSet ) == 1
                    mapObj = containers.Map( objIdxSet, groupInfoStuct );
                else
                    mapObj = containers.Map( objIdxSet, arrayfun(@(x) {x}, groupInfoStuct) );
                end
            end
        end

        function restoreGroupingIfNeeded( self, groupingInfo, subview )
            if ~isempty( groupingInfo )
                objSet = subview.find('-isa', 'Stateflow.State',    'Subviewer', subview, '-or', ...
                                      '-isa', 'Stateflow.Box',      'Subviewer', subview, '-or', ...
                                      '-isa', 'Stateflow.Function', 'Subviewer', subview);
                for obj = objSet(:)'
                    m3iObj = self.getObjsFromIdsInM3ISet(obj);
                    if ~isequal( groupingInfo(obj.Id).isGroupContainer, m3iObj.isGroupContainer)
                        m3iObj.isGroupContainer = groupingInfo(obj.Id).isGroupContainer;
                    elseif ~isequal( groupingInfo(obj.Id).isGrouped, m3iObj.isGrouped)
                        m3iObj.isGrouped = groupingInfo(obj.Id).isGrouped;
                    end
                end
            end
        end

        function implAdjustHorizontally( self, objH )
            self.implResizeObjsHorizontally( objH );
        end

        function implAdjustVertically( self, objH )
            self.implResizeObjsVertically( objH );
        end

        function implExpandTransVertically( self, trans, objH )
            verticalTransIdx = false([length(trans) 1]);
            for i = 1:length(trans)
                if self.transitionIsVertical(trans(i)) && ~self.isSuperTransition(trans(i))
                    verticalTransIdx(i) = 1;
                else
                    verticalTransIdx(i) = 0;
                end
            end
            verticalTransUddHs = trans(verticalTransIdx);
            if isempty( verticalTransUddHs )
                return
            else
                graphicalObjs = self.getLvlOneGraphicalObjsFor( objH );
                graphicalObjs = setdiff( graphicalObjs, trans );
                sortedGraphicalObjs = self.sortFromTopToBottom( graphicalObjs' );

                sortedVerticalTrans = self.sortFromTopToBottom( verticalTransUddHs' );

                for obj = sortedVerticalTrans(:)'
                    moveToBottom = self.doesLabelLongerThanTransInHeight( obj );
                    if moveToBottom > 0
                        bottomBoundary = max( obj.SourceEndpoint(2), obj.DestinationEndpoint(2) );
                        if ~isempty( sortedGraphicalObjs )
                            self.implMoveObjsBelowBoundaryToBottom( moveToBottom, bottomBoundary, sortedGraphicalObjs );
                        end
                        if ~isempty( trans )
                            self.implMoveTransToBottom( moveToBottom, bottomBoundary, trans );
                        end
                        if isempty( obj.Source )
                            m3iTrans = self.getObjsFromIdsInM3ISet(obj);
                            if m3iTrans.srcTangent(2) >=  0.9 && abs(m3iTrans.srcTangent(1)) <= 0.3 && m3iTrans.dstTangent(2) <= -0.9 && abs(m3iTrans.dstTangent(1)) <= 0.3
                                m3iTrans.srcPosAbs(2) = m3iTrans.srcPosAbs(2) - moveToBottom;
                            elseif m3iTrans.srcTangent(2) <= -0.9 && abs(m3iTrans.srcTangent(1)) <= 0.3 && m3iTrans.dstTangent(2) >=  0.9 && abs(m3iTrans.dstTangent(1)) <= 0.3
                                m3iTrans.srcPosAbs(2) = m3iTrans.srcPosAbs(2) + moveToBottom;
                            end
                        end
                        if self.notificationStructMap(obj.Id).isResized == 0
                            tmpStruct = self.notificationStructMap(obj.Id);
                            tmpStruct.isResized = 1;
                            self.notificationStructMap(obj.Id) = tmpStruct;
                        end
                    end
                end
            end
        end

        function implExpandTransHorizontally( self, trans, objH )
            horizontalTransIdx = false([length(trans) 1]);
            for i = 1:length(trans)
                if self.transitionIsHorizontal(trans(i)) && ~self.isSuperTransition(trans(i))
                    horizontalTransIdx(i) = 1;
                else
                    horizontalTransIdx(i) = 0;
                end
            end
            horizontalTransUddHs = trans(horizontalTransIdx);
            if isempty( horizontalTransUddHs )
                return
            else
                graphicalObjs = self.getLvlOneGraphicalObjsFor( objH );
                graphicalObjs = setdiff( graphicalObjs, trans );
                sortedGraphicalObjs = self.sortFromLeftToRight( graphicalObjs' );

                sortedHorizontalTrans = self.sortFromLeftToRight( horizontalTransUddHs' );

                for obj = sortedHorizontalTrans(:)'
                    moveToRight = self.doesLabelLongerThanTransInWidth( obj );
                    if moveToRight > 0
                        rightBoundary = max( obj.SourceEndpoint(1), obj.DestinationEndpoint(1) );
                        if ~isempty( sortedGraphicalObjs )
                            self.implMoveObjsOnRightSideOfBoundaryToRight( moveToRight, rightBoundary, sortedGraphicalObjs );
                        end
                        if ~isempty( trans )
                            self.implMoveTransToRight( moveToRight, rightBoundary, trans );
                        end
                        if isempty( obj.Source )
                            m3iTrans = self.getObjsFromIdsInM3ISet(obj);
                            if m3iTrans.srcTangent(1) >=  0.9 && abs(m3iTrans.srcTangent(2)) <= 0.3 && m3iTrans.dstTangent(1) <= -0.9 && abs(m3iTrans.dstTangent(2)) <= 0.3
                                m3iTrans.srcPosAbs(1) = m3iTrans.srcPosAbs(1) - moveToRight;
                                m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1)/2 +  m3iTrans.dstPosAbs(1)/2;
                            elseif m3iTrans.srcTangent(1) <= -0.9 && abs(m3iTrans.srcTangent(2)) <= 0.3 && m3iTrans.dstTangent(1) >=  0.9 && abs(m3iTrans.dstTangent(2)) <= 0.3
                                m3iTrans.srcPosAbs(1) = m3iTrans.srcPosAbs(1) + moveToRight;
                                m3iTrans.midPosAbs(1) = m3iTrans.srcPosAbs(1)/2 +  m3iTrans.dstPosAbs(1)/2;
                            end
                        end
                        if self.notificationStructMap(obj.Id).isResized == 0
                            tmpStruct = self.notificationStructMap(obj.Id);
                            tmpStruct.isResized = 1;
                            self.notificationStructMap(obj.Id) = tmpStruct;
                        end
                    end
                end
            end
        end

        function moveToBottom = doesLabelLongerThanTransInHeight( self, trans )
            m3iTrans = self.getObjsFromIdsInM3ISet(trans);
            if ~isempty(m3iTrans.label) && m3iTrans.labelSize(2) + self.LABEL_PADDING - abs( trans.SourceEndpoint(2) - trans.DestinationEndpoint(2) ) > 0.01
                moveToBottom = m3iTrans.labelSize(2) + self.LABEL_PADDING - abs( trans.SourceEndpoint(2) - trans.DestinationEndpoint(2) );
            else
                moveToBottom = 0;
            end
        end

        function moveToRight = doesLabelLongerThanTransInWidth( self, trans )
            m3iTrans = self.getObjsFromIdsInM3ISet(trans);
            if ~isempty(m3iTrans.label) && m3iTrans.labelSize(1) + self.LABEL_PADDING - abs( trans.SourceEndpoint(1) - trans.DestinationEndpoint(1) ) > 0.01
                moveToRight = m3iTrans.labelSize(1) + self.LABEL_PADDING - abs( trans.SourceEndpoint(1) - trans.DestinationEndpoint(1) );
            else
                moveToRight = 0;
            end
        end

        function deltaY = implResizeObjsVertically( self, objH )
            deltaY = 0;
            graphicalObjs = self.getLvlOneGraphicalObjsFor( objH );
            trans = self.getLvlOneTransFor( objH );
            if ~isempty(trans)
                graphicalObjs = setdiff( graphicalObjs, trans );
            end
            sortedGraphicalObjs = self.sortFromTopToBottom( graphicalObjs' );
            self.M3ITransInfoMap = self.getTransitionInfoOnCurrentView();
            objsNeedResizing = self.getLvlOneObjsNeedResizingFor( objH );
            sortedObjsNeedResizing = self.sortFromTopToBottom( objsNeedResizing' );

            tempObjsNeedResizing = sortedObjsNeedResizing;
            tempGraphicalObjs = sortedGraphicalObjs;

            bbBefore = [];
            if ~isempty( sortedGraphicalObjs )
                % Guarantee there is at least one graphical object besides
                % transitions inside
                if ~isa(objH, 'Stateflow.Chart')          && ...
                        (isa(objH, 'Stateflow.TruthTable') || ~objH.IsSubchart) && ...
                        ~isa(objH, 'Stateflow.AtomicSubchart') && ...
                        ~isa(objH, 'Stateflow.AtomicBox')      && ...
                        ~self.getObjsFromIdsInM3ISet(objH).isGrouped && ...
                        ~self.getObjsFromIdsInM3ISet(objH).isGroupContainer
                    bbBefore = self.findBottomMostBoundaryInsideOfObj( objH );
                end
            end

            while ~isempty( tempObjsNeedResizing )
                alignedObjSet = self.findHorizontalOverlapBetween( tempGraphicalObjs );
                [tfBefore, heightForAll] = self.doAllStatesHaveSameHeight(alignedObjSet);
                setOfTrans = self.findOutTransitionsOf( alignedObjSet );
                transNeedMovingDueToStateExpansion = [];
                if ~isempty(trans) && ~isempty(setOfTrans)
                    transNeedMovingDueToStateExpansion = setdiff( trans', setOfTrans );
                end
                [deltaHeight, bottomBoundary] = self.calcChangeInHeight( alignedObjSet, tfBefore, heightForAll );
                tempGraphicalObjs = self.updateSet( tempGraphicalObjs, alignedObjSet );
                tempGraphicalObjs = self.sortFromTopToBottom( tempGraphicalObjs );
                if  self.objNeedsToBeResized( deltaHeight )
                    moveToBottom = max(deltaHeight);
                    if (moveToBottom > 0)
                        if ~isempty( tempGraphicalObjs )
                            self.implMoveObjsToBottom( moveToBottom, bottomBoundary, tempGraphicalObjs );
                        end
                        if ~isempty( transNeedMovingDueToStateExpansion )
                            self.implMoveTransToBottom( moveToBottom, bottomBoundary, transNeedMovingDueToStateExpansion );
                        end
                    end
                end
                tempObjsNeedResizing = setdiff( tempObjsNeedResizing, alignedObjSet );
                tempObjsNeedResizing = self.sortFromTopToBottom( tempObjsNeedResizing' );

                self.implResizeEachObjVertically( alignedObjSet, deltaHeight, tfBefore );

                if sf('feature', 'Diagram Auto-Beautification') >= 3
                    self.implAlignStatesHorizontally( alignedObjSet );
                end

                self.M3ITransInfoMap = self.getTransitionInfoOnCurrentView();
            end

            if sf('feature', 'Diagram Auto-Beautification') >= 2
                self.implExpandTransVertically( trans, objH );
            end

            self.M3ITransInfoMap = self.getTransitionInfoOnCurrentView();
            self.implTransitionLabelRestoring( trans );

            if ~isempty( bbBefore )
                bbAfter = self.findBottomMostBoundaryInsideOfObj( objH );
                bb = max( bbAfter, bbBefore );
                deltaY = bb + self.STATE_BORDER_PADDING - objH.Position(2) - objH.Position(4);
                deltaY = max(0, deltaY);
            end
        end

        function deltaX = implResizeObjsHorizontally( self, objH )
            deltaX = 0;
            graphicalObjs = self.getLvlOneGraphicalObjsFor( objH );
            trans = self.getLvlOneTransFor( objH );
            if ~isempty(trans)
                graphicalObjs = setdiff( graphicalObjs, trans );
            end
            sortedGraphicalObjs = self.sortFromLeftToRight( graphicalObjs' );
            self.M3ITransInfoMap = self.getTransitionInfoOnCurrentView();

            objsNeedResizing = self.getLvlOneObjsNeedResizingFor( objH );
            sortedObjsNeedResizing = self.sortFromLeftToRight( objsNeedResizing' );

            tempObjsNeedResizing = sortedObjsNeedResizing;
            tempGraphicalObjs = sortedGraphicalObjs;

            rbBefore = [];
            if ~isempty( sortedGraphicalObjs )
                % Guarantee there is at least one graphical object besides
                % transitions inside
                if ~isa(objH, 'Stateflow.Chart')          && ...
                        isprop(objH, 'IsSubchart') && ~objH.IsSubchart && ...
                        ~isa(objH, 'Stateflow.AtomicSubchart') && ...
                        ~isa(objH, 'Stateflow.AtomicBox')      && ...
                        ~self.getObjsFromIdsInM3ISet(objH).isGrouped && ...
                        ~self.getObjsFromIdsInM3ISet(objH).isGroupContainer
                    rbBefore = self.findRightMostBoundaryInsideOfObj( objH );
                end
            end

            while ~isempty( tempObjsNeedResizing )
                alignedObjSet = self.findVerticalOverlapBetween( tempGraphicalObjs );
                [tfBefore, widthForAll] = self.doAllStatesHaveSameWidth(alignedObjSet);
                setOfTrans = self.findOutTransitionsOf( alignedObjSet );
                transNeedMovingDueToStateExpansion = [];
                if ~isempty(trans) && ~isempty(setOfTrans)
                    transNeedMovingDueToStateExpansion = setdiff( trans', setOfTrans );
                end
                [deltaWidth, rightBoundary] = self.calcChangeInWidth( alignedObjSet, tfBefore, widthForAll );
                tempGraphicalObjs = self.updateSet( tempGraphicalObjs, alignedObjSet );
                tempGraphicalObjs = self.sortFromLeftToRight( tempGraphicalObjs );
                if  self.objNeedsToBeResized( deltaWidth )
                    moveToRight = max(deltaWidth);
                    if (moveToRight > 0)
                        if ~isempty( tempGraphicalObjs )
                            self.implMoveObjsToRight( moveToRight, rightBoundary, tempGraphicalObjs );
                        end
                        if ~isempty( transNeedMovingDueToStateExpansion )
                            self.implMoveTransToRight( moveToRight, rightBoundary, transNeedMovingDueToStateExpansion );
                        end
                    end
                end

                tempObjsNeedResizing = setdiff( tempObjsNeedResizing, alignedObjSet );
                tempObjsNeedResizing = self.sortFromLeftToRight( tempObjsNeedResizing' );

                self.implResizeEachObjHorizontally( alignedObjSet, deltaWidth, tfBefore );

                if sf('feature', 'Diagram Auto-Beautification') >= 3
                    self.implAlignStatesVertically( alignedObjSet );
                end

                self.M3ITransInfoMap = self.getTransitionInfoOnCurrentView();
            end

            if sf('feature', 'Diagram Auto-Beautification') >= 2
                self.implExpandTransHorizontally( trans, objH );
            end
            self.M3ITransInfoMap = self.getTransitionInfoOnCurrentView();
            self.implTransitionLabelRestoring( trans );

            if ~isempty( rbBefore )
                rbAfter = self.findRightMostBoundaryInsideOfObj( objH );
                rb = max( rbAfter, rbBefore );
                deltaX = rb + self.STATE_BORDER_PADDING - objH.Position(1) - objH.Position(3);
                deltaX = max( 0, deltaX );
            end
        end

        function setOfTrans = findOutTransitionsOf( self, alignedObjSet )
            setOfTransIdx = [];
            for obj = alignedObjSet(:)'
                if self.isValidSrcDstForTrans(obj) || isa(obj, 'Stateflow.Junction') || isa(obj, 'Stateflow.Port')
                    setOfTransIdx = union(setOfTransIdx, self.setOfOutTransMap(obj.Id));
                end
            end
            setOfTrans = sf('IdToHandle',setOfTransIdx' );
        end

        function outTransMap = getOutTransMapForObjs( self, setOfObjs )
            idx = arrayfun(@(x) self.isValidSrcDstForTrans(x) || isa(x, 'Stateflow.Junction') || isa(x, 'Stateflow.Port'), setOfObjs);
            setOfObjs = setOfObjs(idx);
            if isempty( setOfObjs )
                outTransMap = [];
                return;
            end
            setOfTransIds = cell(1, length(setOfObjs));
            objIds = cell(1, length(setOfObjs));
            for iter = 1:length(setOfObjs)
                setOfTransIds{iter} = self.getOutTransitionsFor(setOfObjs(iter));
                objIds{iter} = setOfObjs(iter).Id;
            end
            outTransMap = containers.Map( objIds, setOfTransIds);
        end

        function setOfTrans = getOutTransitionsFor(self, obj)
            setOfTrans = [];
            if self.isValidSrcDstForTrans(obj)
                sinkedTrans = sf('SinkedTransitionsOf', obj.Id);
                sourcedTrans = sf('SourcedTransitionsOf', obj.Id);
                insideTrans = sf('TransitionsOf', obj.Id);
                setOfTrans = [sinkedTrans, sourcedTrans];
                setOfTrans = setdiff(setOfTrans, insideTrans);
            elseif isa(obj, 'Stateflow.Junction') || isa(obj, 'Stateflow.Port')
                sinkedTrans = sf('SinkedTransitionsOf', obj.Id);
                sourcedTrans = sf('SourcedTransitionsOf', obj.Id);
                setOfTrans = [sinkedTrans, sourcedTrans];
            end
            setOfTrans = intersect(setOfTrans, self.setOfTransitionIds);
        end

        function tf = transitionIsStrictlyHorizontal( self, obj )
            if self.transitionIsHorizontal( obj ) && abs(obj.SourceEndpoint(2) - obj.DestinationEndpoint(2)) < 1
                tf = 1;
            else
                tf = 0;
            end
        end

        function tf = transitionIsAlreadyStraight( self, obj )
            if ~ismember( obj, self.setOfTransitions ) || ...
                    ~self.transitionIsValid( obj ) || ...
                    ~isempty( obj.Source ) && isequal(obj.Source.Id, obj.Destination.Id)
                tf = false;
                return;
            end
            m3iTrans = self.M3ITransInfoMap(obj.Id);
            if abs(obj.SourceEndpoint(2) - obj.DestinationEndpoint(2)) < 0.01 && ...
                    abs(obj.SourceEndpoint(2) - obj.MidPoint(2)) < 0.01 && ...
                    (isequal(m3iTrans.srcTangent, [ 1 0]) && isequal(m3iTrans.dstTangent, [-1 0]) || ...
                     isequal(m3iTrans.srcTangent, [-1 0]) && isequal(m3iTrans.dstTangent, [ 1 0]))
                tf = true;
            elseif abs(obj.SourceEndpoint(1) - obj.DestinationEndpoint(1)) < 0.01 && ...
                    abs(obj.SourceEndpoint(1) - obj.MidPoint(1)) < 0.01 && ...
                    (isequal(m3iTrans.srcTangent, [0  1]) && isequal(m3iTrans.dstTangent, [0 -1]) || ...
                     isequal(m3iTrans.srcTangent, [0 -1]) && isequal(m3iTrans.dstTangent, [0  1]))
                tf = true;
            else
                tf = false;
            end
        end

        function tf = isLabelEmpty(~, trans)
            trimedStr = strtrim(trans.LabelString);
            if isempty( trimedStr ) || isequal( trimedStr, '?')
                tf = true;
            else
                tf = false;
            end
        end

        function implRepositionTransitionLabels( self, trans )
            if isempty( trans )
                return;
            end
            for obj = trans(:)'
                if ismember( obj, self.setOfTransitions) && ~self.isLabelEmpty( obj )
                    m3iTrans = self.getObjsFromIdsInM3ISet(obj);
                    distToSrcPoint = self.calcDistanceBetweenTwoPoints( self.setOfInitialTransPositionInfo(obj.Id).initSrcPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs );
                    distToMidPoint = self.calcDistanceBetweenTwoPoints( self.setOfInitialTransPositionInfo(obj.Id).initMidPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs );
                    distToDstPoint = self.calcDistanceBetweenTwoPoints( self.setOfInitialTransPositionInfo(obj.Id).initDstPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs );
                    minDist = min( distToSrcPoint, min( distToMidPoint, distToDstPoint ) );
                    if self.transitionIsStrictlyHorizontal( obj )
                        if abs(m3iTrans.labelPosAbs(1) - (m3iTrans.srcPosAbs(1)/2 + m3iTrans.dstPosAbs(1)/2 - m3iTrans.labelSize(1)/2)) > 1
                            m3iTrans.labelPosAbs(1) = m3iTrans.srcPosAbs(1)/2 + m3iTrans.dstPosAbs(1)/2 - m3iTrans.labelSize(1)/2;
                            if self.notificationStructMap(obj.Id).isRepositioned == 0
                                tmpStruct = self.notificationStructMap(obj.Id);
                                tmpStruct.isRepositioned = 1;
                                self.notificationStructMap(obj.Id) = tmpStruct;
                            end
                        end
                        if self.setOfInitialTransPositionInfo(obj.Id).initMidPosAbs(2) > self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs(2) + self.setOfInitialTransPositionInfo(obj.Id).initLabelSize(2)/2
                            if abs( m3iTrans.labelPosAbs(2) - (m3iTrans.midPosAbs(2) - m3iTrans.labelSize(2) - self.LABEL_TO_TRANSITION_DISTANCE_PADDING) ) > 1
                                % Move transition label closer if it is too high above the horizontal transition.
                                m3iTrans.labelPosAbs(2) = m3iTrans.midPosAbs(2) - m3iTrans.labelSize(2) - self.LABEL_TO_TRANSITION_DISTANCE_PADDING;
                                if self.notificationStructMap(obj.Id).isRepositioned == 0
                                    tmpStruct = self.notificationStructMap(obj.Id);
                                    tmpStruct.isRepositioned = 1;
                                    self.notificationStructMap(obj.Id) = tmpStruct;
                                end
                            end
                        else
                            if abs( m3iTrans.labelPosAbs(2) - (m3iTrans.midPosAbs(2) + self.LABEL_TO_TRANSITION_DISTANCE_PADDING) ) > 1
                                % Move transition label closer if it is too low below the horizontal transition.
                                m3iTrans.labelPosAbs(2) = m3iTrans.midPosAbs(2) + self.LABEL_TO_TRANSITION_DISTANCE_PADDING;
                                if self.notificationStructMap(obj.Id).isRepositioned == 0
                                    tmpStruct = self.notificationStructMap(obj.Id);
                                    tmpStruct.isRepositioned = 1;
                                    self.notificationStructMap(obj.Id) = tmpStruct;
                                end
                            end
                        end
                    elseif ~self.compareTwoVectors( m3iTrans.srcPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initSrcPosAbs ) || ...
                            ~self.compareTwoVectors( m3iTrans.midPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initMidPosAbs ) || ...
                            ~self.compareTwoVectors( m3iTrans.dstPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initDstPosAbs )
                        if self.compareTwoVectors( minDist, distToSrcPoint ) && ~self.compareTwoVectors( m3iTrans.srcPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initSrcPosAbs )
                            delta = self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs - self.setOfInitialTransPositionInfo(obj.Id).initSrcPosAbs;
                            m3iTrans.labelPosAbs = m3iTrans.srcPosAbs + delta;
                            if self.notificationStructMap(obj.Id).isRepositioned == 0
                                tmpStruct = self.notificationStructMap(obj.Id);
                                tmpStruct.isRepositioned = 1;
                                self.notificationStructMap(obj.Id) = tmpStruct;
                            end
                        elseif self.compareTwoVectors( minDist, distToMidPoint ) && ~self.compareTwoVectors( m3iTrans.midPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initMidPosAbs )
                            delta = self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs - self.setOfInitialTransPositionInfo(obj.Id).initMidPosAbs;
                            m3iTrans.labelPosAbs = m3iTrans.midPosAbs + delta;
                            if self.notificationStructMap(obj.Id).isRepositioned == 0
                                tmpStruct = self.notificationStructMap(obj.Id);
                                tmpStruct.isRepositioned = 1;
                                self.notificationStructMap(obj.Id) = tmpStruct;
                            end
                        elseif ~self.compareTwoVectors( m3iTrans.dstPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initDstPosAbs )
                            delta = self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs - self.setOfInitialTransPositionInfo(obj.Id).initDstPosAbs;
                            m3iTrans.labelPosAbs = m3iTrans.dstPosAbs + delta;
                            if self.notificationStructMap(obj.Id).isRepositioned == 0
                                tmpStruct = self.notificationStructMap(obj.Id);
                                tmpStruct.isRepositioned = 1;
                                self.notificationStructMap(obj.Id) = tmpStruct;
                            end
                        end
                    end
                end
            end
        end

        function tf = compareTwoVectors( ~, vecA, vecB )
            if norm(vecA - vecB) < 0.01
                tf = true;
            else
                tf = false;
            end
        end

        function implTransitionLabelRestoring( self, trans )
            if isempty( trans )
                return;
            end
            for obj = trans(:)'
                if ismember(obj, self.setOfTransitions) && ~self.isLabelEmpty( obj )
                    m3iTrans = self.getObjsFromIdsInM3ISet(obj);
                    if ~self.compareTwoVectors( m3iTrans.srcPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initSrcPosAbs ) || ...
                            ~self.compareTwoVectors( m3iTrans.midPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initMidPosAbs ) || ...
                            ~self.compareTwoVectors( m3iTrans.dstPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initDstPosAbs )
                        distToSrcPoint = self.calcDistanceBetweenTwoPoints( self.setOfInitialTransPositionInfo(obj.Id).initSrcPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs );
                        distToMidPoint = self.calcDistanceBetweenTwoPoints( self.setOfInitialTransPositionInfo(obj.Id).initMidPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs );
                        distToDstPoint = self.calcDistanceBetweenTwoPoints( self.setOfInitialTransPositionInfo(obj.Id).initDstPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs );
                        minDist = min( distToSrcPoint, min( distToMidPoint, distToDstPoint ) );
                        if self.transitionIsHorizontal( obj )
                            if abs(m3iTrans.labelPosAbs(1) - (m3iTrans.midPosAbs(1) - m3iTrans.labelSize(1)/2)) > 1
                                m3iTrans.labelPosAbs(1) = m3iTrans.midPosAbs(1) - m3iTrans.labelSize(1)/2;
                                if self.notificationStructMap(obj.Id).isRepositioned == 0
                                    tmpStruct = self.notificationStructMap(obj.Id);
                                    tmpStruct.isRepositioned = 1;
                                    self.notificationStructMap(obj.Id) = tmpStruct;
                                end
                            end
                            if self.setOfInitialTransPositionInfo(obj.Id).initMidPosAbs(2) > self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs(2)
                                m3iTrans.labelPosAbs(2) = m3iTrans.midPosAbs(2) - m3iTrans.labelSize(2) - self.LABEL_TO_TRANSITION_DISTANCE_PADDING;
                            else
                                m3iTrans.labelPosAbs(2) = m3iTrans.midPosAbs(2) + self.LABEL_TO_TRANSITION_DISTANCE_PADDING;
                            end
                        elseif self.compareTwoVectors( minDist, distToSrcPoint ) && ~self.compareTwoVectors( m3iTrans.srcPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initSrcPosAbs )
                            delta = self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs - self.setOfInitialTransPositionInfo(obj.Id).initSrcPosAbs;
                            m3iTrans.labelPosAbs = m3iTrans.srcPosAbs + delta;
                            if self.notificationStructMap(obj.Id).isRepositioned == 0
                                tmpStruct = self.notificationStructMap(obj.Id);
                                tmpStruct.isRepositioned = 1;
                                self.notificationStructMap(obj.Id) = tmpStruct;
                            end
                        elseif self.compareTwoVectors( minDist, distToMidPoint ) && ~self.compareTwoVectors( m3iTrans.midPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initMidPosAbs )
                            delta = self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs - self.setOfInitialTransPositionInfo(obj.Id).initMidPosAbs;
                            m3iTrans.labelPosAbs = m3iTrans.midPosAbs + delta;
                            if self.notificationStructMap(obj.Id).isRepositioned == 0
                                tmpStruct = self.notificationStructMap(obj.Id);
                                tmpStruct.isRepositioned = 1;
                                self.notificationStructMap(obj.Id) = tmpStruct;
                            end
                        elseif ~self.compareTwoVectors( m3iTrans.dstPosAbs, self.setOfInitialTransPositionInfo(obj.Id).initDstPosAbs )
                            delta = self.setOfInitialTransPositionInfo(obj.Id).initLabelPosAbs - self.setOfInitialTransPositionInfo(obj.Id).initDstPosAbs;
                            m3iTrans.labelPosAbs = m3iTrans.dstPosAbs + delta;
                            if self.notificationStructMap(obj.Id).isRepositioned == 0
                                tmpStruct = self.notificationStructMap(obj.Id);
                                tmpStruct.isRepositioned = 1;
                                self.notificationStructMap(obj.Id) = tmpStruct;
                            end
                        end
                    end
                end
            end
        end

        function distance = calcDistanceBetweenTwoPoints( ~, x, y )
            distance = sqrt((x(1) - y(1)) * (x(1) - y(1)) + (x(2) - y(2)) * (x(2) - y(2)));
        end

        function implAlignStatesHorizontally( self, setOfAlignedObjs)
            [tf, ~] = self.doAllStatesHaveSameHeight(setOfAlignedObjs);
            if ~self.doesSetcontainMoreThanOneState(setOfAlignedObjs) || ~tf
                return;
            end
            minPosY = double(intmax);
            maxPosY = double(intmin);
            for obj = setOfAlignedObjs(:)'
                if self.objIsRectangular( obj )
                    if obj.Position(2) < minPosY
                        minPosY = obj.Position(2);
                    end
                    if obj.Position(2) > maxPosY
                        maxPosY = obj.Position(2);
                    end
                end
            end

            if maxPosY - minPosY <= 20 && maxPosY - minPosY > 0.01
                for obj = setOfAlignedObjs(:)'
                    if self.objIsRectangular( obj )
                        tempObj = self.getObjsFromIdsInM3ISet(obj);
                        StateflowDI.SFDomain.repositionElement(self.editor, tempObj, [tempObj.absPosition(1), minPosY], tempObj.size);
                        if self.notificationStructMap(obj.Id).isAligned == 0
                            tmpStruct = self.notificationStructMap(obj.Id);
                            tmpStruct.isAligned = 1;
                            self.notificationStructMap(obj.Id) = tmpStruct;
                        end
                    end
                end
            end
        end

        function implAlignStatesVertically( self, setOfAlignedObjs)
            [tf, ~] = self.doAllStatesHaveSameWidth(setOfAlignedObjs);
            if ~self.doesSetcontainMoreThanOneState(setOfAlignedObjs) || ~tf
                return;
            end
            minPosX = double(intmax);
            maxPosX = double(intmin);
            for obj = setOfAlignedObjs(:)'
                if self.objIsRectangular( obj )
                    if obj.Position(1) < minPosX
                        minPosX = obj.Position(1);
                    end
                    if obj.Position(1) > maxPosX
                        maxPosX = obj.Position(1);
                    end
                end
            end

            if maxPosX - minPosX <= 20 && maxPosX - minPosX > 0.01
                for obj = setOfAlignedObjs(:)'
                    if self.objIsRectangular( obj )
                        tempObj = self.getObjsFromIdsInM3ISet(obj);
                        StateflowDI.SFDomain.repositionElement(self.editor, tempObj, [minPosX, tempObj.absPosition(2)], tempObj.size);

                        if self.notificationStructMap(obj.Id).isAligned == 0
                            tmpStruct = self.notificationStructMap(obj.Id);
                            tmpStruct.isAligned = 1;
                            self.notificationStructMap(obj.Id) = tmpStruct;
                        end
                    end
                end
            end
        end

        function update = updateSet(~, tempGraphicalObjs, alignedObjSet)

            update = tempGraphicalObjs(find(tempGraphicalObjs == alignedObjSet(length(alignedObjSet)))+1:length(tempGraphicalObjs));
        end

        function bb = findBottomMostBoundaryInsideOfObj( self, objH )
            graphicalObjs = self.getLvlOneGraphicalObjsFor(objH);
            bb = double(intmin);
            for obj = graphicalObjs(:)'
                if isa( obj, 'Stateflow.Transition' )
                    m3iTrans = self.getObjsFromIdsInM3ISet(obj);
                    srcY = obj.SourceEndpoint(2);
                    midY = obj.MidPoint(2);
                    dstY = obj.DestinationEndpoint(2);
                    labelY = m3iTrans.labelPosAbs(2) + m3iTrans.labelSize(2);
                    if self.isInnerTransition( obj ) && ...
                            (self.setOfInitialTransPositionInfo( obj.Id ).SourceOClock > self.SOUTHEAST_OCLOCK && ...
                             self.setOfInitialTransPositionInfo( obj.Id ).SourceOClock < self.SOUTHWEST_OCLOCK && ...
                             isequal( m3iTrans.srcElement.backendId, objH.Id )    || ...
                             self.setOfInitialTransPositionInfo( obj.Id ).DestinationOClock > self.SOUTHEAST_OCLOCK && ...
                             self.setOfInitialTransPositionInfo( obj.Id ).DestinationOClock < self.SOUTHWEST_OCLOCK && ...
                             isequal( m3iTrans.dstElement.backendId, objH.Id ))
                        bottomBoundary = min( max(srcY, dstY), min(srcY, dstY) + self.INNER_TRANSITION_PADDING );
                    elseif self.isSelfTransition( obj )
                        bottomBoundary = max(srcY, max(midY, max(dstY, labelY))) - self.STATE_BORDER_PADDING;
                    else
                        bottomBoundary = max(srcY, max(midY, max(dstY, labelY)));
                    end
                else
                    labelHeight = self.calcLabelHeightForObjOnItsBottomSide( obj );
                    if isa( obj, 'Stateflow.Junction' ) || isa(obj, 'Stateflow.Port')
                        bottomBoundary = obj.Position.Center(2) + obj.Position.Radius + labelHeight;
                    else
                        bottomBoundary = obj.Position(2) + obj.Position(4) + labelHeight;
                    end
                end
                if bb < bottomBoundary
                    bb = bottomBoundary;
                end
            end
        end

        function rb = findRightMostBoundaryInsideOfObj( self, objH )
            graphicalObjs = self.getLvlOneGraphicalObjsFor(objH);
            rb = double(intmin);
            for obj = graphicalObjs(:)'
                if isa( obj, 'Stateflow.Transition' )
                    m3iTrans = self.getObjsFromIdsInM3ISet(obj);
                    srcX = obj.SourceEndpoint(1);
                    midX = obj.MidPoint(1);
                    dstX = obj.DestinationEndpoint(1);
                    labelX = m3iTrans.labelPosAbs(1) + m3iTrans.labelSize(1);
                    if self.isInnerTransition( obj ) && ...
                            (self.setOfInitialTransPositionInfo( obj.Id ).SourceOClock > self.NORTHEAST_OCLOCK && ...
                             self.setOfInitialTransPositionInfo( obj.Id ).SourceOClock < self.SOUTHEAST_OCLOCK && ...
                             isequal( m3iTrans.srcElement.backendId, objH.Id )    || ...
                             self.setOfInitialTransPositionInfo( obj.Id ).DestinationOClock > self.NORTHEAST_OCLOCK && ...
                             self.setOfInitialTransPositionInfo( obj.Id ).DestinationOClock < self.SOUTHEAST_OCLOCK && ...
                             isequal( m3iTrans.dstElement.backendId, objH.Id ))
                        rightBoundary = min(srcX, dstX) + self.INNER_TRANSITION_PADDING;
                    elseif self.isSelfTransition( obj )
                        rightBoundary = max(srcX, max(midX, max(dstX, labelX))) - self.STATE_BORDER_PADDING;
                    else
                        rightBoundary = max(srcX, max(midX, max(dstX, labelX)));
                    end
                else
                    labelLength = self.calcLabelLengthForObjOnItsRightSide( obj );
                    if isa( obj, 'Stateflow.Junction' ) || isa(obj, 'Stateflow.Port')
                        rightBoundary = obj.Position.Center(1) + obj.Position.Radius + labelLength;
                    else
                        rightBoundary = obj.Position(1) + obj.Position(3) + labelLength;
                    end
                end
                if rb < rightBoundary
                    rb = rightBoundary;
                end
            end
        end

        function deltaLabelHeight = calcLabelHeightForObjOnItsBottomSide( self, objH )
            if isa( objH, 'Stateflow.State' )         || ...
                    isa( objH, 'Stateflow.Junction')       || ...
                    isa( objH, 'Stateflow.AtomicSubchart') || ...
                    isa( objH, 'Stateflow.Box') || ...
                    isa( objH, 'Stateflow.Port')
                if isa( objH, 'Stateflow.Junction' ) || isa( objH, 'Stateflow.AtomicSubchart' ) || isa(objH, 'Stateflow.Port')
                    insideTransIds = [];
                else
                    insideTransIds = sf('TransitionsOf', objH.Id);
                end

                srcTransIds = sf('SourcedTransitionsOf', objH.Id);
                srcTransIds = setdiff( srcTransIds, insideTransIds );
                srcTransUddHs = sf('IdToHandle', srcTransIds);

                dstTransIds = sf('SinkedTransitionsOf', objH.Id);
                dstTransIds = setdiff( dstTransIds, insideTransIds );
                dstTransUddHs = sf('IdToHandle', dstTransIds);
                maxLabelHeight = 0;
                if (~isempty(srcTransUddHs))
                    for j = 1:length(srcTransUddHs)
                        if ~self.isSuperTransition( srcTransUddHs(j) )
                            if (self.transitionIsVertical(srcTransUddHs(j)) && ...
                                srcTransUddHs(j).SourceOClock >= self.SOUTHEAST_OCLOCK          && ...
                                srcTransUddHs(j).SourceOClock <  self.SOUTHWEST_OCLOCK)
                                m3iTrans = self.getObjsFromIdsInM3ISet(srcTransUddHs(j));
                                if m3iTrans.labelSize(2) < self.LABEL_PADDING
                                    labelHeight = self.LABEL_PADDING;
                                else
                                    labelHeight = m3iTrans.labelSize(2);
                                end
                                maxLabelHeight = max(maxLabelHeight,labelHeight + self.LABEL_PADDING);
                            end
                        end
                    end
                end
                if (~isempty(dstTransUddHs))
                    for j = 1:length(dstTransUddHs)
                        if ~self.isSuperTransition( dstTransUddHs(j) )
                            if (self.transitionIsVertical(dstTransUddHs(j)) && ...
                                dstTransUddHs(j).DestinationOClock >= self.SOUTHEAST_OCLOCK     && ...
                                dstTransUddHs(j).DestinationOClock <  self.SOUTHWEST_OCLOCK)
                                m3iTrans = self.getObjsFromIdsInM3ISet(dstTransUddHs(j));
                                if m3iTrans.labelSize(2) < self.LABEL_PADDING
                                    labelHeight = self.LABEL_PADDING;
                                else
                                    labelHeight = m3iTrans.labelSize(2);
                                end
                                maxLabelHeight = max(maxLabelHeight,labelHeight + self.LABEL_PADDING);
                            end
                        end
                    end
                end
                deltaLabelHeight = maxLabelHeight;
            else
                deltaLabelHeight = 0;
            end
        end

        function deltaLabelLength = calcLabelLengthForObjOnItsRightSide(self, objH)
            if isa( objH, 'Stateflow.State' )         || ...
                    isa( objH, 'Stateflow.Junction')       || ...
                    isa( objH, 'Stateflow.AtomicSubchart') || ...
                    isa( objH, 'Stateflow.Box') || ...
                    isa( objH, 'Stateflow.Port')
                if isa( objH, 'Stateflow.Junction' ) || isa( objH, 'Stateflow.AtomicSubchart' ) || isa(objH, 'Stateflow.Port')
                    insideTransIds = [];
                else
                    insideTransIds = sf('TransitionsOf', objH.Id);
                end

                srcTransIds = sf('SourcedTransitionsOf', objH.Id);
                srcTransIds = setdiff( srcTransIds, insideTransIds );
                srcTransUddHs = sf('IdToHandle', srcTransIds);

                dstTransIds = sf('SinkedTransitionsOf', objH.Id);
                dstTransIds = setdiff( dstTransIds, insideTransIds );
                dstTransUddHs = sf('IdToHandle', dstTransIds);

                maxLabelLength = 0;
                if (~isempty(srcTransUddHs))
                    for j = 1:length(srcTransUddHs)
                        if ~self.isSuperTransition( srcTransUddHs(j) )
                            if (self.transitionIsHorizontal(srcTransUddHs(j)) && ...
                                srcTransUddHs(j).SourceOClock >= self.NORTHEAST_OCLOCK          && ...
                                srcTransUddHs(j).SourceOClock <  self.SOUTHEAST_OCLOCK)
                                m3iTrans = self.getObjsFromIdsInM3ISet(srcTransUddHs(j));
                                if m3iTrans.labelSize(1) < self.LABEL_PADDING
                                    labelWidth = self.LABEL_PADDING;
                                else
                                    labelWidth = m3iTrans.labelSize(1);
                                end
                                maxLabelLength = max(maxLabelLength, labelWidth + self.LABEL_PADDING);
                            end
                        end
                    end
                end

                if (~isempty(dstTransUddHs))
                    for j = 1:length(dstTransUddHs)
                        if ~self.isSuperTransition( dstTransUddHs(j) )
                            if (self.transitionIsHorizontal(dstTransUddHs(j)) && ...
                                dstTransUddHs(j).DestinationOClock >= self.NORTHEAST_OCLOCK     && ...
                                dstTransUddHs(j).DestinationOClock <  self.SOUTHEAST_OCLOCK)
                                m3iTrans = self.getObjsFromIdsInM3ISet(dstTransUddHs(j));
                                if m3iTrans.labelSize(1) < self.LABEL_PADDING
                                    labelWidth = self.LABEL_PADDING;
                                else
                                    labelWidth = m3iTrans.labelSize(1);
                                end
                                maxLabelLength = max(maxLabelLength, labelWidth + self.LABEL_PADDING);
                            end
                        end
                    end
                end
                deltaLabelLength = maxLabelLength;
            else
                deltaLabelLength = 0;
            end
        end

        function implResizeEachObjVertically(self, alignedObjSet, deltaHeight, tfBefore)
            for i = 1:length(alignedObjSet)
                m3iObj = self.getObjsFromIdsInM3ISet(alignedObjSet(i));
                if ~isa(alignedObjSet(i), 'Stateflow.Transition')
                    if deltaHeight(i)
                        newHeight = m3iObj.size(2) + deltaHeight(i);
                        StateflowDI.SFDomain.repositionElement(self.editor, m3iObj, m3iObj.absPosition, [m3iObj.size(1) newHeight]);
                        self.restoreTangentForVerticalTrans();
                        if self.notificationStructMap(alignedObjSet(i).Id).isResized == 0 && deltaHeight(i) > 0.01
                            tmpStruct = self.notificationStructMap(alignedObjSet(i).Id);
                            tmpStruct.isResized = 1;
                            self.notificationStructMap(alignedObjSet(i).Id) = tmpStruct;
                        end
                    end
                end
            end

            [tf, ~] = self.doAllStatesHaveSameHeight(alignedObjSet);
            if self.doesSetcontainMoreThanOneState(alignedObjSet) && ( tf || tfBefore )
                heightForAllStates = 0;
                % So far, it guarantees that setOfAlignedObjs has at least two states, if falls in self if branch
                for i = 1:length(alignedObjSet)
                    if self.objIsRectangular(alignedObjSet(i))
                        m3iObj = self.getObjsFromIdsInM3ISet(alignedObjSet(i));
                        height = m3iObj.size(2);

                        if height > heightForAllStates
                            heightForAllStates = height;
                        end
                    end
                end

                for i = 1:length(alignedObjSet)
                    m3iObj = self.getObjsFromIdsInM3ISet(alignedObjSet(i));
                    if self.objIsRectangular(alignedObjSet(i)) && alignedObjSet(i).Position(4) < heightForAllStates
                        StateflowDI.SFDomain.repositionElement(self.editor, m3iObj, m3iObj.absPosition, [m3iObj.size(1) heightForAllStates]);
                        self.restoreTangentForVerticalTrans();
                        if self.notificationStructMap(alignedObjSet(i).Id).isResized == 0
                            tmpStruct = self.notificationStructMap(alignedObjSet(i).Id);
                            tmpStruct.isResized = 1;
                            self.notificationStructMap(alignedObjSet(i).Id) = tmpStruct;
                        end
                    end
                end
            end
        end

        function tf = objIsRectangular( ~, obj )
            tf = isa(obj, 'Stateflow.State') || ...
                 isa(obj, 'Stateflow.AtomicSubchart') || ...
                 isa(obj, 'Stateflow.Function') || ...
                 isa(obj, 'Stateflow.Box') || ...
                 isa(obj, 'Stateflow.EMFunction') || ...
                 isa(obj, 'Stateflow.SLFunction') || ...
                 isa(obj, 'Stateflow.TruthTable') || ...
                 isa(obj, 'Stateflow.AtomicBox')  || ...
                 isa(obj, 'Stateflow.SimulinkBasedState');
        end

        function implResizeEachObjHorizontally(self, alignedObjSet, deltaWeight, tfBefore)
            for i = 1:length(alignedObjSet)
                m3iObj = self.getObjsFromIdsInM3ISet(alignedObjSet(i));
                if ~isa(alignedObjSet(i), 'Stateflow.Transition')
                    if deltaWeight(i)
                        newWidth = m3iObj.size(1) + deltaWeight(i);
                        StateflowDI.SFDomain.repositionElement(self.editor, m3iObj, m3iObj.absPosition, [newWidth, m3iObj.size(2)]);
                        self.restoreTangentForHorizontalTrans();

                        if self.notificationStructMap(alignedObjSet(i).Id).isResized == 0 && deltaWeight(i) > 0.01
                            tmpStruct = self.notificationStructMap(alignedObjSet(i).Id);
                            tmpStruct.isResized = 1;
                            self.notificationStructMap(alignedObjSet(i).Id) = tmpStruct;
                        end
                    end
                end
            end

            [tf, ~] = self.doAllStatesHaveSameWidth(alignedObjSet);
            if self.doesSetcontainMoreThanOneState(alignedObjSet) && ( tf || tfBefore )
                widthForAllStates = 0;
                % So far, it guarantees that setOfAlignedObjs has at least two states, if falls in self if branch
                for i = 1:length(alignedObjSet)
                    if self.objIsRectangular(alignedObjSet(i))
                        m3iObj = self.getObjsFromIdsInM3ISet(alignedObjSet(i));
                        width = m3iObj.size(1);
                        if width > widthForAllStates
                            widthForAllStates = width;
                        end
                    end
                end

                for i = 1:length(alignedObjSet)
                    m3iObj = self.getObjsFromIdsInM3ISet(alignedObjSet(i));
                    if self.objIsRectangular(alignedObjSet(i)) && alignedObjSet(i).Position(3) + 0.01 < widthForAllStates
                        StateflowDI.SFDomain.repositionElement(self.editor, m3iObj, m3iObj.absPosition, [widthForAllStates, m3iObj.size(2)]);
                        self.restoreTangentForHorizontalTrans();
                        if self.notificationStructMap(alignedObjSet(i).Id).isResized == 0
                            tmpStruct = self.notificationStructMap(alignedObjSet(i).Id);
                            tmpStruct.isResized = 1;
                            self.notificationStructMap(alignedObjSet(i).Id) = tmpStruct;
                        end
                    end
                end
            end
        end

        function restoreTangentForVerticalTrans( self )
            for iter = 1:length(self.setOfTransitionM3IObjs)
                obj = self.setOfTransitionM3IObjs{iter};
                prevObj = self.M3ITransInfoMap(obj.backendId);
                if isequal( prevObj.srcTangent, [0,  1]) && isequal( prevObj.dstTangent, [0, -1] ) || ...
                        isequal( prevObj.srcTangent, [0, -1]) && isequal( prevObj.dstTangent, [0,  1] )
                    obj.srcTangent = self.M3ITransInfoMap(obj.backendId).srcTangent;
                    obj.dstTangent = self.M3ITransInfoMap(obj.backendId).dstTangent;
                end
            end
        end

        function restoreTangentForHorizontalTrans( self )
            for iter = 1:length(self.setOfTransitionM3IObjs)
                obj = self.setOfTransitionM3IObjs{iter};
                prevObj = self.M3ITransInfoMap(obj.backendId);
                if isequal( prevObj.srcTangent, [ 1, 0]) && isequal( prevObj.dstTangent, [-1, 0] ) || ...
                        isequal( prevObj.srcTangent, [-1, 0]) && isequal( prevObj.dstTangent, [ 1, 0] )
                    obj.srcTangent = self.M3ITransInfoMap(obj.backendId).srcTangent;
                    obj.dstTangent = self.M3ITransInfoMap(obj.backendId).dstTangent;
                end
            end
        end

        % Contains at least two states in the set
        function flag = doesSetcontainMoreThanOneState( self, setOfObjs )
            flag = 0;
            if length(setOfObjs) < 2
                return;
            else
                numOfStates = 0;
                for obj = setOfObjs(:)'
                    if self.objIsRectangular( obj )
                        numOfStates = numOfStates + 1;
                    end

                    if numOfStates > 1
                        flag = 1;
                        return;
                    end
                end
            end
        end

        function [tf, maxHeightAmongStates] = doAllStatesHaveSameHeight( self, setOfObjs )
            tf = 0;
            minHeightAmongStates = double(intmax);
            maxHeightAmongStates = -1;
            if length(setOfObjs) < 2
                return;
            else
                for obj = setOfObjs(:)'
                    if self.objIsRectangular( obj )
                        if obj.Position(4) < minHeightAmongStates
                            minHeightAmongStates = obj.Position(4);
                        end
                        if obj.Position(4) > maxHeightAmongStates
                            maxHeightAmongStates = obj.Position(4);
                        end
                    end
                end
                if minHeightAmongStates/maxHeightAmongStates > self.STATE_BOUNDARY_RATIO
                    tf = 1;
                end
            end
        end

        function [tf, maxWidthAmongStates] = doAllStatesHaveSameWidth( self, setOfObjs )
            tf = 0;
            minWidthAmongStates = double(intmax);
            maxWidthAmongStates = -1;
            if length(setOfObjs) < 2
                return;
            else
                for obj = setOfObjs(:)'
                    if self.objIsRectangular( obj )
                        if obj.Position(3) < minWidthAmongStates
                            minWidthAmongStates = obj.Position(3);
                        end
                        if obj.Position(3) > maxWidthAmongStates
                            maxWidthAmongStates = obj.Position(3);
                        end
                    end
                end
                if minWidthAmongStates/maxWidthAmongStates > self.STATE_BOUNDARY_RATIO
                    tf = 1;
                end
            end
        end

        function flag = objNeedsToBeResized(~, deltaStruct )
            sum = 0;
            for obj = deltaStruct(:)'
                sum = sum + obj;
            end
            if sum > 0
                flag = 1;
            else
                flag = 0;
            end
        end

        function implMoveTransToBottom( self, moveToBottom, bottomBoundary, trans )
            for obj = trans(:)'
                m3iObj = self.getObjsFromIdsInM3ISet(obj);
                if ~self.transitionIsVertical( obj ) && ...
                        min(self.M3ITransInfoMap(obj.Id).srcPosAbs(2), min(self.M3ITransInfoMap(obj.Id).midPosAbs(2),self.M3ITransInfoMap(obj.Id).dstPosAbs(2))) > bottomBoundary + 1 && ...
                        ~self.isSelfTransition( obj ) && ...
                        self.transitionIsHorizontal( obj )

                    if self.transitionIsHorizontal( obj )
                        self.tryToExpandHeightSrcAndDstFor( obj, bottomBoundary, moveToBottom );
                    end

                    tmp = self.M3ITransInfoMap(obj.Id);

                    tmp.srcPosAbs(2) = self.M3ITransInfoMap(obj.Id).srcPosAbs(2) + moveToBottom;
                    tmp.midPosAbs(2) = self.M3ITransInfoMap(obj.Id).midPosAbs(2) + moveToBottom;
                    tmp.dstPosAbs(2) = self.M3ITransInfoMap(obj.Id).dstPosAbs(2) + moveToBottom;
                    self.M3ITransInfoMap(obj.Id) = tmp;

                    m3iObj.srcPosAbs  = self.M3ITransInfoMap(obj.Id).srcPosAbs;
                    m3iObj.midPosAbs  = self.M3ITransInfoMap(obj.Id).midPosAbs;
                    m3iObj.dstPosAbs  = self.M3ITransInfoMap(obj.Id).dstPosAbs;
                    m3iObj.srcTangent = self.M3ITransInfoMap(obj.Id).srcTangent;
                    m3iObj.dstTangent = self.M3ITransInfoMap(obj.Id).dstTangent;
                elseif self.transitionIsVertical( obj )
                    m3iObj.srcTangent = self.M3ITransInfoMap(obj.Id).srcTangent;
                    m3iObj.dstTangent = self.M3ITransInfoMap(obj.Id).dstTangent;
                end
            end
        end

        function tryToExpandHeightSrcAndDstFor( self, obj, bottomBoundary, moveToBottom )
            if ~isempty(obj.Source)
                if self.isValidSrcDstForTrans(obj.Source)
                    if obj.Source.Position(2) < bottomBoundary && ...
                            obj.Source.Position(2) + obj.Source.Position(4) - self.M3ITransInfoMap(obj.Id).srcPosAbs(2) - self.STATE_BORDER_PADDING < moveToBottom
                        m3iObj = self.getObjsFromIdsInM3ISet(obj.Source);
                        if ~isempty(m3iObj) && ~isequal(obj.Source.Id, self.subview.Id)
                            StateflowDI.SFDomain.repositionElement(self.editor, m3iObj, m3iObj.absPosition, [m3iObj.size(1) m3iObj.size(2) + moveToBottom]);
                            if self.notificationStructMap(obj.Source.Id).isResized == 0
                                tmpStruct = self.notificationStructMap(obj.Source.Id);
                                tmpStruct.isResized = 1;
                                self.notificationStructMap(obj.Source.Id) = tmpStruct;
                            end
                        end
                    end
                elseif self.isaJunctionOrInternalPort(obj.Source)
                    if obj.Source.Position.Center(2) - obj.Source.Position.Radius < bottomBoundary
                        m3iObj = self.getObjsFromIdsInM3ISet(obj.Source);
                        if ~isempty(m3iObj)
                            repositionY = m3iObj.absCenter(2) + moveToBottom;
                            radius = m3iObj.size(1) / 2;
                            StateflowDI.SFDomain.repositionElement( self.editor, m3iObj, [m3iObj.absCenter(1) - radius repositionY - radius], m3iObj.size );
                        end
                    end
                end
            end
            if ~isempty(obj.Destination)
                if self.isValidSrcDstForTrans(obj.Destination)
                    if obj.Destination.Position(2) < bottomBoundary && ...
                            obj.Destination.Position(2) + obj.Destination.Position(4) - self.M3ITransInfoMap(obj.Id).dstPosAbs(2) - self.STATE_BORDER_PADDING < moveToBottom
                        m3iObj = self.getObjsFromIdsInM3ISet(obj.Destination);
                        if ~isempty(m3iObj) && ~isequal(obj.Destination.Id, self.subview.Id)
                            StateflowDI.SFDomain.repositionElement(self.editor, m3iObj, m3iObj.absPosition, [m3iObj.size(1) m3iObj.size(2) + moveToBottom]);
                            if self.notificationStructMap(obj.Destination.Id).isResized == 0
                                tmpStruct = self.notificationStructMap(obj.Destination.Id);
                                tmpStruct.isResized = 1;
                                self.notificationStructMap(obj.Destination.Id) = tmpStruct;
                            end
                        end
                    end
                elseif self.isaJunctionOrInternalPort(obj.Destination)
                    if obj.Destination.Position.Center(2) - obj.Destination.Position.Radius < bottomBoundary
                        m3iObj = self.getObjsFromIdsInM3ISet(obj.Destination);
                        if ~isempty(m3iObj)
                            repositionY = m3iObj.absCenter(2) + moveToBottom;
                            radius = m3iObj.size(1) / 2;
                            StateflowDI.SFDomain.repositionElement( self.editor, m3iObj, [m3iObj.absCenter(1) - radius repositionY - radius], m3iObj.size );
                        end
                    end
                end
            end
        end

        function tf = isValidSrcDstForTrans(~, obj)
        % Exclude junction as a valid source or destination for
        % transitions. Junction is considered separately.
            tf = isa(obj, 'Stateflow.State') || ...
                 isa(obj, 'Stateflow.AtomicSubchart') || ...
                 isa(obj, 'Stateflow.Box') || ...
                 isa(obj, 'Stateflow.AtomicBox') || ...
                 isa(obj, 'Stateflow.SimulinkBasedState');
        end

        function tryToExpandWidthSrcAndDstFor( self, obj, rightBoundary, moveToRight )
            if ~isempty(obj.Source)
                if self.isValidSrcDstForTrans(obj.Source)
                    if obj.Source.Position(1) < rightBoundary && ...
                            obj.Source.Position(1) + obj.Source.Position(3) - self.M3ITransInfoMap(obj.Id).srcPosAbs(1) - self.STATE_BORDER_PADDING < moveToRight
                        m3iObj = self.getObjsFromIdsInM3ISet(obj.Source);
                        if ~isempty(m3iObj) && ~isequal(obj.Source.Id, self.subview.Id)
                            StateflowDI.SFDomain.repositionElement(self.editor, m3iObj, m3iObj.absPosition, [m3iObj.size(1) + moveToRight m3iObj.size(2) ]);
                            if self.notificationStructMap(obj.Source.Id).isResized == 0
                                tmpStruct = self.notificationStructMap(obj.Source.Id);
                                tmpStruct.isResized = 1;
                                self.notificationStructMap(obj.Source.Id) = tmpStruct;
                            end
                        end
                    end
                elseif self.isaJunctionOrInternalPort(obj.Source)
                    if obj.Source.Position.Center(1) - obj.Source.Position.Radius < rightBoundary
                        m3iObj = self.getObjsFromIdsInM3ISet(obj.Source);
                        if ~isempty(m3iObj)
                            repositionX = m3iObj.absCenter(1) + moveToRight;
                            radius = m3iObj.size(1) / 2;
                            StateflowDI.SFDomain.repositionElement( self.editor, m3iObj, [repositionX - radius m3iObj.absCenter(2) - radius], m3iObj.size );
                        end
                    end
                end
            end
            if ~isempty(obj.Destination)
                if self.isValidSrcDstForTrans(obj.Destination)
                    if obj.Destination.Position(1) < rightBoundary && ...
                            obj.Destination.Position(1) + obj.Destination.Position(3) - self.M3ITransInfoMap(obj.Id).dstPosAbs(1) - self.STATE_BORDER_PADDING < moveToRight
                        m3iObj = self.getObjsFromIdsInM3ISet(obj.Destination);
                        if ~isempty(m3iObj) && ~isequal(obj.Destination.Id, self.subview.Id)
                            StateflowDI.SFDomain.repositionElement(self.editor, m3iObj, m3iObj.absPosition, [m3iObj.size(1) + moveToRight m3iObj.size(2)]);
                            if self.notificationStructMap(obj.Destination.Id).isResized == 0
                                tmpStruct = self.notificationStructMap(obj.Destination.Id);
                                tmpStruct.isResized = 1;
                                self.notificationStructMap(obj.Destination.Id) = tmpStruct;
                            end
                        end
                    end
                elseif self.isaJunctionOrInternalPort(obj.Destination)
                    if obj.Destination.Position.Center(1) - obj.Destination.Position.Radius < rightBoundary
                        m3iObj = self.getObjsFromIdsInM3ISet(obj.Destination);
                        if ~isempty(m3iObj)
                            repositionX = m3iObj.absCenter(1) + moveToRight;
                            radius = m3iObj.size(1) / 2;
                            StateflowDI.SFDomain.repositionElement( self.editor, m3iObj, [repositionX - radius m3iObj.absCenter(2) - radius], m3iObj.size );
                        end
                    end
                end
            end
        end

        function implMoveTransToRight( self, moveToRight, rightBoundary, trans )
            for obj = trans(:)'
                m3iObj = self.getObjsFromIdsInM3ISet(obj);
                if ~self.transitionIsHorizontal( obj ) && ...
                        min(self.M3ITransInfoMap(obj.Id).srcPosAbs(1), min(self.M3ITransInfoMap(obj.Id).midPosAbs(1),self.M3ITransInfoMap(obj.Id).dstPosAbs(1))) > rightBoundary - 1 && ...
                        ~self.isSelfTransition( obj ) && ...
                        self.transitionIsVertical( obj )

                    if self.transitionIsVertical( obj )
                        self.tryToExpandWidthSrcAndDstFor( obj, rightBoundary, moveToRight );
                    end

                    tmp = self.M3ITransInfoMap(obj.Id);

                    tmp.srcPosAbs(1) = self.M3ITransInfoMap(obj.Id).srcPosAbs(1) + moveToRight;
                    tmp.midPosAbs(1) = self.M3ITransInfoMap(obj.Id).midPosAbs(1) + moveToRight;
                    tmp.dstPosAbs(1) = self.M3ITransInfoMap(obj.Id).dstPosAbs(1) + moveToRight;
                    self.M3ITransInfoMap(obj.Id) = tmp;

                    m3iObj.srcPosAbs  = self.M3ITransInfoMap(obj.Id).srcPosAbs;
                    m3iObj.midPosAbs  = self.M3ITransInfoMap(obj.Id).midPosAbs;
                    m3iObj.dstPosAbs  = self.M3ITransInfoMap(obj.Id).dstPosAbs;
                    m3iObj.srcTangent = self.M3ITransInfoMap(obj.Id).srcTangent;
                    m3iObj.dstTangent = self.M3ITransInfoMap(obj.Id).dstTangent;
                elseif self.transitionIsHorizontal( obj )
                    m3iObj.srcTangent = self.M3ITransInfoMap(obj.Id).srcTangent;
                    m3iObj.dstTangent = self.M3ITransInfoMap(obj.Id).dstTangent;
                end
            end
        end

        function implMoveObjsToBottom( self, moveToBottom, bottomBoundary, graphicalObjs )
            rGraphicalObjs = fliplr( graphicalObjs' );
            for gObj = rGraphicalObjs(:)'
                m3iObj = self.getObjsFromIdsInM3ISet(gObj);
                if self.isaJunctionOrInternalPort(gObj) && gObj.Position.Center(2) - gObj.Position.Radius > bottomBoundary
                    repositionY = m3iObj.absCenter(2) + moveToBottom;
                    radius = m3iObj.size(1) / 2;
                    StateflowDI.SFDomain.repositionElement( self.editor, m3iObj, [m3iObj.absCenter(1) - radius repositionY - radius], m3iObj.size );
                elseif ~isa(gObj, 'Stateflow.Junction') && ...
                        ~isa(gObj, 'Stateflow.Port') && ...
                        gObj.Position(2) > bottomBoundary
                    repositionY = m3iObj.absPosition(2) + moveToBottom;
                    StateflowDI.SFDomain.repositionElement( self.editor, m3iObj, [m3iObj.absPosition(1) repositionY], m3iObj.size );
                end
            end
        end

        function implMoveObjsBelowBoundaryToBottom( self, moveToBottom, bottomBoundary, sortedGraphicalObjs )
            rGraphicalObjs = fliplr( sortedGraphicalObjs );
            for gObj = rGraphicalObjs(:)'
                m3iObj = self.getObjsFromIdsInM3ISet(gObj);
                if self.isaJunctionOrInternalPort(gObj) && gObj.Position.Center(2) - gObj.Position.Radius > bottomBoundary - 1
                    repositionY = m3iObj.absCenter(2) + moveToBottom;
                    radius = m3iObj.size(1) / 2;
                    StateflowDI.SFDomain.repositionElement( self.editor, m3iObj, [m3iObj.absCenter(1) - radius repositionY - radius], m3iObj.size );
                elseif ~isa(gObj, 'Stateflow.Junction') && ...
                        ~isa(gObj, 'Stateflow.Port') && ...
                        gObj.Position(2) > bottomBoundary - 1
                    repositionY = m3iObj.absPosition(2) + moveToBottom;
                    StateflowDI.SFDomain.repositionElement( self.editor, m3iObj, [m3iObj.absPosition(1) repositionY], m3iObj.size );
                end
            end
        end

        function implMoveObjsOnRightSideOfBoundaryToRight( self, moveToRight, rightBoundary, sortedGraphicalObjs )
            rGraphicalObjs = fliplr( sortedGraphicalObjs );
            for gObj = rGraphicalObjs(:)'
                m3iObj = self.getObjsFromIdsInM3ISet(gObj);
                if self.isaJunctionOrInternalPort(gObj) && gObj.Position.Center(1) - gObj.Position.Radius > rightBoundary - 1
                    repositionX = m3iObj.absCenter(1) + moveToRight;
                    radius = m3iObj.size(1) / 2;
                    StateflowDI.SFDomain.repositionElement( self.editor, m3iObj, [repositionX - radius m3iObj.absCenter(2) - radius], m3iObj.size );
                elseif ~isa(gObj, 'Stateflow.Junction') && ...
                        ~isa(gObj, 'Stateflow.Port') && ...
                         gObj.Position(1) > rightBoundary - 1
                    repositionX = m3iObj.absPosition(1) + moveToRight;
                    StateflowDI.SFDomain.repositionElement( self.editor, m3iObj, [repositionX m3iObj.absPosition(2)], m3iObj.size );
                end
            end
        end

        function implMoveObjsToRight( self, moveToRight, rightBoundary, graphicalObjs )
            rGraphicalObjs = fliplr( graphicalObjs' );
            for gObj = rGraphicalObjs(:)'
                m3iObj = self.getObjsFromIdsInM3ISet(gObj);
                if self.isaJunctionOrInternalPort(gObj) && gObj.Position.Center(1) - gObj.Position.Radius > rightBoundary
                    repositionX = m3iObj.absCenter(1) + moveToRight;
                    radius = m3iObj.size(1) / 2;
                    StateflowDI.SFDomain.repositionElement( self.editor, m3iObj, [repositionX - radius m3iObj.absCenter(2) - radius], m3iObj.size );
                elseif ~isa(gObj, 'Stateflow.Junction') && ...
                        ~isa(gObj, 'Stateflow.Port') && ...
                        gObj.Position(1) > rightBoundary
                    repositionX = m3iObj.absPosition(1) + moveToRight;
                    StateflowDI.SFDomain.repositionElement( self.editor, m3iObj, [repositionX m3iObj.absPosition(2)], m3iObj.size );
                end
            end
        end

        function [deltaHeight,bottomBoundary]  = calcChangeInHeight(self, tempObjSet, tfBefore, heightForAll )
            bottomBoundary = double(intmax);
            for i = 1:length(tempObjSet)
                m3iObj = self.getObjsFromIdsInM3ISet(tempObjSet(i));
                if isa(tempObjSet(i), 'Stateflow.Transition')
                    labelHeight = m3iObj.labelSize(2);
                    if labelHeight + self.LABEL_PADDING > abs( m3iObj.srcPosAbs(2) - m3iObj.dstPosAbs(2) )
                        deltaY(i) = labelHeight + self.LABEL_PADDING - abs( m3iObj.srcPosAbs(2) - m3iObj.dstPosAbs(2) ); %#ok<AGROW>
                    else
                        deltaY(i) = 0; %#ok<AGROW>
                    end
                elseif isa(tempObjSet(i), 'Stateflow.EMFunction')       || ...
                        isa(tempObjSet(i), 'Stateflow.AtomicSubchart')   || ...
                        isa(tempObjSet(i), 'Stateflow.SLFunction')       || ...
                        isa(tempObjSet(i), 'Stateflow.TruthTable')       || ...
                        isa(tempObjSet(i), 'Stateflow.State') && tempObjSet(i).IsSubchart || ...
                        isa(tempObjSet(i), 'Stateflow.AtomicBox')        || ...
                        isa(tempObjSet(i), 'Stateflow.SimulinkBasedState')
                    labelHeight = m3iObj.labelSize(2) + m3iObj.labelPosition(2);
                    if labelHeight + self.LABEL_PADDING > m3iObj.size(2)
                        deltaY(i) = labelHeight + self.LABEL_PADDING - m3iObj.size(2); %#ok<AGROW>
                    elseif tfBefore && m3iObj.size(2) < heightForAll
                        deltaY(i) = heightForAll - m3iObj.size(2); %#ok<AGROW>
                    else
                        deltaY(i) = 0; %#ok<AGROW>
                    end
                elseif isa(tempObjSet(i), 'Stateflow.Junction')   || ...
                        isa(tempObjSet(i), 'Stateflow.Annotation') || ...
                        isa(tempObjSet(i), 'Stateflow.Port')
                    deltaY(i) = 0; %#ok<AGROW>
                elseif isa(tempObjSet(i), 'Stateflow.State') && (m3iObj.isGrouped || m3iObj.isGroupContainer) || ...
                        isa(tempObjSet(i), 'Stateflow.Function') && (m3iObj.isGrouped || m3iObj.isGroupContainer) || ...
                        isa(tempObjSet(i), 'Stateflow.Box') && (m3iObj.isGrouped || m3iObj.isGroupContainer)
                    if tfBefore && m3iObj.size(2) < heightForAll
                        deltaY(i) = heightForAll - m3iObj.size(2); %#ok<AGROW>
                    else
                        deltaY(i) = 0; %#ok<AGROW>
                    end
                elseif self.hasGraphicalObjects(tempObjSet(i))
                    expansionDueToInsideObjectsInHeight= self.implResizeObjsVertically(tempObjSet(i) );
                    if isa(tempObjSet(i), 'Stateflow.Function')
                        txtNode.Height = m3iObj.labelSize(2) + m3iObj.labelPosition(2);
                    else
                        txtNode.Height = m3iObj.labelSize(2);
                    end
                    deltaY(i) = expansionDueToInsideObjectsInHeight; %#ok<AGROW>
                    if txtNode.Height + self.LABEL_PADDING > m3iObj.size(2)
                        repositionHeight = txtNode.Height + self.LABEL_PADDING;
                        deltaY(i) = max( repositionHeight - m3iObj.size(2), expansionDueToInsideObjectsInHeight ); %#ok<AGROW>
                    elseif tfBefore && m3iObj.size(2) < heightForAll
                        deltaY(i) = max( heightForAll - m3iObj.size(2), expansionDueToInsideObjectsInHeight); %#ok<AGROW>
                    end
                else
                    txtNode.Height = m3iObj.labelSize(2);
                    repositionHeight = m3iObj.size(2);
                    if txtNode.Height > m3iObj.size(2)
                        repositionHeight = txtNode.Height + self.LABEL_PADDING;
                    end

                    deltaY(i) = max(0, repositionHeight - m3iObj.size(2)); %#ok<AGROW>
                    if tfBefore && m3iObj.size(2) < heightForAll
                        deltaY(i) = max(deltaY(i), heightForAll - m3iObj.size(2)); %#ok<AGROW>
                    end
                end
                if deltaY(i) > 0
                    % If deltaY(i) > 0, it means object cannot be a
                    % junction.
                    bottomBoundary = min(bottomBoundary, m3iObj.absPosition(2) + m3iObj.size(2));
                end
            end
            deltaHeight = deltaY;
        end

        function [deltaWidth,rightBoundary]  = calcChangeInWidth(self, tempObjSet, tfBefore, widthForAll)
            rightBoundary = double(intmax);
            for i = 1:length(tempObjSet)
                m3iObj = self.getObjsFromIdsInM3ISet( tempObjSet(i));
                if isa(tempObjSet(i), 'Stateflow.Transition')
                    labelLength = m3iObj.labelSize(1);
                    if labelLength + self.LABEL_PADDING > abs( m3iObj.srcPosAbs(1) - m3iObj.dstPosAbs(1) )
                        deltaX(i) = labelLength + self.LABEL_PADDING - abs( m3iObj.srcPosAbs(1) - m3iObj.dstPosAbs(1) ); %#ok<AGROW>
                    else
                        deltaX(i) = 0; %#ok<AGROW>
                    end
                elseif isa(tempObjSet(i), 'Stateflow.EMFunction')       || ...
                        isa(tempObjSet(i), 'Stateflow.AtomicSubchart')   || ...
                        isa(tempObjSet(i), 'Stateflow.SLFunction')       || ...
                        isa(tempObjSet(i), 'Stateflow.TruthTable')       || ...
                        isa(tempObjSet(i), 'Stateflow.State') && tempObjSet(i).IsSubchart || ...
                        isa(tempObjSet(i), 'Stateflow.AtomicBox')        || ...
                        isa(tempObjSet(i), 'Stateflow.SimulinkBasedState')
                    labelWidth = m3iObj.labelSize(1) + m3iObj.labelPosition(1);
                    if isa(tempObjSet(i), 'Stateflow.EMFunction') || ...
                            isa(tempObjSet(i), 'Stateflow.SLFunction') || ...
                            isa(tempObjSet(i), 'Stateflow.TruthTable')
                        minimalSize = self.MINIMAL_WIDTH_FOR_FCN;
                    else
                        minimalSize = self.MINIMAL_WIDTH_FOR_STATE;
                    end
                    if labelWidth + self.LABEL_PADDING > m3iObj.size(1) || m3iObj.size(1) < minimalSize
                        deltaX(i) = max(labelWidth + self.LABEL_PADDING - m3iObj.size(1), minimalSize - m3iObj.size(1)); %#ok<AGROW>
                    elseif tfBefore && m3iObj.size(1) < widthForAll
                        deltaX(i) = widthForAll - m3iObj.size(1); %#ok<AGROW>
                    else
                        deltaX(i) = 0; %#ok<AGROW>
                    end
                elseif isa(tempObjSet(i), 'Stateflow.Junction')   || ...
                        isa(tempObjSet(i), 'Stateflow.Annotation') || ...
                        isa(tempObjSet(i), 'Stateflow.Port')
                    deltaX(i) = 0; %#ok<AGROW>
                elseif isa(tempObjSet(i), 'Stateflow.State') && (m3iObj.isGrouped || m3iObj.isGroupContainer) || ...
                        isa(tempObjSet(i), 'Stateflow.Function') && (m3iObj.isGrouped || m3iObj.isGroupContainer) || ...
                        isa(tempObjSet(i), 'Stateflow.Box') && (m3iObj.isGrouped || m3iObj.isGroupContainer)
                    if tfBefore && m3iObj.size(1) < widthForAll
                        deltaX(i) = widthForAll - m3iObj.size(1); %#ok<AGROW>
                    else
                        deltaX(i) = 0; %#ok<AGROW>
                    end
                elseif self.hasGraphicalObjects(tempObjSet(i))
                    expansionDueToInsideObjectsInWidth = self.implResizeObjsHorizontally(tempObjSet(i));
                    if isa(tempObjSet(i), 'Stateflow.Function')
                        txtNode.Width = max(m3iObj.labelSize(1) + m3iObj.labelPosition(1), self.MINIMAL_WIDTH_FOR_FCN);
                    else
                        txtNode.Width = m3iObj.labelSize(1);
                    end
                    deltaX(i) = expansionDueToInsideObjectsInWidth; %#ok<AGROW>
                    if txtNode.Width + self.LABEL_PADDING > m3iObj.size(1)
                        repositionWidth = txtNode.Width + self.LABEL_PADDING;
                        deltaX(i) = max( repositionWidth - m3iObj.size(1), expansionDueToInsideObjectsInWidth ); %#ok<AGROW>
                    elseif tfBefore && m3iObj.size(1) < widthForAll
                        deltaX(i) = max( widthForAll - m3iObj.size(1), expansionDueToInsideObjectsInWidth); %#ok<AGROW>
                    end
                else
                    txtNode.Width = m3iObj.labelSize(1);
                    repositionWidth = m3iObj.size(1);
                    if txtNode.Width > m3iObj.size(1)
                        repositionWidth = txtNode.Width + self.LABEL_PADDING;
                    end
                    deltaX(i) = max(0, repositionWidth - m3iObj.size(1)); %#ok<AGROW>
                    if tfBefore && m3iObj.size(1) < widthForAll
                        deltaX(i) = max(deltaX(i), widthForAll - m3iObj.size(1)); %#ok<AGROW>
                    end
                end
                if deltaX(i) > 0
                    % If deltaX(i) > 0, it means object cannot be a
                    % junction.
                    rightBoundary = min(rightBoundary, m3iObj.absPosition(1) + m3iObj.size(1));
                end
            end
            deltaWidth = deltaX;
        end

        function flag = hasGraphicalObjects(self, objH)
            graphicalObj = objH.find('-isa','Stateflow.DDObject', 'Subviewer', self.subview, '-depth', 1);
            if ~isempty(setdiff( graphicalObj, objH ))
                flag = 1;
            else
                flag = 0;
            end
        end

        function bottomBoundary = findBottomBorderForSetOfStates(~, graphicalObjDown)
            bottomBoundary = double(intmin);
            for gObj = graphicalObjDown(:)'
                if isa(gObj, 'Stateflow.Junction') || isa(gObj, 'Stateflow.Port')
                    radius = gObj.Position.Radius;
                    centerY = gObj.Position.Center(2);
                    bb = radius + centerY;
                    if bb > bottomBoundary
                        bottomBoundary = bb;
                    end
                elseif isa(gObj, 'Stateflow.Transition')
                    srcY      = gObj.SourceEndpoint(2);
                    midY      = gObj.MidPoint(2);
                    dstY = gObj.DestinationEndpoint(2);
                    bb = max(srcY, max(midY, dstY));
                    if bb > bottomBoundary
                        bottomBoundary = bb;
                    end
                else
                    bb = gObj.Position(2) + gObj.Position(4);
                    if bb > bottomBoundary
                        bottomBoundary = bb;
                    end
                end
            end
        end

        function rightBoundary = findRightMostBoundaryForObjs(~, graphicalObj)
            rightBoundary = double(intmin);
            for gObj = graphicalObj(:)'
                if isa(gObj, 'Stateflow.Junction') || isa(gObj, 'Stateflow.Port')
                    radius = gObj.Position.Radius;
                    centerX = gObj.Position.Center(1);
                    rb = radius + centerX;
                    if rb > rightBoundary
                        rightBoundary = rb;
                    end
                elseif isa(gObj, 'Stateflow.Transition')
                    sourceX      = gObj.SourceEndpoint(1);
                    midX         = gObj.MidPoint(1);
                    destinationX = gObj.DestinationEndpoint(1);
                    rb = max(sourceX, max(midX, destinationX));
                    if rb > rightBoundary
                        rightBoundary = rb;
                    end
                else
                    rb = gObj.Position(1) + gObj.Position(3);
                    if rb > rightBoundary
                        rightBoundary = rb;
                    end
                end
            end
        end

        function objSet = findHorizontalOverlapBetween(self, sortedObjSet)
            if isempty( sortedObjSet )
                objSet = [];
                return;
            end
            objSet = sortedObjSet(1);
            metricObj = sortedObjSet(1);
            if length(sortedObjSet) == 1
                return;
            end
            for i = 2:length(sortedObjSet)
                flag = 0;
                if (self.doObjsOverlapHorizontally(metricObj,sortedObjSet(i)))

                    if isa(metricObj, 'Stateflow.Transition')
                        bottomBoundary1 = max( metricObj.SourceEndpoint(2), metricObj.DestinationEndpoint(2) );
                    elseif isa(metricObj, 'Stateflow.Junction') || isa(metricObj, 'Stateflow.Port')
                        bottomBoundary1 = metricObj.Position.Center(2) + metricObj.Position.Radius;
                    else
                        bottomBoundary1 = metricObj.Position(2) + metricObj.Position(4);
                    end

                    if isa(sortedObjSet(i), 'Stateflow.Transition')
                        bottomBoundary2 = max( sortedObjSet(i).SourceEndpoint(2), sortedObjSet(i).DestinationEndpoint(2) );
                    elseif isa(sortedObjSet(i), 'Stateflow.Junction') || isa(sortedObjSet(i), 'Stateflow.Port')
                        bottomBoundary2 = sortedObjSet(i).Position.Center(2) + sortedObjSet(i).Position.Radius;
                    else
                        bottomBoundary2 = sortedObjSet(i).Position(2) + sortedObjSet(i).Position(4);
                    end

                    if bottomBoundary1 > bottomBoundary2
                        metricObj = sortedObjSet(i);
                    end

                    for j = 1:length(objSet)
                        if (self.doObjsOverlapVertically(objSet(j),sortedObjSet(i)))
                            flag = 1;
                            break;
                        end

                        if j == length(objSet)
                            objSet = [objSet, sortedObjSet(i)]; %#ok<AGROW>
                        end
                    end
                else
                    break;
                end

                if flag == 1
                    break;
                end
            end
        end

        function objSet = findVerticalOverlapBetween(self, sortedObjSet)
        % Initialize the set to contain only the first object in
        % the set.
            if isempty( sortedObjSet )
                objSet = [];
                return;
            end
            objSet = sortedObjSet(1);
            metricObj = sortedObjSet(1);
            if length(sortedObjSet) == 1
                return;
            end
            for i = 2:length(sortedObjSet)
                flag = 0;
                if (self.doObjsOverlapVertically(metricObj,sortedObjSet(i)))

                    if isa(metricObj, 'Stateflow.Transition')
                        rightBoundary1 = max( metricObj.SourceEndpoint(1), metricObj.DestinationEndpoint(1) );
                    elseif isa(metricObj, 'Stateflow.Junction') || isa(metricObj, 'Stateflow.Port')
                        rightBoundary1 = metricObj.Position.Center(1) + metricObj.Position.Radius;
                    else
                        rightBoundary1 = metricObj.Position(1) + metricObj.Position(3);
                    end

                    if isa(sortedObjSet(i), 'Stateflow.Transition')
                        rightBoundary2 = max( sortedObjSet(i).SourceEndpoint(1), sortedObjSet(i).DestinationEndpoint(1) );
                    elseif isa(sortedObjSet(i), 'Stateflow.Junction') || isa(sortedObjSet(i), 'Stateflow.Port')
                        rightBoundary2 = sortedObjSet(i).Position.Center(1) + sortedObjSet(i).Position.Radius;
                    else
                        rightBoundary2 = sortedObjSet(i).Position(1) + sortedObjSet(i).Position(3);
                    end

                    if rightBoundary1 > rightBoundary2
                        metricObj = sortedObjSet(i);
                    end

                    for j = 1:length(objSet)
                        if (self.doObjsOverlapHorizontally(objSet(j),sortedObjSet(i)))
                            flag = 1;
                            break; % Break is OK because set is sorted
                        end

                        if j  == length(objSet)
                            objSet = [objSet, sortedObjSet(i)]; %#ok<AGROW>
                        end
                    end
                else
                    break;
                end

                if flag == 1
                    break;
                end
            end
        end

        function flag = doObjsOverlapVertically(~, objA, objB)

            if isa(objA, 'Stateflow.Transition')
                objA_X = min( objA.SourceEndpoint(1), objA.DestinationEndpoint(1) );
                objA_Width = abs( objA.SourceEndpoint(1) - objA.DestinationEndpoint(1) );
            elseif isa(objA, 'Stateflow.Junction') || isa(objA, 'Stateflow.Port')
                objA_X = objA.Position.Center(1) - objA.Position.Radius;
                objA_Width = objA.Position.Radius * 2;
            else
                objA_X = objA.Position(1);
                objA_Width = objA.Position(3);
            end

            if isa(objB, 'Stateflow.Transition')
                objB_X = min( objB.SourceEndpoint(1), objB.DestinationEndpoint(1) );
                objB_Width = abs( objB.SourceEndpoint(1) - objB.DestinationEndpoint(1) );
            elseif isa(objB, 'Stateflow.Junction') || isa(objB, 'Stateflow.Port')
                objB_X = objB.Position.Center(1) - objB.Position.Radius;
                objB_Width = objB.Position.Radius * 2;
            else
                objB_X = objB.Position(1);
                objB_Width = objB.Position(3);
            end

            if (objA_X < objB_X && objB_X + objB_Width - objA_X < objA_Width + objB_Width) || ...
                    (objA_X >= objB_X && objA_X + objA_Width - objB_X < objA_Width + objB_Width)
                flag = 1;
            else
                flag = 0;
            end
        end

        function flag = doObjsOverlapHorizontally(~, objA, objB)
            if isa(objA, 'Stateflow.Transition')
                objA_Y = min( objA.SourceEndpoint(2), objA.DestinationEndpoint(2) );
                objA_Height = abs( objA.SourceEndpoint(2) - objA.DestinationEndpoint(2) );
            elseif isa(objA, 'Stateflow.Junction') || isa(objA, 'Stateflow.Port')
                objA_Y = objA.Position.Center(2) - objA.Position.Radius;
                objA_Height = objA.Position.Radius * 2;
            else
                objA_Y = objA.Position(2);
                objA_Height = objA.Position(4);
            end

            if isa(objB, 'Stateflow.Transition')
                objB_Y = min( objB.SourceEndpoint(2), objB.DestinationEndpoint(2) );
                objB_Height = abs( objB.SourceEndpoint(2) - objB.DestinationEndpoint(2) );
            elseif isa(objB, 'Stateflow.Junction') || isa(objB, 'Stateflow.Port')
                objB_Y = objB.Position.Center(2) - objB.Position.Radius;
                objB_Height = objB.Position.Radius * 2;
            else
                objB_Y = objB.Position(2);
                objB_Height = objB.Position(4);
            end

            if (objA_Y < objB_Y && objB_Y + objB_Height - objA_Y < objA_Height + objB_Height) || ...
                    (objA_Y >= objB_Y && objA_Y + objA_Height - objB_Y < objA_Height + objB_Height)
                flag = 1;
            else
                flag = 0;
            end
        end

        function tf = isInnerTransition( self, trans )
            if ~self.transitionIsValid( trans )
                tf = 0;
                return;
            end
            if isempty( trans.Source )
                tf = false;
            elseif isequal( trans.getParent.Id, trans.Source.Id) || ...
                    isequal( trans.getParent.Id, trans.Destination.Id)
                tf = true;
            else
                tf = false;
            end
        end

        function tf = isSuperTransition( self, trans )
            if ~self.transitionIsValid( trans )
                tf = 0;
                return;
            end
            if self.isDefaultTransition( trans )
                tf = false;
            elseif self.isInnerTransition(trans)
                tf = false;
            elseif ~isequal( trans.getParent.Id, trans.Source.getParent.Id ) || ...
                    ~isequal( trans.getParent.Id, trans.Destination.getParent.Id )
                tf = true;
            else
                tf = false;
            end
        end

        function tf = isDefaultTransition( self, trans )
            if ~self.transitionIsValid( trans )
                tf = 0;
                return;
            end
            if isempty( trans.Source )
                tf = 1;
            else
                tf = 0;
            end
        end

        function tf = isSelfTransition( self, trans )
            if ~self.transitionIsValid( trans )
                tf = 0;
                return;
            end
            if self.isDefaultTransition( trans )
                tf = 0;
            elseif isequal( trans.Source.Id, trans.Destination.Id )
                tf = 1;
            else
                tf = 0;
            end
        end

        function target = sortFromTopToBottom( ~, targetArray )
            pos = zeros(length(targetArray), 1);
            for i = 1:length(targetArray)
                if isa(targetArray(i), 'Stateflow.Junction') || isa(targetArray(i), 'Stateflow.Port')
                    pos(i) = targetArray(i).Position.Center(2) - targetArray(i).Position.Radius;
                elseif isa(targetArray(i), 'Stateflow.Transition')
                    pos(i) = min(targetArray(i).SourceEndpoint(2), targetArray(i).DestinationEndpoint(2));
                else
                    pos(i) = targetArray(i).position(2);
                end
            end
            [~,J] = sort(pos);
            target = targetArray(J);
        end

        function target = sortFromLeftToRight(~, targetArray)
            pos = zeros(length(targetArray),1);
            for i = 1:length(targetArray)
                if isa(targetArray(i), 'Stateflow.Junction') || isa(targetArray(i), 'Stateflow.Port')
                    pos(i) = targetArray(i).Position.Center(1) - targetArray(i).Position.Radius;
                elseif isa(targetArray(i), 'Stateflow.Transition')
                    pos(i) = min(targetArray(i).SourceEndpoint(1), targetArray(i).DestinationEndpoint(1));
                else
                    pos(i) = targetArray(i).position(1);
                end
            end
            [~,J] = sort(pos);
            target = targetArray(J);
        end

        function undoBeautification(self)
            isContextMenu = false;
            domain = self.editor.getStudio.getActiveDomain;
            domain.undo(isContextMenu);
            % Clear undo/redo stack.
            StateflowDI.Util.clearRedoStack( self.subview.Id );
        end

        function objToParentIdMap = calParentForEachObj( self, graphicalObjsOnCurrentView)
            graphicalObjsOnCurrentView = setdiff( graphicalObjsOnCurrentView, self.subview );
            setOfAnnotation = self.subview.find('-isa', 'Stateflow.Annotation', 'Subviewer', self.subview);
            if ~isempty(setOfAnnotation)
                graphicalObjsOnCurrentView = setdiff( graphicalObjsOnCurrentView, setOfAnnotation );
            end
            if isempty( graphicalObjsOnCurrentView )
                objToParentIdMap = [];
            else
                objIdSet = arrayfun(@(x) x.id, graphicalObjsOnCurrentView);
                objParentIdSet = arrayfun(@(x) x.getParent.id, graphicalObjsOnCurrentView);
                objToParentIdMap = containers.Map(objIdSet, objParentIdSet);
            end
        end

        function objIdMap = calBadIntersectForEachObj( self, graphicalObjsOnCurrentView )
            graphicalObjsOnCurrentView = setdiff(graphicalObjsOnCurrentView, self.subview);
            objIds = arrayfun(@(x) self.objIsRectangular(x), graphicalObjsOnCurrentView);
            rectangularObjs = graphicalObjsOnCurrentView( objIds );
            if isempty( rectangularObjs )
                objIdMap = [];
                return;
            end
            objIds = arrayfun(@(x) x.Id, rectangularObjs);
            objBadIntersectionSet = arrayfun(@(x) x.BadIntersection, rectangularObjs);
            objIdMap = containers.Map(objIds, objBadIntersectionSet);
        end

        function objSet = getTransitionsOnCurrentView( self )
            objSet = self.subview.find('-isa', 'Stateflow.Transition', 'Subviewer', self.subview);
            transInGroupedObjIdxSet = false(1, length(objSet));
            for iter = 1:length(objSet)
                parentId = objSet(iter).getParent.Id;
                if ~isequal(objSet(iter).getParent, self.subview) && ...
                        (self.setOfIdToM3IObjMap(parentId).isGrouped || ...
                         self.setOfIdToM3IObjMap(parentId).isGroupContainer)
                    transInGroupedObjIdxSet(iter) = 1;
                end
            end
            transInGroupedObj = objSet(transInGroupedObjIdxSet);
            if ~isempty(transInGroupedObj)
                objSet = setdiff( objSet, transInGroupedObj );
            end
        end

        function objSet = getLvlOneObjsNeedResizingFor( self, objH )
            if isequal( objH.Id, self.subview.Id )
                objSet = self.subview.find('-isa', 'Stateflow.State',          '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                           '-isa', 'Stateflow.AtomicSubchart', '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                           '-isa', 'Stateflow.Function',       '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                           '-isa', 'Stateflow.Box',            '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                           '-isa', 'Stateflow.EMFunction',     '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                           '-isa', 'Stateflow.SLFunction',     '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                           '-isa', 'Stateflow.TruthTable',     '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                           '-isa', 'Stateflow.AtomicBox',      '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                           '-isa', 'Stateflow.SimulinkBasedState',    '-depth', 1, 'Subviewer', self.subview);
            else
                objSet = objH.find('-isa', 'Stateflow.State',          '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                   '-isa', 'Stateflow.AtomicSubchart', '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                   '-isa', 'Stateflow.Function',       '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                   '-isa', 'Stateflow.Box',            '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                   '-isa', 'Stateflow.EMFunction',     '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                   '-isa', 'Stateflow.SLFunction',     '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                   '-isa', 'Stateflow.TruthTable',     '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                   '-isa', 'Stateflow.AtomicBox',      '-depth', 1, 'Subviewer', self.subview, '-or', ...
                                   '-isa', 'Stateflow.SimulinkBasedState',    '-depth', 1, 'Subviewer', self.subview);
                objSet = setdiff( objSet, objH );
            end
        end

        function objSet = getLvlOneTransFor( self, objH )
            if isequal( objH.Id, self.subview.Id ) && isa(self.subview, 'Stateflow.Chart') || ...
                    isequal( objH.Id, self.subview.Id ) && isa(self.subview, 'Stateflow.TruthTable') || ...
                    isequal( objH.Id, self.subview.Id ) && ~isa(self.subview, 'Stateflow.Chart') && ~objH.IsGrouped
                objSet = self.subview.find('-isa', 'Stateflow.Transition', '-depth', 1, 'Subviewer', self.subview);
            elseif self.getObjsFromIdsInM3ISet(objH).isGrouped || self.getObjsFromIdsInM3ISet(objH).isGroupContainer
                objSet = [];
            else
                objSet = objH.find('-isa', 'Stateflow.Transition', '-depth', 1, 'Subviewer', self.subview);
                if ~isempty(objSet)
                    objSet = intersect(objSet, self.setOfTransitions);
                end
            end
        end

        function objSet = getLvlOneGraphicalObjsFor( self, objH )
            if isequal( objH.Id, self.subview.Id ) && isa(self.subview, 'Stateflow.Chart') || ...
                    isequal( objH.Id, self.subview.Id ) && isa(self.subview, 'Stateflow.TruthTable') || ...
                    isequal( objH.Id, self.subview.Id ) && ~isa(self.subview, 'Stateflow.Chart') && ~objH.IsGrouped
                objSet = self.subview.find('-isa', 'Stateflow.DDObject', '-depth', 1, 'Subviewer', self.subview);
            elseif self.getObjsFromIdsInM3ISet(objH).isGrouped || self.getObjsFromIdsInM3ISet(objH).isGroupContainer
                objSet = [];
            else
                objSet = objH.find('-isa', 'Stateflow.DDObject', '-depth', 1, 'Subviewer', self.subview);
                objSet = setdiff( objSet, objH );
            end
        end

        function objH = getHandleFromId( ~, objId )
            objH = sf('IdToHandle', objId );
        end

        function mapObj = getIdToM3IObjMap( ~, graphicalObjSetOnCurrentView )
            if isempty( graphicalObjSetOnCurrentView )
                mapObj = [];
                return;
            end
            setOfObjIds = cell(1, length(graphicalObjSetOnCurrentView));
            setOfM3IObjs = cell(1, length(graphicalObjSetOnCurrentView));

            for iter = 1:length(graphicalObjSetOnCurrentView)
                setOfObjIds{iter} = graphicalObjSetOnCurrentView(iter).id;
                m3i = StateflowDI.Util.getDiagramElement(setOfObjIds{iter});
                setOfM3IObjs{iter} = m3i.temporaryObject;
            end

            mapObj = containers.Map( setOfObjIds, setOfM3IObjs );
        end

        function mapObj = getInitPositionOfTransOnCurrentView( self )
            if isempty( self.setOfTransitions )
                mapObj = [];
                return;
            end

            elSize = length(self.setOfTransitionM3IObjs);
            srcPosAbs = cell(1,elSize);
            midPosAbs = cell(1,elSize);
            dstPosAbs = cell(1,elSize);
            labelPosAbs = cell(1,elSize);
            labelSize = cell(1,elSize);
            SourceOClock = cell(1,elSize);
            DestinationOClock = cell(1,elSize);

            for iter = 1:length(self.setOfTransitionM3IObjs)
                x = self.setOfTransitionM3IObjs{iter};
                y = self.setOfTransitions(iter);
                srcPosAbs{iter} = x.srcPosAbs;
                midPosAbs{iter} = x.midPosAbs;
                dstPosAbs{iter} = x.dstPosAbs;
                labelPosAbs{iter} = x.labelPosAbs;
                labelSize{iter} = x.labelSize;
                SourceOClock{iter} = y.SourceOClock;
                DestinationOClock{iter} = y.DestinationOClock;
            end

            transitionInfoStruct = struct('initSrcPosAbs'          ,    srcPosAbs, ...
                                          'initMidPosAbs'          ,    midPosAbs, ...
                                          'initDstPosAbs'          ,    dstPosAbs, ...
                                          'initLabelPosAbs'        ,    labelPosAbs, ...
                                          'initLabelSize'          ,    labelSize, ...
                                          'SourceOClock'           ,    SourceOClock, ...
                                          'DestinationOClock'      ,    DestinationOClock );
            if length( self.setOfTransitionIds ) == 1
                mapObj = containers.Map( self.setOfTransitionIds, transitionInfoStruct );
            else
                mapObj = containers.Map( self.setOfTransitionIds, arrayfun(@(x) {x}, transitionInfoStruct) );
            end
        end

        function mapObj = getNotificationStructMapOnCurrentView( ~, grapicalObjSetOnCurrentView )
            if isempty( grapicalObjSetOnCurrentView )
                mapObj = [];
            else
                elSize = length(grapicalObjSetOnCurrentView);
                [isResized{1:elSize}] = deal(0);
                [isAligned{1:elSize}] = deal(0);
                [isStraightened{1:elSize}] = deal(0);
                [isRepositioned{1:elSize}] = deal(0);
                setOfObjIds = cell(1, elSize);
                notificationStruct = struct('isResized'     , isResized, ...
                                            'isAligned'     , isAligned, ...
                                            'isStraightened', isStraightened, ...
                                            'isRepositioned', isRepositioned);
                for iter = 1:length(grapicalObjSetOnCurrentView)
                    setOfObjIds{iter} = grapicalObjSetOnCurrentView(iter).id;
                end
                if length( setOfObjIds ) == 1
                    mapObj = containers.Map( setOfObjIds{1}, notificationStruct );
                else
                    mapObj = containers.Map( setOfObjIds, arrayfun(@(x) {x}, notificationStruct) );
                end
            end
        end

        function mapObj = getTransitionInfoOnCurrentView( self )

            if isempty( self.setOfTransitions )
                mapObj = [];
                return;
            end
            transStruct = StateflowDI.SFDomain.getTransitionInfoForChart(self.setOfTransitionIds);
            if length( self.setOfTransitionIds ) == 1
                mapObj = containers.Map( self.setOfTransitionIds, transStruct );
            else
                mapObj = containers.Map( self.setOfTransitionIds, arrayfun(@(x) {x}, transStruct) );
            end
        end

        function tf = transitionIsValid( ~, trans )
            if isempty( trans.Destination )
                tf = 0;
            else
                tf = 1;
            end
        end

        function flag = transitionIsHorizontal(self, trans)
            if ~ismember( trans, self.setOfTransitions ) || ...
                    ~self.transitionIsValid( trans ) || ...
                    ~isempty( trans.Source ) && isequal(trans.Source.Id, trans.Destination.Id)
                flag = false;
                return;
            end
            m3iTrans = self.M3ITransInfoMap(trans.Id);
            if m3iTrans.srcTangent(1) >=  0.9 && abs(m3iTrans.srcTangent(2)) <= 0.3 && m3iTrans.dstTangent(1) <= -0.9 && abs(m3iTrans.dstTangent(2)) <= 0.3 && self.setOfInitialTransPositionInfo(trans.Id).initSrcPosAbs(1) < self.setOfInitialTransPositionInfo(trans.Id).initDstPosAbs(1) || ...
                    m3iTrans.srcTangent(1) <= -0.9 && abs(m3iTrans.srcTangent(2)) <= 0.3 && m3iTrans.dstTangent(1) >=  0.9 && abs(m3iTrans.dstTangent(2)) <= 0.3 && self.setOfInitialTransPositionInfo(trans.Id).initSrcPosAbs(1) > self.setOfInitialTransPositionInfo(trans.Id).initDstPosAbs(1)
                flag = true;
            else
                flag = false;
            end
        end

        function flag = transitionIsVertical(self, trans)
            if ~ismember(trans, self.setOfTransitions) || ...
                    ~self.transitionIsValid( trans ) || ...
                    ~isempty( trans.Source ) && isequal(trans.Source.Id, trans.Destination.Id)
                flag = false;
                return;
            end
            m3iTrans = self.M3ITransInfoMap(trans.Id);
            initPositionInfo = self.setOfInitialTransPositionInfo(trans.Id);
            flag = Stateflow.Tools.Beautifier.isTransitionVertical(m3iTrans, initPositionInfo);
        end

        function transIds = findStraightTransitions( self )
            transIds = [];
            for i = 1:length(self.setOfTransitionM3IObjs)
                m3iTrans = self.setOfTransitionM3IObjs{i};
                if (isequal( m3iTrans.srcTangent, [ 1 0] ) && isequal( m3iTrans.dstTangent, [-1 0]) || ...
                    isequal( m3iTrans.srcTangent, [-1 0] ) && isequal( m3iTrans.dstTangent, [ 1 0])) && ...
                        abs(m3iTrans.srcPosAbs(2) - m3iTrans.midPosAbs(2)) < 0.01 && abs(m3iTrans.srcPosAbs(2) - m3iTrans.dstPosAbs(2)) < 0.01 || ...
                        (isequal( m3iTrans.srcTangent, [0  1] ) && isequal( m3iTrans.dstTangent, [0 -1]) || ...
                         isequal( m3iTrans.srcTangent, [0 -1] ) && isequal( m3iTrans.dstTangent, [0  1])) && ...
                        abs(m3iTrans.srcPosAbs(1) - m3iTrans.midPosAbs(1)) < 0.01 && abs(m3iTrans.srcPosAbs(1) - m3iTrans.dstPosAbs(1)) < 0.01
                    transIds = [transIds double(m3iTrans.backendId)]; %#ok<AGROW>
                end
            end
        end

        function reportInfoToDiagnosticViewer(self, results)
            if self.AllowNotificationDisplay
                sldiagviewer.reportInfo(results);
            end
        end

        function reportErrorToDiagnosticViewer(self, exceptionObj)
            if self.AllowNotificationDisplay
                sldiagviewer.reportError(exceptionObj);
            end
        end
    end

    methods (Static)

        function invoke(varargin)
            editorH = StateflowDI.SFDomain.getLastActiveEditor;

            if nargin == 0
                invokedFromUI = true;
            else
                if nargin >= 1 && islogical(varargin{1})
                    invokedFromUI = varargin{1};
                else
                    invokedFromUI = true;
                end
                if nargin >= 2
                    subviewerId = varargin{2};
                    editorH = StateflowDI.SFDomain.getLastActiveEditorFor(subviewerId);
                end
                if nargin >= 3
                    allowNotifications = varargin{3};
                end
            end

            if ~isempty( editorH )
                SLM3I.ScopedStudioBlocker(message('Stateflow:studio:ArrangeLayoutStatusBarMsg').getString());
                obj = Stateflow.Tools.Beautifier(editorH);

                if exist('allowNotifications', 'var')
                    obj.AllowNotificationDisplay = allowNotifications;
                end

                subviewer = sf('IdToHandle', double(editorH.getDiagram.backendId));
                modelName = subviewer.Machine.Name;
                stage = sldiagviewer.createStage(message('Stateflow:studio:ArrangeLayoutSchemaLabel').getString(), 'ModelName', modelName);
                try
                    results = obj.beautify();
                    obj.reportInfoToDiagnosticViewer(results);
                catch reason
                    if invokedFromUI
                        ME = MException('Stateflow:ArrangeLayout:ArrangeLayoutFailed', message('Stateflow:studio:ArrangeLayoutFailed').getString());
                        ME = ME.addCause(reason);
                        obj.reportErrorToDiagnosticViewer(ME);
                    else
                        throw(reason);
                    end
                end
                delete(stage);
            end
        end

        function isVertical = isTransitionVertical(m3iTrans, initPositionInfo)

            if ~exist('initPositionInfo', 'var')
                initPositionInfo.initSrcPosAbs = m3iTrans.srcPosAbs;
                initPositionInfo.initDstPosAbs = m3iTrans.dstPosAbs;
            end

            isVertical = m3iTrans.srcTangent(2) >=  0.9 && ...
                abs(m3iTrans.srcTangent(1)) <= 0.3 && ...
                m3iTrans.dstTangent(2) <= -0.9 && ...
                abs(m3iTrans.dstTangent(1)) <= 0.3 && ...
                initPositionInfo.initSrcPosAbs(2) < initPositionInfo.initDstPosAbs(2) || ...
                m3iTrans.srcTangent(2) <= -0.9 && ...
                abs(m3iTrans.srcTangent(1)) <= 0.3 && ...
                m3iTrans.dstTangent(2) >=  0.9 && ...
                abs(m3iTrans.dstTangent(1)) <= 0.3 && ...
                initPositionInfo.initSrcPosAbs(2) > initPositionInfo.initDstPosAbs(2);
        end

    end
end
