classdef diagramLayoutForSTT < handle%
%

%   Copyright 2016-2020 The MathWorks, Inc.

    properties
        subviewerId = [];
    end

    methods (Access = private)
        function this = diagramLayoutForSTT( subviewerId )
            this.subviewerId = subviewerId;
        end

        function construct(this)
            subview = this.getSubviewer( this.subviewerId );
            graphicalObjsOnCurrentView = this.getGraphicalObjsOnCurrentView( subview );
            if isempty( graphicalObjsOnCurrentView )
                return;
            end

            this.implPostConstructForSTT( this.subviewerId );
        end

        function implPostConstructForSTT( this, subviewerId )
            [states, junctions, transitions, UDDTransInfoMap] = this.setup( subviewerId );
            if isempty( states )
                return;
            end
            this.implUniformLabelSize( transitions );
            this.implAdjustHorizontally( states, junctions, transitions, UDDTransInfoMap, subviewerId );
            this.implAdjustVertically( states, junctions, transitions, UDDTransInfoMap );
            this.implRestoreOClocksForTransitions( transitions, UDDTransInfoMap )
            this.implReadjustObjsOnCanvas( subviewerId, states, junctions );
            this.implTransitionLabelRepositioning( transitions, states );
        end

        function implUniformLabelSize( ~, transitions )
            for trans = transitions(:)'
                if abs(trans.FontSize - 16) > .01
                    trans.FontSize = 16;
                end
            end
        end

        function implReadjustObjsOnCanvas( this, subviewerId, states, junctions )
            subview = this.getSubviewer( subviewerId );
            isSubviewChart = this.isSubviewerTheChart( subviewerId );
            if ~isSubviewChart
                innerTrans = sf('InnerTransitionsOf', subviewerId);
                if length( innerTrans ) == 1
                    innerTransUddH = sf('IdToHandle', innerTrans);
                    if innerTransUddH.DestinationOClock ~= 9
                        innerTransUddH.DestinationOClock = 9;
                    end
                    reserve = max(100, innerTransUddH.LabelPosition(3) + 15);
                else
                    reserve = 100;
                end
                objSet = [states', junctions'];
                sortedObjSet = this.sortFromLeftToRight( objSet );

                if isa(sortedObjSet(1), 'Stateflow.Junction')
                    if sortedObjSet(1).Position.Center(1) < reserve + 5
                        tempJunc = Stateflow.Junction( subview );
                        tempJunc.Position.Center = [4 4];
                        tempJunc.delete;
                        objectLimits = sf('get', subviewerId, '.subviewS.objectLimits');
                        tempBox = Stateflow.Box( subview );
                        tempBoxInX = sortedObjSet(1).Position.Center(1) - sortedObjSet(1).Position.Radius - 1;
                        tempBoxWidth = objectLimits(2) - (tempBoxInX - objectLimits(1));
                        tempBox.Position = [tempBoxInX 0 tempBoxWidth objectLimits(4)];
                        tempBox.isGrouped = 1;
                        tempBox.Position(1) = reserve + 5;
                        tempBox.isGrouped = 0;
                        tempBox.delete;
                    end
                end

            end
        end

        function implAdjustHorizontally( this, states, junctions, transitions, UDDTransInfoMap, subviewerId )
            this.implResizeStatesHorizontally( states, junctions, transitions, UDDTransInfoMap );
            this.implExpandHorizontalTrans( states, junctions, transitions, UDDTransInfoMap, subviewerId );
            this.implAlignStatesVertically( states );
        end

        function implAdjustVertically( this, states, junctions, transitions, UDDTransInfoMap )
            this.implResizeStatesVertically( states, junctions, transitions, UDDTransInfoMap );
            this.implSpaceOutHorizontalTransitionsForState( states, UDDTransInfoMap );
        end

        function implTransitionLabelRepositioning( this, transitions, states )
            function setLabelPosition(trans, x, y)
                if trans.LabelPosition(1) ~= x || trans.LabelPosition(2) ~= y
                    trans.LabelPosition(1) = x;
                    trans.LabelPosition(2) = y;
                end
            end
            for trans = transitions(:)'
                if ~isempty( trans.LabelString )
                    txtNode.Width = trans.LabelPosition(3);
                    txtNode.Height = trans.LabelPosition(4);
                    % For some cases, the transitions are not strictly
                    % horizontal or vertical, instead of using
                    % isequal(src,dst), using abs(src - dst) < threshold.
                    if abs( trans.SourceEndpoint(2) - trans.DestinationEndpoint(2) ) < 2
                        
                        if isa(trans.Source, 'Stateflow.State')
                            if trans.SourceEndpoint(1) < trans.DestinationEndpoint(1)
                                setLabelPosition( trans, ...
                                    ceil(trans.SourceEndpoint(1) + 5), ...
                                    ceil(trans.SourceEndpoint(2) - txtNode.Height - 2));
                            else
                                setLabelPosition(trans, ...
                                    ceil(trans.SourceEndpoint(1) - txtNode.Width - 5), ...
                                    ceil(trans.SourceEndpoint(2) - txtNode.Height - 2));
                            end
                        elseif isa(trans.Destination, 'Stateflow.State')
                            if trans.SourceEndpoint(1) < trans.DestinationEndpoint(1)
                                setLabelPosition(trans, ...
                                    ceil(trans.DestinationEndpoint(1) - txtNode.Width - 5), ...
                                    ceil(trans.DestinationEndpoint(2) - txtNode.Height - 2));
                            else
                                setLabelPosition(trans, ...
                                    ceil(trans.DestinationEndpoint(1) + 5), ...
                                    ceil(trans.DestinationEndpoint(2) - txtNode.Height - 2));
                            end
                        else
                            leftMidPos.x = abs(trans.SourceEndpoint(1) - trans.DestinationEndpoint(1)) + min(trans.SourceEndpoint(1), trans.DestinationEndpoint(1));
                            leftMidPos.y = trans.MidPoint(2);
                            trans.LabelPosition(1) = ceil(leftMidPos.x - txtNode.Width / 2 - 2);
                            trans.LabelPosition(2) = ceil(leftMidPos.y - txtNode.Height - 2);
                        end
                    end
                end
            end

            sortedStates = this.sortFromTopToBottom( states );
            for obj = sortedStates(:)'
                srcTransId = sf('SourcedTransitionsOf', obj.Id);
                dstTransId = sf('SinkedTransitionsOf', obj.Id);
                transId = [srcTransId, dstTransId];
                trans = sf('IdToHandle',transId);
                verticalTransIdxSet = arrayfun(@(x) abs( x.SourceEndpoint(1) - x.DestinationEndpoint(1) ) < 1, trans);
                verticalTrans = trans( verticalTransIdxSet );
                bottomVerticalTransIdxSet = arrayfun(@(x) ~isempty( x.Source ) && isequal( x.Source.Id, obj.Id) && x.SourceEndpoint(2) < x.DestinationEndpoint(2) || ...
                                                     isequal( x.Destination.Id, obj.Id) && x.SourceEndpoint(2) > x.DestinationEndpoint(2), verticalTrans);
                bottomTrans = verticalTrans( bottomVerticalTransIdxSet );

                if length(bottomTrans) > 2
                    % If there are more than two transitions, do nothing at
                    % the moment.
                elseif length(bottomTrans) > 1
                    if bottomTrans(1).SourceEndpoint(1) < bottomTrans(2).SourceEndpoint(1)
                        leftTrans = bottomTrans(1);
                        rightTrans = bottomTrans(2);
                    else
                        leftTrans = bottomTrans(2);
                        rightTrans = bottomTrans(1);
                    end
                    txtNodeLeftTrans.Width = leftTrans.LabelPosition(3);
                    txtNodeLeftTrans.Height = leftTrans.LabelPosition(4);

                    leftMidPos.x = leftTrans.MidPoint(1);
                    leftMidPos.y = abs(leftTrans.SourceEndpoint(2) - leftTrans.DestinationEndpoint(2)) / 2 + min(leftTrans.SourceEndpoint(2), leftTrans.DestinationEndpoint(2));

                    if leftTrans.LabelPosition(1) ~= ceil(leftMidPos.x - txtNodeLeftTrans.Width - 2) || ...
                            leftTrans.LabelPosition(2) ~= ceil(leftMidPos.y - txtNodeLeftTrans.Height / 2)
                        leftTrans.LabelPosition(1) = ceil(leftMidPos.x - txtNodeLeftTrans.Width - 2);
                        leftTrans.LabelPosition(2) = ceil(leftMidPos.y - txtNodeLeftTrans.Height / 2);
                    end

                    txtNodeRightTrans.Height = rightTrans.LabelPosition(4);

                    rightMidPos.x = rightTrans.MidPoint(1);
                    rightMidPos.y = abs(rightTrans.SourceEndpoint(2) - rightTrans.DestinationEndpoint(2)) / 2 + min(rightTrans.SourceEndpoint(2), rightTrans.DestinationEndpoint(2));

                    if rightTrans.LabelPosition(1) ~= ceil(rightMidPos.x + 2) || ...
                            rightTrans.LabelPosition(2) ~= ceil(rightMidPos.y - txtNodeRightTrans.Height / 2)
                        rightTrans.LabelPosition(1) = ceil(rightMidPos.x + 2);
                        rightTrans.LabelPosition(2) = ceil(rightMidPos.y - txtNodeRightTrans.Height / 2);
                    end
                elseif ~isempty(bottomTrans)
                    txtNode.Height = bottomTrans.LabelPosition(4);

                    midPos.x = bottomTrans.MidPoint(1);
                    midPos.y = abs(bottomTrans.SourceEndpoint(2) - bottomTrans.DestinationEndpoint(2)) / 2 + min(bottomTrans.SourceEndpoint(2), bottomTrans.DestinationEndpoint(2));

                    bottomTrans.LabelPosition(1) = ceil(midPos.x + 2);
                    bottomTrans.LabelPosition(2) = ceil(midPos.y - txtNode.Height / 2);
                end
            end

            defaultTransIdxSet = arrayfun(@(x) isempty(x.Source), transitions);
            defaultTrans = transitions( defaultTransIdxSet );
            for trans = defaultTrans(:)'
                if abs( trans.SourceEndpoint(1) - trans.DestinationEndpoint(1) ) < 1
                    txtNode.Width = trans.LabelPosition(3);
                    txtNode.Height = trans.LabelPosition(4);
                    if trans.LabelPosition(1) ~= ceil(trans.MidPoint(1) - txtNode.Width - 2) || ...
                            trans.LabelPosition(2) ~= ceil(trans.MidPoint(2) - txtNode.Height / 2)
                    
                        trans.LabelPosition(1) = ceil(trans.MidPoint(1) - txtNode.Width - 2);
                        trans.LabelPosition(2) = ceil(trans.MidPoint(2) - txtNode.Height / 2);
                    end
                end
            end
        end

        function implRestoreOClocksForTransitions( ~, transitions, UDDTransInfoMap )
            for trans = transitions(:)'
                if isa(trans.Source, 'Stateflow.State') && isa(trans.Destination, 'Stateflow.State')
                    if trans.SourceOClock ~= UDDTransInfoMap(trans.Id).SourceOClock || ...
                            trans.DestinationOClock ~= UDDTransInfoMap(trans.Id).DestinationOClock
                        % Resetting to the same value dirties the model in
                        % mcos so we must ensure they are different
                        trans.SourceOClock = UDDTransInfoMap(trans.Id).SourceOClock;
                        trans.DestinationOClock = UDDTransInfoMap(trans.Id).DestinationOClock;
                    end
                end
            end
        end

        function implSpaceOutHorizontalTransitionsForState(this, states, UDDTransInfoMap)
            for objUddH = states(:)'
                srcTransIds = sf('SourcedTransitionsOf', objUddH.Id);

                dstTransIds = sf('SinkedTransitionsOf', objUddH.Id);
                dstTransUddHs = sf('IdToHandle', dstTransIds);
                defaultTransFlag = arrayfun(@(x) isempty(x.Source), dstTransUddHs);
                defaultTrans = dstTransUddHs(defaultTransFlag);

                outerTransIds = [srcTransIds, dstTransIds];
                if ~isempty( defaultTrans )
                    defaultTransIds = arrayfun(@(x) x.Id, defaultTrans);
                    outerTransIds = setdiff( outerTransIds, defaultTransIds );
                end

                if ~isempty( outerTransIds )
                    this.impSpaceOutTransitionsOnLeftSideOfState( outerTransIds, objUddH.Id, UDDTransInfoMap );
                    this.impSpaceOutTransitionsOnRightSideOfState( outerTransIds, objUddH.Id, UDDTransInfoMap );
                end
            end
        end

        function impSpaceOutTransitionsOnRightSideOfState(this, outerTransIds, objUddHId, UDDTransInfoMap)
        % Try to space out transitions on the right side of the state
            transOnRightSideOfStateIds = [];
            for transId = outerTransIds(:)'
                transUddH = sf('IdToHandle', transId);
                if isequal(transUddH.Source.Id, objUddHId) && ...
                        transUddH.SourceOClock >= 1.5 && transUddH.SourceOClock < 4.5 || ...
                        isequal(transUddH.Destination.Id, objUddHId) && ...
                        transUddH.DestinationOClock >= 1.5 && transUddH.DestinationOClock < 4.5
                    transOnRightSideOfStateIds = [transOnRightSideOfStateIds, transId]; %#ok<AGROW>
                end
            end

            if length(transOnRightSideOfStateIds) > 1
                % Sort the transitions on the right-side of state from top to
                % bottom
                transOnRightSideOfStateUddH = sf('IdToHandle', transOnRightSideOfStateIds);
                transOnRightSideOfStateUddH = this.sortTransFromTopToBottomForState(transOnRightSideOfStateUddH,objUddHId);
                for transIndex = 2:length(transOnRightSideOfStateUddH)
                    if isequal(transOnRightSideOfStateUddH(transIndex-1).Source.Id, objUddHId)
                        expectedY = transOnRightSideOfStateUddH(transIndex-1).SourceEndpoint(2) + transOnRightSideOfStateUddH(transIndex).LabelPosition(4) + 10;
                    else
                        expectedY = transOnRightSideOfStateUddH(transIndex-1).DestinationEndpoint(2) + transOnRightSideOfStateUddH(transIndex).LabelPosition(4) + 10;
                    end
                    if isequal(transOnRightSideOfStateUddH(transIndex).Source.Id, objUddHId)
                        actualY = transOnRightSideOfStateUddH(transIndex).SourceEndpoint(2);
                    else
                        actualY = transOnRightSideOfStateUddH(transIndex).DestinationEndpoint(2);
                    end
                    if ~isempty(transOnRightSideOfStateUddH(transIndex).LabelString) && actualY < expectedY
                        if isa(transOnRightSideOfStateUddH(transIndex).Source, 'Stateflow.Junction')
                            transOnRightSideOfStateUddH(transIndex).Source.Position.Center(2) = expectedY;
                        elseif isa(transOnRightSideOfStateUddH(transIndex).Destination, 'Stateflow.Junction')
                            transOnRightSideOfStateUddH(transIndex).Destination.Position.Center(2) = expectedY;
                        else
                            transOnRightSideOfStateUddH(transIndex).SourceOClock = UDDTransInfoMap(transOnRightSideOfStateUddH(transIndex).Id).SourceOClock;
                            transOnRightSideOfStateUddH(transIndex).DestinationOClock = UDDTransInfoMap(transOnRightSideOfStateUddH(transIndex).Id).DestinationOClock;
                        end
                    end
                end
            end
        end

        function impSpaceOutTransitionsOnLeftSideOfState(this, outerTransIds, objUddHId, UDDTransInfoMap )
        % Try to space out transitions on the left side of the state
            transOnLeftSideOfStateIds = [];
            for transId = outerTransIds(:)'
                transUddH = sf('IdToHandle', transId);
                if isequal(transUddH.Source.Id, objUddHId) && ...
                        transUddH.SourceOClock >= 7.5 && transUddH.SourceOClock < 10.5 || ...
                        isequal(transUddH.Destination.Id, objUddHId) && ...
                        transUddH.DestinationOClock >= 7.5 && transUddH.DestinationOClock < 10.5
                    transOnLeftSideOfStateIds = [transOnLeftSideOfStateIds, transId]; %#ok<AGROW>
                end
            end
            if length(transOnLeftSideOfStateIds) > 1
                % Sort the transitions on the left-side of state from top to
                % bottom
                transOnLeftSideOfStateUddH = sf('IdToHandle', transOnLeftSideOfStateIds);
                transOnLeftSideOfStateUddH = this.sortTransFromTopToBottomForState(transOnLeftSideOfStateUddH,objUddHId);

                for transIndex = 2:length(transOnLeftSideOfStateUddH)
                    if isequal(transOnLeftSideOfStateUddH(transIndex-1).Source.Id, objUddHId)
                        expectedY = transOnLeftSideOfStateUddH(transIndex-1).SourceEndpoint(2) + transOnLeftSideOfStateUddH(transIndex).LabelPosition(4) + 10;
                    else
                        expectedY = transOnLeftSideOfStateUddH(transIndex-1).DestinationEndpoint(2) + transOnLeftSideOfStateUddH(transIndex).LabelPosition(4) + 10;
                    end
                    if isequal(transOnLeftSideOfStateUddH(transIndex).Source.Id, objUddHId)
                        actualY = transOnLeftSideOfStateUddH(transIndex).SourceEndpoint(2);
                    else
                        actualY = transOnLeftSideOfStateUddH(transIndex).DestinationEndpoint(2);
                    end
                    if ~isempty(transOnLeftSideOfStateUddH(transIndex).LabelString) && actualY < expectedY
                        if isa(transOnLeftSideOfStateUddH(transIndex).Source, 'Stateflow.Junction')
                            transOnLeftSideOfStateUddH(transIndex).Source.Position.Center(2) = expectedY;
                        elseif isa(transOnLeftSideOfStateUddH(transIndex).Destination, 'Stateflow.Junction')
                            transOnLeftSideOfStateUddH(transIndex).Destination.Position.Center(2) = expectedY;
                        else
                            transOnLeftSideOfStateUddH(transIndex).SourceOClock = UDDTransInfoMap(transOnLeftSideOfStateUddH(transIndex).Id).SourceOClock;
                            transOnLeftSideOfStateUddH(transIndex).DestinationOClock = UDDTransInfoMap(transOnLeftSideOfStateUddH(transIndex).Id).DestinationOClock;
                        end
                    end
                end
            end
        end

        function implResizeStatesVertically( this, states, junctions, transitions, UDDTransInfoMap )
            sortedStates = this.sortFromTopToBottom( states );
            for obj = sortedStates(:)'
                bottomBoundary = this.findBottomBoundary( obj );
                deltaHeight = this.calcChangeInHeight( obj );
                if (deltaHeight > 0)
                    this.implMoveObjsDown( bottomBoundary, states, junctions, transitions, deltaHeight, UDDTransInfoMap );
                    obj.Position(4) = obj.Position(4) + deltaHeight;
                end
            end
        end

        function implMoveObjsDown( this, bottomBoundary, states, junctions, transitions, moveDown, UDDTransInfoMap )
            stateIdxSet = arrayfun(@(x) x.Position(2) > bottomBoundary, states);
            statesNeedToMove = states( stateIdxSet )';
            junctionIdxSet = arrayfun(@(x) x.Position.Center(2) > bottomBoundary, junctions );
            junctionsNeedToMove = junctions( junctionIdxSet )';
            tranIdxSet = arrayfun(@(x) x.SourceEndpoint(2) == x.DestinationEndpoint(2) && x.SourceEndpoint(2) > bottomBoundary, transitions );
            transNeedToMove = transitions( tranIdxSet )';
            objsNeedToMove = [statesNeedToMove, junctionsNeedToMove]';
            if ~isempty( objsNeedToMove )
                objsNeedToMove = this.sortFromTopToBottom( objsNeedToMove );
                rSortedObjsNeedToMove = fliplr( objsNeedToMove' );
                for obj = rSortedObjsNeedToMove(:)'
                    if isa(obj, 'Stateflow.Junction')
                        obj.Position.Center(2) = obj.Position.Center(2) + moveDown;
                    else
                        obj.Position(2) = obj.Position(2) + moveDown;
                    end
                end
            end
            if ~isempty( transNeedToMove )
                for trans = transNeedToMove(:)'
                    trans.SourceOClock = UDDTransInfoMap(trans.Id).SourceOClock;
                    trans.DestinationOClock = UDDTransInfoMap(trans.Id).DestinationOClock;
                end
            end
        end

        function deltaHeight = calcChangeInHeight(this, state)
            assert( isa(state, 'Stateflow.State') );
            m3i = StateflowDI.Util.getDiagramElement(state.Id);
            m3iObj = m3i.temporaryObject;
            txtNode.Height = m3iObj.labelSize(2);
            repositionHeight = state.Position(4);
            if txtNode.Height > state.Position(4)
                repositionHeight = txtNode.Height + 10;
            end
            expansionDueToSpacingOutTransitions = this.changeInHeightDueToSpacingOutTransitionForState((state.Id));
            temp = max(repositionHeight - state.Position(4), expansionDueToSpacingOutTransitions);

            deltaHeight = temp;
        end

        function deltaHeight = changeInHeightDueToSpacingOutTransitionForState( this, stateId )

            objStateUddH = sf('IdToHandle',stateId);

            srcTransIds = sf('SourcedTransitionsOf', stateId);
            dstTransIds = sf('SinkedTransitionsOf', stateId);

            transIds = [srcTransIds, dstTransIds];

            if isempty( transIds )
                deltaHeight = 0;
                return;
            end
            transUddH = sf('IdToHandle', transIds);
            % Calculate the left side of the state
            transOnLeftSideOfStateIdxSet = arrayfun(@(x) ~isempty( x.Source ) && isequal( x.Source.Id, stateId ) && x.SourceOClock >= 7.5 && x.SourceOClock < 10.5 || ...
                                                    isequal( x.Destination.Id, stateId ) && x.DestinationOClock >= 7.5 && x.DestinationOClock < 10.5, transUddH);
            transOnLeftSideOfStateUddH = transUddH( transOnLeftSideOfStateIdxSet );

            deltaHeightOnLeftSide = 0;
            if length(transOnLeftSideOfStateUddH) > 1
                % Sort the transitions on the left-side of state from top to
                % bottom
                transOnLeftSideOfStateUddH = this.sortTransFromTopToBottomForState(transOnLeftSideOfStateUddH,stateId);
                yPositionForLastTranstionOnLeftSide = transOnLeftSideOfStateUddH(1).SourceEndpoint(2);
                % Calculate the height on the left side so that all the labels
                % on transitions will not overlap with each other
                for objTransUddH = transOnLeftSideOfStateUddH(2:end)'
                    if isempty(objTransUddH.LabelString)
                        yPositionForLastTranstionOnLeftSide = objTransUddH.SourceEndpoint(2);
                    else
                        yPositionForLastTranstionOnLeftSide = max(yPositionForLastTranstionOnLeftSide + objTransUddH.LabelPosition(4) + 10, objTransUddH.SourceEndpoint(2));
                    end
                end
                if objStateUddH.Position(2) + objStateUddH.Position(4) < yPositionForLastTranstionOnLeftSide + 16
                    deltaHeightOnLeftSide = yPositionForLastTranstionOnLeftSide + 16 - objStateUddH.Position(2) - objStateUddH.Position(4);
                end
            end


            % Calculate the right side of the state
            transOnRIghtSideOfStateIdxSet = arrayfun(@(x) ~isempty( x.Source ) && isequal( x.Source.Id, stateId) && ...
                                                     x.SourceOClock >= 1.5 && x.SourceOClock < 4.5 || ...
                                                     isequal( x.Destination.Id, stateId) && ...
                                                     x.DestinationOClock >= 1.5 && x.DestinationOClock < 4.5, transUddH);
            transOnRightSideOfStateUddH = transUddH( transOnRIghtSideOfStateIdxSet );

            deltaHeightOnRightSide = 0;
            if length(transOnRightSideOfStateUddH) > 1
                % Sort the transitions on the right-side of state from top to
                % bottom
                transOnRightSideOfStateUddH = this.sortTransFromTopToBottomForState(transOnRightSideOfStateUddH,stateId);
                yPositionForLastTranstionOnRightSide = transOnRightSideOfStateUddH(1).SourceEndpoint(2);
                % Calculate the height on the rigt side so that all the labels
                % on transitions will not overlap with each other
                for objTransUddH = transOnRightSideOfStateUddH(2:end)'
                    if isempty(objTransUddH.LabelString)
                        yPositionForLastTranstionOnRightSide = objTransUddH.SourceEndpoint(2);
                    else
                        yPositionForLastTranstionOnRightSide = max(yPositionForLastTranstionOnRightSide + objTransUddH.LabelPosition(4) + 10, objTransUddH.SourceEndpoint(2));
                    end
                end
                if objStateUddH.Position(2) + objStateUddH.Position(4) < yPositionForLastTranstionOnRightSide + 16
                    deltaHeightOnRightSide = yPositionForLastTranstionOnRightSide + 16 - objStateUddH.Position(2) - objStateUddH.Position(4);
                end
            end

            deltaHeight = max(deltaHeightOnLeftSide, deltaHeightOnRightSide);
        end

        function sortedTransUddHs = sortTransFromTopToBottomForState(~, transUddHs, stateId)
            pos = zeros(length(transUddHs),1);
            for i = 1:length(transUddHs)
                if isequal(transUddHs(i).Source.Id, stateId)
                    pos(i) = transUddHs(i).SourceEndpoint(2);
                else
                    pos(i) = transUddHs(i).DestinationEndpoint(2);
                end
            end
            [~,orderedIdx] = sort(pos);
            sortedTransUddHs = transUddHs(orderedIdx);
        end

        function bottomBoundary = findBottomBoundary( ~, obj )
            assert( isa(obj, 'Stateflow.State') );
            bottomBoundary = obj.Position(2) + obj.Position(4);
        end

        function [s, j, t, u] = setup( this, subviewerId )
            subview = this.getSubviewer( subviewerId );
            UDDTransInfoMap = this.getTransitionInfo( subviewerId );
            statesOnCurrentView = this.getStatesOnCurrentView( subview );
            junctionsOnCurrentView = this.getJunctionsOnCurrentView( subview );
            transitionsOnCurrentView = this.getTransitionsOnCurrentView ( subview );
            s = statesOnCurrentView;
            j = junctionsOnCurrentView;
            t = transitionsOnCurrentView;
            u = UDDTransInfoMap;
        end

        function tf = isSubviewerTheChart( ~, subviewerId )
            subview = sf('IdToHandle', subviewerId);
            if isa(subview, 'Stateflow.StateTransitionTableChart')
                tf = 1;
            else
                tf = 0;
            end
        end

        function implAlignStatesVertically ( ~, states )
            if length(states) > 1
                firstState = states(1);
                for obj = states(2:end)'
                    if obj.Position(1) ~= firstState.Position(1)
                        % We can only do this if they are different as it
                        % dirties the model
                        obj.Position(1) = firstState.Position(1);
                    end
                end
            end
        end

        function implResizeStatesHorizontally( this, states, junctions, transitions, UDDTransInfoMap )
            rightBoundary = this.findRightMostBoundaryForSetOfStates( states );
            deltaWidth = this.calcChangeInWidth( states );
            moveToRight = max(deltaWidth);
            if (moveToRight > 0)
                this.moveObjsToRight( rightBoundary, states, junctions, transitions, moveToRight, UDDTransInfoMap );
            end
            this.resizeStatesHorizontally( states, deltaWidth );
        end

        function resizeStatesHorizontally( ~, states, deltaWidth )
            widthForAll = 0;
            anyChanged = false;
            for i = 1:length(states)
                if deltaWidth(i) > 0
                    width = states(i).Position(3) + deltaWidth(i);
                    anyChanged = true;
                else
                    width = states(i).Position(3);
                end

                if widthForAll < width
                    widthForAll = width;
                end
            end

            if anyChanged
                for obj = states(:)'
                    obj.Position(3) = widthForAll;
                end
            end

        end

        function rightBoundary = findRightMostBoundaryForSetOfStates(~, states)
            rightBoundary = double(intmin);
            rStates = fliplr(states);
            for obj = rStates(:)'
                assert( isa(obj, 'Stateflow.State') )
                m3i = StateflowDI.Util.getDiagramElement(obj.Id);
                m3iObj = m3i.temporaryObject;
                rb = m3iObj.absPosition(1) + m3iObj.size(1);
                if rb > rightBoundary
                    rightBoundary = rb;
                end
            end
        end

        function [deltaWidth]  = calcChangeInWidth( ~, states )
            temp = zeros(1,length(states));
            for i = 1:length(states)
                assert( isa(states(i), 'Stateflow.State') );
                m3i = StateflowDI.Util.getDiagramElement(states(i).Id);
                m3iObj = m3i.temporaryObject;
                txtNode.Width = m3iObj.labelSize(1);
                repositionWidth = states(i).Position(3);
                if txtNode.Width > states(i).Position(3)
                    repositionWidth = txtNode.Width + 10;
                end
                temp(i) = repositionWidth - states(i).Position(3);
            end
            deltaWidth = temp;
        end

        function objSet = getJunctionsOnCurrentView( ~, subview )
            objSet = subview.find('-isa', 'Stateflow.Junction', 'Subviewer', subview);
        end

        function objSet = getStatesOnCurrentView( ~, subview )
            objSet = subview.find('-isa', 'Stateflow.State', 'Subviewer', subview);
        end


        function objSet = getTransitionsOnCurrentView( ~, subview )
            objSet = subview.find('-isa', 'Stateflow.Transition', 'Subviewer', subview);
        end

        function objSet = getGraphicalObjsOnCurrentView( ~, subview )
            objSet = subview.find('-isa', 'Stateflow.Object', 'Subviewer', subview);
        end

        function subview = getSubviewer( ~, subviewerId )
            subview = sf('IdToHandle', subviewerId);
        end

        function objSet = getHorizontalTransitions( ~, transitions )
            idxSet = arrayfun(@(x) abs(x.sourceEndpoint(2) - x.destinationEndpoint(2)) < 1, transitions);
            objSet = transitions( idxSet );
        end

        function objSet = getVerticalTransitions( ~, transitions )
            idxSet = arrayfun(@(x) abs(x.sourceEndpoint(1) - x.destinationEndpoint(1)) < 1, transitions);
            objSet = transitions( idxSet );
        end

        function sortedObjSet = sortFromLeftToRight(~, objSet)
            pos = zeros(length(objSet),1);
            for i = 1:length(objSet)
                if isa(objSet(i), 'Stateflow.Junction')
                    pos(i) = objSet(i).Position.Center(1) - objSet(i).Position.Radius;
                elseif isa(objSet(i), 'Stateflow.Transition')
                    pos(i) = max( objSet(i).SourceEndpoint(1), objSet(i).DestinationEndpoint(1) );
                else
                    pos(i) = objSet(i).position(1);
                end
            end
            [~,J] = sort(pos);
            sortedObjSet = objSet(J);
        end

        function sortedObjSet = sortTrans(~, objSet, leftOrRight)
            pos = zeros(length(objSet),1);
            if leftOrRight % If true, sort transitions according to left-most edge; right-most edge if false.
                for i = 1:length(objSet)
                    pos(i) = min( objSet(i).SourceEndpoint(1), objSet(i).DestinationEndpoint(1) );
                end
            else
                for i = 1:length(objSet)
                    pos(i) = max( objSet(i).SourceEndpoint(1), objSet(i).DestinationEndpoint(1) );
                end
            end
            [~, J] = sort(pos);
            sortedObjSet = objSet(J);
        end

        function target = sortFromTopToBottom(~, objSet)
            pos = zeros(length(objSet),1);
            for i = 1:length(objSet)
                if isa(objSet(i), 'Stateflow.Junction')
                    pos(i) = objSet(i).Position.Center(2) - objSet(i).Position.Radius;
                elseif isa(objSet(i), 'Stateflow.Transition')
                    pos(i) = max( objSet(i).SourceEndpoint(2), objSet(i).DestinationEndpoint(2) );
                else
                    pos(i) = objSet(i).position(2);
                end
            end
            [~,J] = sort(pos);
            target = objSet(J);
        end

        function implExpandHorizontalTrans( this, states, junctions, transitions, UDDTransInfoMap, subviewerId )
            isSubviewChart = this.isSubviewerTheChart( subviewerId );
            if ~isSubviewChart
                innerTrans = sf('InnerTransitionsOf', subviewerId);
                if length( innerTrans ) == 1
                    innerTransUddH = sf('IdToHandle', innerTrans);
                    if innerTransUddH.DestinationOClock ~= 9
                        innerTransUddH.DestinationOClock = 9;
                    end
                end
            end
            horizontalTrans = this.getHorizontalTransitions( transitions );
            if isempty( horizontalTrans )
                return;
            end

            transIdxSet = arrayfun(@(x) max(x.SourceEndpoint(1), x.DestinationEndpoint(1)) < states(1).Position(1) + 1, horizontalTrans);
            horizontalTransOnLeftSideOfStateZone = horizontalTrans( transIdxSet );
            horizontalTransOnLeftSideOfStateZone = this.sortTrans( horizontalTransOnLeftSideOfStateZone, false );

            transIdxSet = arrayfun(@(x) min(x.SourceEndpoint(1), x.DestinationEndpoint(1)) > states(1).Position(1) - 1, horizontalTrans);
            horizontalTransOnRightSideOfStateZone = horizontalTrans( transIdxSet );
            horizontalTransOnRightSideOfStateZone = this.sortTrans( horizontalTransOnRightSideOfStateZone, false );

            if ~isempty( horizontalTransOnLeftSideOfStateZone )
                for trans = horizontalTransOnLeftSideOfStateZone(:)'
                    if ~isempty( trans.LabelString )
                        labelLength = trans.LabelPosition(3);
                        transLength = abs( trans.SourceEndpoint(1) - trans.DestinationEndpoint(1) );
                        leftXPositionOfVerticalTrans = this.doesLabelOverLapWithVerticalTrans( trans, transitions, true );

                        if labelLength + 15 > transLength
                            leftXPositionOfTrans = min( trans.SourceEndpoint(1), trans.DestinationEndpoint(1) );
                        else
                            leftXPositionOfTrans = [];
                        end

                        if ~isempty( leftXPositionOfTrans ) && ~isempty( leftXPositionOfVerticalTrans )
                            if leftXPositionOfVerticalTrans > leftXPositionOfTrans
                                delta = labelLength + 15 - (max(trans.SourceEndpoint(1), trans.DestinationEndpoint(1)) - leftXPositionOfVerticalTrans);
                                border = leftXPositionOfVerticalTrans;
                            else
                                delta = labelLength + 15 - transLength;
                                border = leftXPositionOfTrans;
                            end
                        elseif ~isempty( leftXPositionOfTrans )
                            delta = labelLength + 15 - transLength;
                            border = leftXPositionOfTrans;
                        elseif ~isempty( leftXPositionOfVerticalTrans )
                            delta = labelLength + 15 - (max(trans.SourceEndpoint(1), trans.DestinationEndpoint(1)) - leftXPositionOfVerticalTrans);
                            border = leftXPositionOfVerticalTrans;
                        else
                            delta = 0;
                            border = [];
                        end

                        if delta > 0
                            this.moveObjsToRight( border, states, junctions, transitions, delta, UDDTransInfoMap );
                        end
                    end
                end
            end
            if ~isempty( horizontalTransOnRightSideOfStateZone )
                for trans = horizontalTransOnRightSideOfStateZone(:)'
                    if ~isempty( trans.LabelString )
                        labelLength = trans.LabelPosition(3);
                        transLength = abs( trans.SourceEndpoint(1) - trans.DestinationEndpoint(1) );
                        leftXPositionOfVerticalTrans = this.doesLabelOverLapWithVerticalTrans( trans, transitions, false );
                        if labelLength + 15 > transLength
                            leftXPositionOfTrans = max( trans.SourceEndpoint(1), trans.DestinationEndpoint(1) );
                        else
                            leftXPositionOfTrans = [];
                        end
                        if ~isempty( leftXPositionOfTrans ) && ~isempty( leftXPositionOfVerticalTrans )
                            if leftXPositionOfVerticalTrans < leftXPositionOfTrans
                                delta = labelLength + 15 - (leftXPositionOfVerticalTrans - min(trans.SourceEndpoint(1), trans.DestinationEndpoint(1)));
                                border = leftXPositionOfVerticalTrans;
                            else
                                delta = labelLength + 15 - transLength;
                                border = leftXPositionOfTrans;
                            end
                        elseif ~isempty( leftXPositionOfTrans )
                            delta = labelLength + 15 - transLength;
                            border = leftXPositionOfTrans;
                        elseif ~isempty( leftXPositionOfVerticalTrans )
                            delta = labelLength + 15 - (leftXPositionOfVerticalTrans - min(trans.SourceEndpoint(1), trans.DestinationEndpoint(1)));
                            border = leftXPositionOfVerticalTrans;
                        else
                            delta = 0;
                            border = [];
                        end
                        if delta > 0
                            this.moveObjsToRight( border, states, junctions, transitions, delta, UDDTransInfoMap );
                        end
                    end
                end
            end
        end

        function boundary = doesLabelOverLapWithVerticalTrans( this, trans, transitions, leftOrRight )
            verticalTrans = this.getVerticalTransitions( transitions );
            if leftOrRight % If true, calculate the space for transition label on the lhs of states, calculate for rhs if false
                leftBoundary = max( trans.SourceEndpoint(1), trans.DestinationEndpoint(1) ) - trans.LabelPosition(3) - 4;
                rightBoundary = max( trans.SourceEndpoint(1), trans.DestinationEndpoint(1) );
            else
                leftBoundary = min( trans.SourceEndpoint(1), trans.DestinationEndpoint(1) );
                rightBoundary = min( trans.SourceEndpoint(1), trans.DestinationEndpoint(1) ) + trans.LabelPosition(3) + 4;
            end
            transIdxSet = arrayfun(@(x) x.SourceEndpoint(1) > leftBoundary  && ...
                                   x.SourceEndpoint(1) < rightBoundary && ...
                                   min(x.SourceEndpoint(2), x.DestinationEndpoint(2)) < trans.SourceEndpoint(2) && ...
                                   max(x.SourceEndpoint(2), x.DestinationEndpoint(2)) > trans.SourceEndpoint(2), verticalTrans);
            verticalTransOverlapWithLabel = verticalTrans( transIdxSet );
            verticalTransOverlapWithLabel = this.sortTrans( verticalTransOverlapWithLabel, false );
            if ~isempty( verticalTransOverlapWithLabel )
                if leftOrRight % true for left, false for right.
                    boundary = verticalTransOverlapWithLabel(end).SourceEndpoint(1);
                else
                    boundary = verticalTransOverlapWithLabel(1).SourceEndpoint(1);
                end
            else
                boundary = [];
            end
        end

        % Not use this function at the moment.
        % For STT, the inner transitions will always from left to right.
        % Therefore, if we want to push objects to the left, we need to put
        % a dummy junction at the source of the inner transitions. So the
        % subviewer will be extended automatically if objects are pushed to
        % the left.
        function moveObjsToLeft( this, border, junctions, transitions, delta, UDDTransInfoMap, subviewerId )
            subview = this.getSubviewer( subviewerId );
            innerTrans = sf('InnerTransitionsOf', subviewerId);
            if length( innerTrans ) == 1
                innerTransUddH = sf('IdToHandle', innerTrans);
                transitions = setdiff( transitions, innerTransUddH );
                dummyJunction = Stateflow.Junction( subview );
                if ~isempty(innerTransUddH.LabelString)
                    reserve = innerTransUddH.LabelPosition(3) + 15;
                else
                    reserve = 30;
                end
                rhsOfInnerTrans = max(innerTransUddH.SourceEndpoint(1), innerTransUddH.DestinationEndpoint(1));
                dummyJunction.Position.Center = [rhsOfInnerTrans - reserve innerTransUddH.SourceEndpoint(2)];
                dummyJunction.Position.Center(1) = dummyJunction.Position.Center(1) - delta;
            end


            junctionIdxSet = arrayfun(@(x) x.Position.Center(1) < border + 8, junctions);
            junctionsNeedToMove = junctions( junctionIdxSet )';
            tranIdxSet = arrayfun(@(x) abs(x.SourceEndpoint(1) - x.DestinationEndpoint(1)) < 1 && x.SourceEndpoint(1) < border, transitions);
            transNeedToMove = transitions( tranIdxSet )';
            if ~isempty( junctionsNeedToMove )
                junctionsNeedToMove = this.sortFromLeftToRight( junctionsNeedToMove );
                for obj = junctionsNeedToMove(:)'
                    obj.Position.Center(1) = obj.Position.Center(1) - delta;
                end
            end
            if ~isempty( transNeedToMove )
                for trans = transNeedToMove(:)'
                    trans.SourceOClock = UDDTransInfoMap(trans.Id).SourceOClock;
                    trans.DestinationOClock = UDDTransInfoMap(trans.Id).DestinationOClock;
                end
            end
            if length( innerTrans ) == 1
                dummyJunction.delete;
            end
        end

        function moveObjsToRight( this, boundaryLine, states, junctions, transitions, delta, UDDTransInfoMap )
            stateIdxSet = arrayfun(@(x) x.Position(1) > boundaryLine - 1, states);
            statesNeedToMove = states( stateIdxSet )';
            junctionIdxSet = arrayfun(@(x) x.Position.Center(1) > boundaryLine - 1, junctions);
            junctionsNeedToMove = junctions( junctionIdxSet )';
            tranIdxSet = arrayfun(@(x) abs(x.SourceEndpoint(1) - x.DestinationEndpoint(1)) < 1 && x.SourceEndpoint(1) > boundaryLine, transitions);
            transNeedToMove = transitions( tranIdxSet )';
            objsNeedToMove = [statesNeedToMove, junctionsNeedToMove];
            if ~isempty( objsNeedToMove )
                objsNeedToMove = this.sortFromLeftToRight( objsNeedToMove );
                rSortedJuncsNeedToMove = fliplr( objsNeedToMove' );
                if abs(delta) > .001
                    for obj = rSortedJuncsNeedToMove(:)'
                    
                        if isa(obj, 'Stateflow.Junction')
                            obj.Position.Center(1) = obj.Position.Center(1) + delta;
                        else
                            obj.Position(1) = obj.Position(1) + delta;
                        end
                    end
                end
            end

            if ~isempty( transNeedToMove )
                for trans = transNeedToMove(:)'
                    if trans.SourceOClock ~= UDDTransInfoMap(trans.Id).SourceOClock || ...
                            trans.DestinationOClock ~= UDDTransInfoMap(trans.Id).DestinationOClock
                    trans.SourceOClock = UDDTransInfoMap(trans.Id).SourceOClock;
                    trans.DestinationOClock = UDDTransInfoMap(trans.Id).DestinationOClock;
                    end
                end
            end
        end

        function mapObj = getTransitionInfo( this, subviewerId )
            subview = this.getSubviewer( subviewerId );
            setOfTransitions = subview.find('-isa', 'Stateflow.Transition', 'Subviewer', subview);
            if isempty( setOfTransitions )
                mapObj = [];
                return;
            end
            setOfTransitions = num2cell( setOfTransitions )';
            idKeys = double(cellfun(@(x) x.Id, setOfTransitions))';
            SourceOClock = cellfun(@(x) x.SourceOClock, setOfTransitions, 'UniformOutPut', false)';
            DestinationOClock = cellfun(@(x) x.DestinationOClock, setOfTransitions, 'UniformOutPut', false)';
            SourceEndpoint = cellfun(@(x) x.SourceEndpoint, setOfTransitions, 'UniformOutPut', false)';
            MidPoint = cellfun(@(x) x.MidPoint, setOfTransitions, 'UniformOutPut', false)';
            DestinationEndpoint = cellfun(@(x) x.DestinationEndpoint, setOfTransitions, 'UniformOutPut', false)';

            transitionInfoStruct = struct('SourceOClock'        ,  SourceOClock, ...
                                          'DestinationOClock'   ,  DestinationOClock, ...
                                          'SourceEndpoint'      ,  SourceEndpoint , ...
                                          'MidPoint'            ,  MidPoint , ...
                                          'DestinationEndpoint' ,  DestinationEndpoint );


            if length( idKeys ) == 1
                mapObj = containers.Map( idKeys, transitionInfoStruct );
            else
                mapObj = containers.Map( idKeys, arrayfun(@(x) {x}, transitionInfoStruct) );
            end
        end
    end

    methods (Static)
        function beautifyCurrentSubviewer( subviewerId )
            obj = Stateflow.Tools.diagramLayoutForSTT( subviewerId );
            obj.construct();
        end

        function beautifyEachSubviewerForChart( chartSubviewerId )
            Stateflow.Tools.diagramLayoutForSTT.beautifyCurrentSubviewer( chartSubviewerId );
            subview = sf('IdToHandle',chartSubviewerId);
            stateUddHs = subview.find('-isa', 'Stateflow.State', 'subviewer', subview, 'IsSubchart', 1);
            if ~isempty( stateUddHs )
                for state = stateUddHs(:)'
                    children = state.getChildren;
                    if ~isempty( children )
                        chartSubviewerId = children(1).Subviewer.Id;
                        Stateflow.Tools.diagramLayoutForSTT.beautifyEachSubviewerForChart( chartSubviewerId );
                    end
                end
            end
        end

    end
end
