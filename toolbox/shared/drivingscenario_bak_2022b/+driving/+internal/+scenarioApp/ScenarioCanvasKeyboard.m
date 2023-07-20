classdef ScenarioCanvasKeyboard<matlabshared.application.ComponentKeyboard

    methods
        function escape(this)
            canvas=this.Component;

            if strcmp(canvas.InteractionMode,'none')
                canvas.CurrentSpecification=[];
                canvas.Application.ActorProperties.SpecificationIndex=1;
                update(canvas.Application.ActorProperties);
            else
                exitInteractionMode(canvas);
                setStatus(canvas.Application,'');
            end
        end

        function control_a(this)
            canvas=this.Component;
            if strcmp(canvas.InteractionMode,'none')
                allActors=canvas.Application.ActorSpecifications(1:end);
                canvas.Application.ActorProperties.SpecificationIndex=[allActors.ActorID];
                canvas.CurrentSpecification=allActors;
                drawnow;
                focusOnComponent(canvas);
            end
        end

        function control_r(this)
            canvas=this.Component;
            if strcmp(canvas.InteractionMode,'addActorWaypoints')

                setReverseMotion(canvas.Application.ActorProperties,1);
                tooltip=getCursorText(canvas);
                tooltip=tooltip+" "+getString(message('driving:scenarioApp:ReverseTooltip'));
                setTooltipString(canvas,tooltip);
                return;
            elseif canAddWaypoints(canvas)
                canvas.addReverseWaypointsCallback;
                return;
            end
        end

        function control_f(this)
            canvas=this.Component;
            if strcmp(canvas.InteractionMode,'addActorWaypoints')
                setReverseMotion(canvas.Application.ActorProperties,0);
                tooltip=getCursorText(canvas);
                tooltip=tooltip+" "+getString(message('driving:scenarioApp:ForwardTooltip'));
                setTooltipString(canvas,tooltip);
                return;
            elseif canAddWaypoints(canvas)
                canvas.addWaypointsCallback;
                return;
            end
        end

        function enter(this)
            canvas=this.Component;
            commitRoadEdgeBarrier(canvas);
            commitWaypoints(canvas);
            setStatus(canvas.Application,'');
        end

        function return_(this)
            enter(this);
        end

        function equal(this)
            canvas=this.Component;
            if~contains(canvas.InteractionMode,"drag")
                zoomIn(canvas);
            end
        end
        function plus(this)
            equal(this);
        end
        function add(this)
            equal(this);
        end

        function hyphen(this)
            canvas=this.Component;
            if~contains(canvas.InteractionMode,"drag")
                zoomOut(canvas);
            end
        end
        function minus(this)
            hyphen(this);
        end
        function subtract(this)
            hyphen(this);
        end

        function delete_(this)
            canvas=this.Component;
            app=canvas.Application;
            if strcmp(canvas.InteractionMode,'none')&&isStopped(app.Simulator)
                spec=canvas.CurrentSpecification;
                if isa(spec,'driving.internal.scenarioApp.road.Specification')
                    indx=find(spec==app.RoadSpecifications,1);
                    if~isempty(indx)
                        applyEdit(app,driving.internal.scenarioApp.undoredo.DeleteRoad(app,indx));
                    end
                elseif isa(spec,'driving.internal.scenarioApp.ActorSpecification')
                    indx=[spec.ActorID];
                    if~isempty(indx)
                        applyEdit(app,driving.internal.scenarioApp.undoredo.DeleteActor(app,indx));
                    end
                elseif isa(spec,'driving.internal.scenarioApp.BarrierSpecification')
                    indx=find(spec==app.BarrierSpecifications,1);
                    if~isempty(indx)
                        applyEdit(app,driving.internal.scenarioApp.undoredo.DeleteBarrier(app,indx));
                    end
                end
            end
        end

        function leftarrow(this)
            arrowKeyHelper(this,'leftarrow');
        end

        function rightarrow(this)
            arrowKeyHelper(this,'rightarrow');
        end

        function uparrow(this)
            arrowKeyHelper(this,'uparrow');
        end

        function downarrow(this)
            arrowKeyHelper(this,'downarrow');
        end

        function control_leftarrow(this)
            arrowKeyHelper(this,'leftarrow',{'control'})
        end

        function control_rightarrow(this)
            arrowKeyHelper(this,'rightarrow',{'control'})
        end

        function control_uparrow(this)
            arrowKeyHelper(this,'uparrow',{'control'})
        end

        function control_downarrow(this)
            arrowKeyHelper(this,'downarrow',{'control'})
        end

        function alt_control_leftarrow(this)
            arrowKeyHelper(this,'leftarrow',{'alt','control'})
        end

        function alt_control_rightarrow(this)
            arrowKeyHelper(this,'rightarrow',{'alt','control'})
        end

        function alt_control_uparrow(this)
            arrowKeyHelper(this,'uparrow',{'alt','control'})
        end

        function alt_control_downarrow(this)
            arrowKeyHelper(this,'downarrow',{'alt','control'})
        end

        function alt_leftarrow(this)
            arrowKeyHelper(this,'leftarrow',{'alt'});
        end

        function alt_rightarrow(this)
            arrowKeyHelper(this,'rightarrow',{'alt'});
        end

        function alt_uparrow(this)
            arrowKeyHelper(this,'uparrow',{'alt'});
        end

        function alt_downarrow(this)
            arrowKeyHelper(this,'downarrow',{'alt'});
        end
    end

    methods(Access=protected)
        function arrowKeyHelper(this,key,mods)
            if nargin<3
                mods={};
            end
            canvas=this.Component;
            spec=canvas.CurrentSpecification;

            if isempty(spec)
                switch key
                case 'leftarrow'
                    dir='west';
                case 'rightarrow'
                    dir='east';
                case 'uparrow'
                    dir='north';
                case 'downarrow'
                    dir='south';
                otherwise
                    return;
                end
                pan(canvas,dir);
                return;
            end
            app=canvas.Application;
            pref=driving.internal.scenarioApp.Preferences.Instance;

            isRotate=any(strcmp(mods,'alt'));
            isActor=isa(spec,'driving.internal.scenarioApp.ActorSpecification');

            if isRotate

                if~isActor
                    return;
                end
                if any(strcmp(mods,'control'))
                    dist=pref.MajorArrowRotateAngle;
                else
                    dist=pref.MinorArrowRotateAngle;
                end
            else
                if strcmp(mods,'control')
                    dist=pref.MinorArrowMoveDistance;
                else
                    dist=pref.MajorArrowMoveDistance;
                end
            end
            xShift=0;
            yShift=0;
            switch key
            case 'rightarrow'
                if isRotate
                    newYaw=[spec.Yaw]-dist;
                end
                yShift=-dist;
            case 'leftarrow'
                if isRotate
                    newYaw=[spec.Yaw]+dist;
                end
                yShift=dist;
            case 'downarrow'
                if isRotate
                    newYaw=zeros(numel(spec),1)';
                    newYaw(1:end)=180;
                end
                xShift=-dist;
            case 'uparrow'
                if isRotate
                    newYaw=zeros(numel(spec),1)';
                    newYaw(1:end)=0;
                end
                xShift=dist;
            end

            if isRotate
                for iSpec=1:numel(spec)
                    nYaw{iSpec}=newYaw(iSpec);
                    if isempty(spec(iSpec).Waypoints)
                        nWYaw{iSpec}=newYaw(iSpec);
                    else
                        if isempty(spec(iSpec).WaypointsYaw)||all(isnan(spec(iSpec).WaypointsYaw))
                            waypointsYaw=nan(numel(spec(iSpec).pWaypointsYaw),1);
                            waypointsYaw(1)=newYaw(iSpec);
                            nWYaw{iSpec}=waypointsYaw;
                        else
                            nWYaw{iSpec}=[newYaw(iSpec);spec(iSpec).WaypointsYaw(2:end)];
                        end
                    end
                end
                edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                app,spec,[{'Yaw'},{'WaypointsYaw'}],[nYaw;nWYaw]');
            elseif isActor
                for iSpec=1:numel(spec)
                    nPos{iSpec}=spec(iSpec).Position+[xShift,yShift,0];
                    value=spec(iSpec).Waypoints;
                    if isempty(value)
                        nWPos{iSpec}=[];
                    else
                        nWPos{iSpec}=value+[xShift,yShift,0];
                    end
                end
                edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                app,spec,[{'Position'},{'Waypoints'}],[nPos;nWPos]');
            else
                pvPairs=getPvPairsForDrag(spec,[xShift,yShift,0]);
                if numel(pvPairs)==2
                    edit=driving.internal.scenarioApp.undoredo.SetRoadProperty(app,spec,pvPairs{:});
                else
                    params=pvPairs(1:2:end);
                    values=pvPairs(2:2:end);
                    edit=driving.internal.scenarioApp.undoredo.SetMultipleRoadProperties(app,spec,params,values);
                end
            end

            applyEdit(app,edit);
        end
    end
end
