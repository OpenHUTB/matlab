

classdef(Sealed=true)YYAxisEventManager<handle















    properties(Hidden=true,Access=?tmatlab_graphics_internal_YYAxisEventManager)
TrackedObjs
HostProp
ClickListener
    end

    methods(Static,Hidden=true)


        function registerAxes(ax)


            f=ancestor(ax,'figure');

            if isempty(f)


                matlab.graphics.internal.YYAxisEventManager.installReparentWatcher(ax);
                return;
            end

            if isprop(f,'YYAxisEventManager')


                f.YYAxisEventManager.addAxes(ax);
            else

                matlab.graphics.internal.YYAxisEventManager(ax);
            end

        end




        function unregisterAxes(ax)


            if isprop(ax,'YYAxisCleanupTask')
                delete(ax.YYAxisCleanupTask);
            end

        end

    end



    methods(Static,Access=private,Hidden=true)
        function installReparentWatcher(ax)
            if~isprop(ax,'YYAxisReparentListener')
                q=addprop(ax,'YYAxisReparentListener');
                q.Hidden=true;
                q.Transient=true;
            else
                delete(ax.YYAxisReparentListener);
            end

            objs=ax;
            np=ax.NodeParent;
            if isscalar(np)&&isa(np,'matlab.graphics.shape.internal.AxesLayoutManager')



                objs=[ax,np];
            end
            ax.YYAxisReparentListener=event.listener(objs,'Reparent',...
            @(~,~)handleReparent(ax));
        end
    end


    methods(Hidden=true)


        function doneWith(hThis,obj)

            if isprop(obj,'YYAxisReparentListener')
                delete(obj.YYAxisReparentListener);
            end

            hThis.TrackedObjs=setdiff(hThis.TrackedObjs,obj);
            if(isempty(hThis.TrackedObjs))
                removeManager(hThis);
            end
        end
    end

    methods(Access=private,Hidden=true)



        function h=YYAxisEventManager(ax)
            f=ancestor(ax,'figure');


            h.ClickListener=event.listener(f,'WindowMousePress',@(a,b)handleClick(a,b));

            h.HostProp=f.addprop('YYAxisEventManager');
            h.HostProp.Hidden=true;
            h.HostProp.Transient=true;
            f.YYAxisEventManager=h;
            h.addAxes(ax);
        end


        function addAxes(hThis,ax)
            hThis.TrackedObjs=union(hThis.TrackedObjs,ax);
            h=onCleanup(@()hThis.doneWith(ax));


            if~isprop(ax,'YYAxisCleanupTask')
                p=addprop(ax,'YYAxisCleanupTask');
                p.Hidden=true;
                p.Transient=true;
            end
            ax.YYAxisCleanupTask=h;

            hThis.installReparentWatcher(ax);
        end



        function removeManager(hThis)
            delete(hThis.ClickListener);
            delete(hThis.HostProp);
        end

    end

end



function handleReparent(ax)
    if(~isscalar(ax)||~isvalid(ax)||strcmpi(ax.BeingDeleted,'on'))
        return
    end


    if isprop(ax,'YYAxisCleanupTask')
        delete(ax.YYAxisCleanupTask);
    end


    matlab.graphics.internal.YYAxisEventManager.registerAxes(ax);

end


function handleClick(~,evt)


    obj=evt.HitPrimitive;

    if isempty(obj)||~isvalid(obj)
        return
    end


    ax=ancestor(obj,'matlab.graphics.axis.AbstractAxes');

    if(~isscalar(ax)||~isvalid(ax)||strcmpi(ax.BeingDeleted,'on'))
        return
    end

    ax.processFigureHitObject(obj);


end
