classdef Linger<handle&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer



    properties

        Target(:,1)matlab.graphics.Graphics


        IncludeChildren(1,1)logical=false


        LingerTime(1,1)double=1


        LingerResetMethod{mustBeMember(LingerResetMethod,{'exitobject','exitaxes'})}='exitobject'



        GetNearestPointFcn matlab.internal.datatype.matlab.graphics.datatype.Callback=''

MoveEventObject

ExitEventObject

        AutoReparent(1,1)logical=true
    end

    events

EnterObject


ExitObject


LingerOverObject


LingerReset
    end

    properties(SetAccess='private')
        Enabled(1,1)logical=false
    end

    properties(Access=?tLinger,Transient,NonCopyable)
Figure
Canvas

LingerTimer
        LingerTimeExpired=false
LingerAxes

        LastObject=gobjects(1)
        LastIndex=NaN
LastEventData

MotionListener
ExitListener
DeleteListener
        ReparentNodeListeners=event.listener.empty()
        ReparentContainerListeners=event.proplistener.empty();

MoveEventName
ExitEventName
    end

    methods
        function hObj=Linger(hTargets,MoveEventObject,MoveEventName,ExitEventObject,ExitEventName)



            if nargin>1
                hObj.AutoReparent=false;
            end



            if isempty(hObj.MoveEventObject)&&nargin>2
                hObj.MoveEventObject=MoveEventObject;
                hObj.MoveEventName=MoveEventName;
            end



            if isempty(hObj.ExitEventObject)&&nargin>4
                hObj.ExitEventObject=ExitEventObject;
                hObj.ExitEventName=ExitEventName;
            end


            hObj.Target=hTargets;
        end

        function enable(hObj)
            hObj.Enabled=true;
            if~isempty(hObj.MoveEventObject)
                hObj.MotionListener=event.listener(...
                hObj.MoveEventObject,hObj.MoveEventName,@(o,e)motionCallback(hObj,o,e));
            end
            if~isempty(hObj.ExitEventObject)
                hObj.ExitListener=event.listener(...
                hObj.ExitEventObject,hObj.ExitEventName,@(o,e)canvasExitCallback(hObj,o,e));
            end
        end

        function disable(hObj)
            hObj.Enabled=false;

            hObj.MotionListener=[];


            hObj.ExitListener=[];


            hObj.stopTimer();


            hObj.LingerTimeExpired=false;
        end

        function delete(hObj)

            hObj.disable();


            if isscalar(hObj.LingerTimer)&&isvalid(hObj.LingerTimer)
                stop(hObj.LingerTimer)
                delete(hObj.LingerTimer)
            end
        end

        function resetLinger(hObj)

            hObj.stopTimer();


            hObj.LingerTimeExpired=false;


            notify(hObj,'LingerReset');
        end
    end

    methods
        function set.MoveEventObject(hObj,newTargets)



            if hObj.AutoReparent&&~isa(newTargets,'matlab.ui.Figure')

            else
                hObj.MoveEventObject=newTargets;
                if hObj.Enabled
                    hObj.enable();
                end
            end
        end

        function set.ExitEventObject(hObj,newTargets)
            if hObj.AutoReparent&&~isa(newTargets,'matlab.graphics.primitive.canvas.JavaCanvas')

            else
                hObj.ExitEventObject=newTargets;
                if hObj.Enabled
                    hObj.enable();
                end
            end
        end

        function set.Target(hObj,newTargets)

            hObj.Target=newTargets;


            if hObj.AutoReparent
                hObj.reparent();
            end
        end
    end

    methods(Access=?tLinger)
        function startTimer(hObj)
            t=hObj.LingerTimer;

            if isscalar(t)&&isvalid(t)

                t.StartDelay=hObj.LingerTime;
            else


                t=timer(...
                'Name','Linger Timer',...
                'ObjectVisibility','off',...
                'StartDelay',hObj.LingerTime,...
                'BusyMode','queue');
                hObj.LingerTimer=t;






                cb=@(~,~)hObj.lingerEvent();
                t.TimerFcn=matlab.graphics.controls.internal.timercb(cb);
            end


            start(t);
        end

        function stopTimer(hObj)



            if~isempty(hObj)&&isvalid(hObj)
                t=hObj.LingerTimer;
                if isscalar(t)&&isvalid(t)
                    stop(t);
                end
            end
        end

        function reparent(hObj)

            hTargets=hObj.Target(:)';

            hCanvas=gobjects(0);
            hFigure=gobjects(0);

            for t=hTargets
                tCanvas=ancestor(t,'matlab.graphics.primitive.canvas.Canvas','node');
                if isscalar(tCanvas)&&~any(tCanvas==hCanvas)
                    hCanvas=[hCanvas,tCanvas];%#ok<AGROW>
                end

                tFigure=ancestor(t,'matlab.ui.Figure');
                if isscalar(tFigure)&&~any(tFigure==hFigure)
                    hFigure=[hFigure,tFigure];%#ok<AGROW>
                end
            end


            hObj.Canvas=hCanvas;
            hObj.Figure=hFigure;





            hObj.MoveEventObject=hFigure;
            hObj.MoveEventName='WindowMouseMotion';

            hObj.ExitEventObject=hCanvas;
            hObj.ExitEventName='ButtonExited';


            hObj.DeleteListener=event.listener(hTargets,'ObjectBeingDestroyed',@hObj.deleteTarget);






            nodes=matlab.graphics.primitive.world.SceneNode.empty();


            containers=matlab.ui.control.Component.empty();


            for t=1:numel(hTargets)
                parent=hTargets(t);
                while isscalar(parent)&&~isgraphics(parent,'figure')
                    if isa(parent,'matlab.graphics.primitive.world.SceneNode')
                        if any(parent==nodes)
                            break
                        end
                        nodes(end+1)=parent;%#ok<AGROW>
                    elseif isa(parent,'matlab.ui.control.Component')
                        if any(parent==containers)
                            break
                        end
                        containers(end+1)=parent;%#ok<AGROW>
                    end
                    parent=parent.NodeParent;
                end
            end


            hObj.ReparentNodeListeners=event.listener(nodes,'Reparent',@(~,~)hObj.reparent());


            if isempty(containers)
                hObj.ReparentContainerListeners=event.proplistener.empty();
            else
                parentProp=findprop(containers(1),'Parent');
                hObj.ReparentContainerListeners=event.proplistener(containers,parentProp,'PostSet',@(~,~)hObj.reparent());
            end


            if hObj.Enabled

                hObj.enable();
            end
        end

        function deleteTarget(hObj,deletedObj,~)
            oldTargets=hObj.Target;
            newTargets=setdiff(oldTargets,deletedObj);
            if numel(newTargets)==0
                hObj.delete();
            else
                hObj.Target=newTargets;
            end
        end

        function canvasExitCallback(hObj,hCanvas,~)







            data.Point=[NaN,NaN];
            data.PointInPixels=[NaN,NaN];
            data.IntersectionPoint=[NaN,NaN,NaN];


            data.HitObject=gobjects(0);
            data.HitPrimitive=gobjects(0);


            hObj.motionCallback(hCanvas,data)
        end


        function enterEvent(hObj,eventData)
            notify(hObj,'EnterObject',eventData);
        end

        function exitEvent(hObj,eventData)
            notify(hObj,'ExitObject',eventData);
        end

        function lingerEvent(hObj)



            if~isempty(hObj)&&isvalid(hObj)

                hObj.stopTimer();


                hObj.LingerTimeExpired=true;


                eventData=hObj.LastEventData;
                lingerEventData=matlab.graphics.interaction.actions.LingerEventData(eventData.Source,eventData);


                if isempty(eventData.HitObject)||~isvalid(eventData.HitObject)
                    return;
                end

                hObj.LingerAxes=ancestor(eventData.HitObject,'matlab.graphics.axis.AbstractAxes','node');


                notify(hObj,'LingerOverObject',lingerEventData);
            end
        end
    end
    methods
        function motionCallback(hObj,hSource,eventData)



            eventData=matlab.graphics.interaction.actions.LingerEventData(hSource,eventData);


            figPoint=eventData.PointInPixels;


            hTargets=hObj.Target;
            hitObject=eventData.HitObject;

            if hObj.IncludeChildren
                hitTargetObject=false;
                obj=hitObject;
                while~isempty(obj)
                    hitTargetObject=any(obj==hTargets);
                    if hitTargetObject
                        break;
                    end
                    obj=obj.NodeParent;
                end
            else
                hitTargetObject=ismember(hitObject,hTargets);
            end

            if hitTargetObject
                getNearestPointFcn=hObj.GetNearestPointFcn;
                if~isempty(getNearestPointFcn)


                    nearestPoint=getNearestPointFcn(hitObject,eventData);
                else



                    hit=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hitObject);

                    if isempty(hit)&&hObj.IncludeChildren






                        hit=ancestor(hitObject,'matlab.graphics.chart.interaction.DataAnnotatable','node');
                    end

                    if isempty(hit)


                        nearestPoint=NaN;
                    else


                        nearestPoint=hit.getNearestPoint(figPoint);
                    end

                end
            else

                nearestPoint=NaN;
                hitObject=gobjects(1);
            end

            if isempty(nearestPoint)


                nearestPoint=NaN;
                hitObject=gobjects(1);
            end


            lastIndex=hObj.LastIndex;
            lastObject=hObj.LastObject;
            hObj.LastObject=hitObject;
            hObj.LastIndex=nearestPoint;


            eventData.NearestPoint=nearestPoint;
            eventData.PreviousPoint=lastIndex;
            if~isgraphics(lastObject)
                eventData.PreviousObject=gobjects(0);
            else
                eventData.PreviousObject=lastObject;
            end








            if hitObject~=lastObject||~isequaln(nearestPoint,lastIndex)




                hObj.stopTimer();


                if isgraphics(lastObject)
                    exitEventData=matlab.graphics.interaction.actions.LingerEventData(hSource,eventData);
                    hObj.exitEvent(exitEventData);
                end



                if hObj.LingerTimeExpired&&strcmp(hObj.LingerResetMethod,'exitobject')
                    hObj.resetLinger();
                end



                if hObj.LingerTimeExpired&&~isgraphics(hitObject)


                    hitAxes=ancestor(eventData.HitObject,'matlab.graphics.axis.AbstractAxes','node');
                    lingerAxes=hObj.LingerAxes;

                    if isempty(hitAxes)||(~isempty(lingerAxes)&&hitAxes~=lingerAxes)

                        hObj.resetLinger();
                    end
                end


                if isgraphics(hitObject)



                    hObj.enterEvent(eventData);


                    hObj.LastEventData=eventData;


                    if hObj.LingerTimeExpired||hObj.LingerTime==0


                        hObj.lingerEvent();
                    else

                        hObj.startTimer();
                    end
                end
            end
        end
    end
end

