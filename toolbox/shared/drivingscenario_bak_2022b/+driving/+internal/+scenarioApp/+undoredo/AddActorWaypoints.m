classdef AddActorWaypoints<driving.internal.scenarioApp.undoredo.Edit

    properties(SetAccess=protected)
Actor
NewWaypoints
NewSpeed
OldWaypoints
OldSpeed
NewWaitTime
OldWaitTime
NewWaypointsYaw
OldWaypointsYaw
NewpWaypointsYaw
OldpWaypointsYaw
OldYaw
    end

    methods
        function this=AddActorWaypoints(hDesigner,actor,waypoints)
            this.Application=hDesigner;
            this.Actor=actor;

            if size(waypoints,2)==6
                pWaypointsYaw=waypoints(:,6);
                waypointsYaw=actor.WaypointsYaw;
                if numel(waypointsYaw)<numel(pWaypointsYaw)
                    waypointsYaw=[waypointsYaw;NaN(numel(pWaypointsYaw)-numel(waypointsYaw),1)];
                elseif numel(waypointsYaw)>numel(pWaypointsYaw)
                    waypointsYaw(numel(pWaypointsYaw)+1:end)=[];
                end
                if isempty(pWaypointsYaw)
                    pWaypointsYaw=NaN;
                end
                waypoints(:,6)=[];
            else
                pWaypointsYaw=[];
                waypointsYaw=[];
            end

            if size(waypoints,2)>=5
                waitTime=waypoints(:,5);
                if isempty(waitTime)
                    waitTime=0;
                end
                waypoints(:,5)=[];
            else
                waitTime=[];
            end
            if size(waypoints,2)>=4
                speed=waypoints(:,4);
                if isempty(speed)
                    speed=actor.Speed(1);
                end
                waypoints(:,4)=[];
            else
                if isempty(actor.Speed)

                    speed=hDesigner.ClassSpecifications.getProperty(actor.ClassID,'Speed');
                else
                    speed=actor.Speed(1);
                end
            end


            if isscalar(speed)&&speed==0
                speed=driving.scenario.Path.DefaultSpeed;
            end
            this.NewWaypoints=waypoints;
            this.NewSpeed=speed;
            this.OldWaypoints=actor.Waypoints;
            this.OldSpeed=actor.Speed;
            this.NewWaitTime=waitTime;
            this.OldWaitTime=actor.WaitTime;
            this.NewWaypointsYaw=waypointsYaw;
            this.OldWaypointsYaw=actor.WaypointsYaw;
            this.NewpWaypointsYaw=pWaypointsYaw;
            this.OldpWaypointsYaw=actor.pWaypointsYaw;
            this.OldYaw=actor.Yaw;
        end

        function execute(this)
            actorSpec=this.Actor;
            waypoints=this.NewWaypoints;
            actorSpec.Waypoints=waypoints;
            newSpeed=this.NewSpeed;
            speedSet=false;
            if isempty(newSpeed)


                speed=actorSpec.Speed;
                if~isscalar(speed)
                    nWaypoints=size(waypoints,1);
                    nSpeeds=numel(speed);
                    if nWaypoints>nSpeeds
                        speed(end+1:nWaypoints)=speed(end);
                        actorSpec.Speed=speed;
                        speedSet=true;
                    elseif nWaypoints<nSpeeds
                        speed(nWaypoints+1:end)=[];
                        actorSpec.Speed=speed;
                        speedSet=true;
                    end
                end
            else
                actorSpec.Speed=newSpeed;
                speedSet=true;
            end
            waitTimeSet=false;
            newWaitTime=this.NewWaitTime;
            actorSpec.WaitTime=newWaitTime;
            if~isempty(newWaitTime)
                waitTimeSet=true;
            end
            pWaypointsYawSet=false;
            newpWaypointsYaw=this.NewpWaypointsYaw;
            actorSpec.pWaypointsYaw=newpWaypointsYaw;

            actorSpec.WaypointsYaw=this.NewWaypointsYaw;
            if~isempty(newpWaypointsYaw)
                pWaypointsYawSet=true;
            end
            updateActorInScenario(this.Application,this.Actor.ActorID);
            if~isempty(actorSpec.pWaypointsYaw)
                if actorSpec.Speed(1)<0
                    actorSpec.Yaw=actorSpec.pWaypointsYaw(1)-180;
                else
                    actorSpec.Yaw=actorSpec.pWaypointsYaw(1);
                end
            end
            if speedSet&&~waitTimeSet
                if pWaypointsYawSet
                    props={'Waypoints','Speed','pWaypointsYaw','WaypointsYaw','Yaw'};
                else
                    props={'Waypoints','Speed','Yaw'};
                end
            elseif speedSet&&waitTimeSet
                if pWaypointsYawSet
                    props={'Waypoints','Speed','WaitTime','pWaypointsYaw','WaypointsYaw','Yaw'};
                else
                    props={'Waypoints','Speed','WaitTime','Yaw'};
                end
            else
                if pWaypointsYawSet
                    props={'Waypoints','pWaypointsYaw','WaypointsYaw','Yaw'};
                else
                    props={'Waypoints','Yaw'};
                end
            end
            notify(this.Application,'ActorPropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(actorSpec,props));
        end

        function undo(this)

            actorSpec=this.Actor;
            actorSpec.Waypoints=this.OldWaypoints;
            actorSpec.Speed=this.OldSpeed;
            actorSpec.WaitTime=this.OldWaitTime;
            actorSpec.WaypointsYaw=this.OldWaypointsYaw;
            actorSpec.pWaypointsYaw=this.OldpWaypointsYaw;
            actorSpec.Yaw=this.OldYaw;
            if isequal(this.OldSpeed,this.NewSpeed)
                if isequal(this.OldpWaypointsYaw,this.NewpWaypointsYaw)
                    props='Waypoints';
                else
                    props={'Waypoints','pWaypointsYaw','WaypointsYaw'};
                end
            else
                if isequal(this.OldpWaypointsYaw,this.NewpWaypointsYaw)
                    props={'Waypoints','Speed','WaitTime'};
                else
                    props={'Waypoints','Speed','WaitTime','pWaypointsYaw','WaypointsYaw'};
                end
            end
            updateActorInScenario(this.Application,this.Actor.ActorID);
            notify(this.Application,'ActorPropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(actorSpec,props));
        end
    end
end


