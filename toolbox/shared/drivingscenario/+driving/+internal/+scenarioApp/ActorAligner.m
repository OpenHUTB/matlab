classdef ActorAligner<handle
    properties
Application
    end


    methods
        function this=ActorAligner(hApplication)
            this.Application=hApplication;
        end

        function alignLeft(this,ind,first)
            sel_actors=this.Application.Scenario.Actors;
            actorSpecs=this.Application.ActorSpecifications;

            left=zeros(length(ind),1);
            for i=1:length(ind)
                vertices=sel_actors(ind(i)).scenarioFacesCuboid;
                left(i)=max(vertices(:,2));
                if ind(i)==first
                    left_follower=left(i);
                end
            end



            newPosition=zeros(length(ind),3);
            oldPosition=zeros(length(ind),3);

            for i=1:length(ind)
                actor=sel_actors(ind(i));
                delta=1;
                oldPosition(i,:)=actor.Position;

                while abs(delta)>.01
                    Position=actor.Position;
                    delta=left_follower-left(i);
                    Position=Position+[0,delta,0];
                    if~isempty(this.Application.ActorSpecifications(ind(i)).Waypoints)
                        oldWaypoints=actorSpecs(ind(i)).Waypoints;
                        oldWaypoints(1,:)=Position;
                        trajectory(actor,oldWaypoints)
                        vertices_follower=getVertices(actor);
                        left(i)=max(vertices_follower(2,:));
                        delta=left_follower-left(i);
                    else
                        delta=0;

                    end

                    newPosition(i,:)=Position;

                end
            end

            e=driving.internal.scenarioApp.undoredo.SetActorPosition(this.Application,this.Application.ActorSpecifications(ind),newPosition,oldPosition);
            applyEdit(this.Application,e);

        end

        function alignRight(this,ind,first)
            sel_actors=this.Application.Scenario.Actors;
            actorSpecs=this.Application.ActorSpecifications;

            right=zeros(length(ind),1);
            for i=1:length(ind)

                vertices=sel_actors(ind(i)).scenarioFacesCuboid;
                right(i)=min(vertices(:,2));
                if ind(i)==first
                    right_follower=right(i);
                end
            end

            newPosition=zeros(length(ind),3);
            oldPosition=zeros(length(ind),3);

            for i=1:length(ind)
                actor=sel_actors(ind(i));
                oldPosition(i,:)=actor.Position;

                delta=1;
                while abs(delta)>.005
                    Position=actor.Position;
                    delta=right_follower-right(i);
                    Position=Position+[0,delta,0];

                    if~isempty(this.Application.ActorSpecifications(ind(i)).Waypoints)
                        oldWaypoints=actorSpecs(ind(i)).Waypoints;
                        oldWaypoints(1,:)=Position;
                        trajectory(actor,oldWaypoints)
                        vertices_follower=getVertices(actor);
                        right(i)=min(vertices_follower(2,:));
                        delta=right_follower-right(i);
                    else
                        delta=0;

                    end

                    newPosition(i,:)=Position;
                end

            end
            e=driving.internal.scenarioApp.undoredo.SetActorPosition(this.Application,this.Application.ActorSpecifications(ind),newPosition,oldPosition);
            applyEdit(this.Application,e);

        end

        function alignTop(this,ind,first)
            sel_actors=this.Application.Scenario.Actors;
            actorSpecs=this.Application.ActorSpecifications;

            top=zeros(length(ind),1);
            for i=1:length(ind)
                vertices=sel_actors(ind(i)).scenarioFacesCuboid;
                top(i)=max(vertices(:,1));
                if ind(i)==first
                    top_follower=top(i);
                end
            end

            newPosition=zeros(length(ind),3);
            oldPosition=zeros(length(ind),3);

            for i=1:length(ind)
                actor=sel_actors(ind(i));
                oldPosition(i,:)=actor.Position;

                delta=1;
                while abs(delta)>.005
                    Position=actor.Position;
                    delta=top_follower-top(i);
                    Position=Position+[delta,0,0];

                    if~isempty(this.Application.ActorSpecifications(ind(i)).Waypoints)
                        oldWaypoints=actorSpecs(ind(i)).Waypoints;
                        oldWaypoints(1,:)=Position;
                        trajectory(actor,oldWaypoints)
                        vertices_follower=getVertices(actor);
                        top(i)=max(vertices_follower(1,:));
                        delta=top_follower-top(i);
                    else
                        delta=0;

                    end

                    newPosition(i,:)=Position;
                end

            end
            e=driving.internal.scenarioApp.undoredo.SetActorPosition(this.Application,this.Application.ActorSpecifications(ind),newPosition,oldPosition);
            applyEdit(this.Application,e);
        end


        function alignBottom(this,ind,first)
            sel_actors=this.Application.Scenario.Actors;
            actorSpecs=this.Application.ActorSpecifications;

            bottom=zeros(length(ind),1);
            for i=1:length(ind)
                vertices=sel_actors(ind(i)).scenarioFacesCuboid;
                bottom(i)=min(vertices(:,1));
                if ind(i)==first
                    bottom_follower=bottom(i);
                end
            end


            newPosition=zeros(length(ind),3);
            oldPosition=zeros(length(ind),3);

            for i=1:length(ind)
                actor=sel_actors(ind(i));
                oldPosition(i,:)=actor.Position;

                delta=1;
                while abs(delta)>.005
                    Position=actor.Position;
                    delta=bottom_follower-bottom(i);
                    Position=Position+[delta,0,0];
                    if~isempty(this.Application.ActorSpecifications(ind(i)).Waypoints)
                        oldWaypoints=actorSpecs(ind(i)).Waypoints;
                        oldWaypoints(1,:)=Position;
                        trajectory(actor,oldWaypoints)
                        vertices_follower=getVertices(actor);
                        bottom(i)=min(vertices_follower(1,:));
                        delta=bottom_follower-bottom(i);
                    else
                        delta=0;

                    end

                    newPosition(i,:)=Position;
                end

            end
            e=driving.internal.scenarioApp.undoredo.SetActorPosition(this.Application,this.Application.ActorSpecifications(ind),newPosition,oldPosition);
            applyEdit(this.Application,e);
        end


        function alignVertMiddle(this,ind,first)
            sel_actors=this.Application.Scenario.Actors;
            actorSpecs=this.Application.ActorSpecifications;

            center=zeros(length(ind),1);

            for i=1:length(ind)
                centroid=mean(sel_actors(ind(i)).scenarioFacesCuboid);
                center(i)=centroid(1);
                if ind(i)==first
                    center_follower=center(i);
                end
            end

            newPosition=zeros(length(ind),3);
            oldPosition=zeros(length(ind),3);
            for i=1:length(ind)
                actor=sel_actors(ind(i));
                oldPosition(i,:)=actor.Position;

                delta=1;
                while abs(delta)>.005
                    Position=actor.Position;
                    delta=center_follower-center(i);
                    Position=Position+[delta,0,0];
                    if~isempty(this.Application.ActorSpecifications(ind(i)).Waypoints)
                        oldWaypoints=actorSpecs(ind(i)).Waypoints;
                        oldWaypoints(1,:)=Position;
                        trajectory(actor,oldWaypoints)
                        vertices_follower=getVertices(actor);
                        center(i)=mean(vertices_follower(1,:));
                        delta=center_follower-center(i);
                    else
                        delta=0;

                    end

                    newPosition(i,:)=Position;
                end

            end
            e=driving.internal.scenarioApp.undoredo.SetActorPosition(this.Application,this.Application.ActorSpecifications(ind),newPosition,oldPosition);
            applyEdit(this.Application,e);
        end

        function alignHorizMiddle(this,ind,first)
            sel_actors=this.Application.Scenario.Actors;
            actorSpecs=this.Application.ActorSpecifications;

            center=zeros(length(ind),1);

            for i=1:length(ind)
                centroid=mean(sel_actors(ind(i)).scenarioFacesCuboid);
                center(i)=centroid(2);
                if ind(i)==first
                    center_follower=center(i);
                end
            end

            newPosition=zeros(length(ind),3);
            oldPosition=zeros(length(ind),3);
            for i=1:length(ind)
                actor=sel_actors(ind(i));
                oldPosition(i,:)=actor.Position;

                delta=1;
                while abs(delta)>.005
                    Position=actor.Position;
                    delta=center_follower-center(i);
                    Position=Position+[0,delta,0];
                    if~isempty(this.Application.ActorSpecifications(ind(i)).Waypoints)
                        oldWaypoints=actorSpecs(ind(i)).Waypoints;
                        oldWaypoints(1,:)=Position;
                        trajectory(actor,oldWaypoints)
                        vertices_follower=getVertices(actor);
                        center(i)=mean(vertices_follower(2,:));
                        delta=center_follower-center(i);
                    else
                        delta=0;

                    end

                    newPosition(i,:)=Position;
                end

            end
            e=driving.internal.scenarioApp.undoredo.SetActorPosition(this.Application,this.Application.ActorSpecifications(ind),newPosition,oldPosition);
            applyEdit(this.Application,e);
        end

        function distributeHoriz(this,ind)
            sel_actors=this.Application.Scenario.Actors;
            actorSpecs=this.Application.ActorSpecifications;

            pos=zeros(length(ind),2);
            for i=1:length(ind)
                center=mean(sel_actors(ind(i)).scenarioFacesCuboid);
                pos(i,2)=center(2);
                pos(i,1)=i;
            end

            dist=max(pos(:,2))-min(pos(:,2));
            dist_btwn=dist/(length(ind)-1);
            [~,idx]=sort(pos(:,2));
            pos=pos(idx,:);

            start=this.Application.ActorSpecifications(ind(pos(1,1))).Position(2);
            c2p_start=this.Application.ActorSpecifications(ind(pos(1,1))).Position(2)-pos(1,2);

            newPosition=zeros(length(ind),3);
            oldPosition=zeros(length(ind),3);
            for i=1:length(pos)
                actor=sel_actors(ind(pos(i,1)));
                oldPosition(i,:)=actor.Position;
                Position=oldPosition(i,:);

                delta=1;
                while abs(delta)>.005

                    c2p=actor.Position(2)-pos(i,2);

                    center_goal=start-c2p_start+dist_btwn*(i-1);
                    Position(2)=start+dist_btwn*(i-1)+c2p-c2p_start;

                    if~isempty(this.Application.ActorSpecifications(ind(pos(i,1))).Waypoints)

                        oldWaypoints=actorSpecs(ind(pos(i,1))).Waypoints;
                        oldWaypoints(1,:)=Position;
                        trajectory(actor,oldWaypoints)
                        vertices_follower=getVertices(actor);
                        pos(i,2)=mean(vertices_follower(2,:));
                        delta=center_goal-pos(i,2);
                    else
                        delta=0;
                    end
                    newPosition(i,:)=Position;
                end
            end
            e=driving.internal.scenarioApp.undoredo.SetActorPosition(this.Application,this.Application.ActorSpecifications(ind(pos(:,1))),newPosition,oldPosition);
            applyEdit(this.Application,e);
        end

        function distributeVert(this,ind)
            sel_actors=this.Application.Scenario.Actors;
            actorSpecs=this.Application.ActorSpecifications;

            pos=zeros(length(ind),2);
            for i=1:length(ind)
                center=mean(sel_actors(ind(i)).scenarioFacesCuboid);
                pos(i,2)=center(1);
                pos(i,1)=i;
            end

            dist=max(pos(:,2))-min(pos(:,2));
            dist_btwn=dist/(length(ind)-1);
            [~,idx]=sort(pos(:,2));
            pos=pos(idx,:);

            start=this.Application.ActorSpecifications(ind(pos(1,1))).Position(1);
            c2p_start=this.Application.ActorSpecifications(ind(pos(1,1))).Position(1)-pos(1,2);

            newPosition=zeros(length(ind),3);
            oldPosition=zeros(length(ind),3);

            for i=1:length(pos)
                actor=sel_actors(ind(pos(i,1)));
                oldPosition(i,:)=actor.Position;
                Position=oldPosition(i,:);

                delta=1;
                while abs(delta)>.005

                    c2p=actor.Position(1)-pos(i,2);

                    center_goal=start-c2p_start+dist_btwn*(i-1);
                    Position(1)=start+dist_btwn*(i-1)+c2p-c2p_start;

                    if~isempty(this.Application.ActorSpecifications(ind(pos(i,1))).Waypoints)

                        oldWaypoints=actorSpecs(ind(pos(i,1))).Waypoints;
                        oldWaypoints(1,:)=Position;
                        trajectory(actor,oldWaypoints)
                        Position=actor.Position;
                        Width=actor.Width;
                        RearOverhang=actor.RearOverhang;
                        Length=actor.Length;
                        Roll=actor.Roll*(pi/180);
                        Pitch=actor.Pitch*(pi/180);
                        Yaw=actor.Yaw*(pi/180);
                        rotm=eul2rotm([Roll,Pitch,Yaw],'XYZ');

                        vertices_follower=repmat(Position,4,1)'+rotm*[Length-RearOverhang,0.5*Width,0;Length-RearOverhang,-0.5*Width,0;-RearOverhang,-0.5*Width,0;-RearOverhang,0.5*Width,0]';
                        pos(i,2)=mean(vertices_follower(1,:));
                        delta=center_goal-pos(i,2);
                    else
                        delta=0;
                    end
                    newPosition(i,:)=Position;
                end
            end
            e=driving.internal.scenarioApp.undoredo.SetActorPosition(this.Application,this.Application.ActorSpecifications(ind(pos(:,1))),newPosition,oldPosition);
            applyEdit(this.Application,e);
        end

    end
end

function vertices=getVertices(actor)
    Position=actor.Position;
    Width=actor.Width;

    dims=dimensions(actor);
    RearOverhang=dims.Length/2+dims.OriginOffset(1);
    Length=actor.Length;
    Roll=actor.Roll*(pi/180);
    Pitch=actor.Pitch*(pi/180);
    Yaw=actor.Yaw*(pi/180);
    rotm=eul2rotm([Roll,Pitch,Yaw],'XYZ');

    vertices=repmat(Position,4,1)'+rotm*[Length-RearOverhang,0.5*Width,0;Length-RearOverhang,-0.5*Width,0;-RearOverhang,-0.5*Width,0;-RearOverhang,0.5*Width,0]';
end