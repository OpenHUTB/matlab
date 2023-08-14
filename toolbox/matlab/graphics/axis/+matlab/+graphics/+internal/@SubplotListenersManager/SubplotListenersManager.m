classdef SubplotListenersManager<handle&matlab.mixin.Copyable







    properties(Transient)
        ContainerListeners;
        AxesListeners;
        AxesPropertyListeners;
        TitleListener;
    end

    properties(Dependent=true)
helper
    end

    properties(SetAccess=private,GetAccess=private)
        MaxNumAxes;
    end

    methods(Access=protected)
        function copy=copyElement(this)
            copy=copyElement@matlab.mixin.Copyable(this);
            copy.ContainerListeners=[];
        end
    end

    methods

        function obj=SubplotListenersManager(n)



            obj.ContainerListeners={};
            obj.AxesListeners={};
            obj.AxesPropertyListeners={};
            if(nargin>0)
                obj.MaxNumAxes=n;
            else
                obj.MaxNumAxes=0;
            end
        end

        function delete(obj)

            for idx=1:numel(obj.ContainerListeners)
                delete(obj.ContainerListeners{idx});
            end
        end

        function set.helper(obj,~)


            axes=findall(gcf,'Type','axes');
            nax=length(axes);
            if(nax>0&&isempty(obj.MaxNumAxes))
                obj.MaxNumAxes=nax;
            end
            for iter=1:nax
                obj.addToListeners(axes(iter),[]);
                slm=getappdata(axes(iter),'SubplotDeleteListenersManager');
                if~isempty(slm)
                    slm.addToListeners(axes(iter));
                end
            end
        end

        function v=isManaged(obj,ax)



            n=numel(obj.AxesListeners);
            for i=1:n
                if(~isempty(obj.AxesListeners{i})&&obj.AxesListeners{i}.Source{1}==ax)
                    v=true;
                    return;
                end
            end
            v=false;
        end

        function num=getNumManaged(obj)



            num=0;
            n=numel(obj.AxesListeners);
            for i=1:n
                if~isempty(obj.AxesListeners{i})
                    num=num+1;
                end
            end
        end

        function b=hasManagedTitle(obj)
            b=~isempty(obj.TitleListener);
        end

        function addTitle(obj,title)
            fig=title.Parent;
            inv=@(o,e)subplotlayoutInvalid(title,e,fig);
            obj.TitleListener=event.listener(title,'MarkedDirty',inv);
        end

        function removeTitle(obj,subplotText)
            if~isempty(obj.TitleListener)&&obj.TitleListener.Source{1}==subplotText
                delete(obj.TitleListener);
                obj.TitleListener=[];
            end
        end

        function addToListeners(obj,ax,canvas)




            fig=ax.Parent;
            inv=@(o,e)subplotlayoutInvalid(ax,e,fig);
            if isempty(obj.ContainerListeners)
                if isempty(canvas)
                    if~isa(fig,'matlab.ui.container.CanvasContainer')
                        error(message('MATLAB:subplot:InvalidParent'));
                    end
                    canvas=fig.getCanvas();
                end

                pu=@(o,e)subplotlayout(ax,e,fig);
                obj.ContainerListeners={event.listener(fig,'SizeChanged',inv);...
                event.listener(canvas,'PreUpdate',pu)};
            end



            am=@(o,e)matlab.graphics.internal.axesMoved(o,e,fig);

            upre=@(o,e)matlab.graphics.internal.axesUnitsPreSet(o,e);
            upost=@(o,e)matlab.graphics.internal.axesUnitsPostSet(o,e);
            up=findprop(ax,'Units');
            mp=[findprop(ax,'Position'),...
            findprop(ax,'OuterPosition'),...
            findprop(ax,'InnerPosition'),...
            findprop(ax,'ActivePositionProperty'),...
            findprop(ax,'Parent')];















            if isempty(obj.AxesListeners)
                obj.AxesListeners=cell(1,obj.MaxNumAxes);
                aindex=1;
            else
                aindex=findemptycell(obj.AxesListeners);
            end

            if isempty(obj.AxesPropertyListeners)
                obj.AxesPropertyListeners=cell(1,3*obj.MaxNumAxes);
                bindex=1:3;
            else
                bindex=find3emptycells(obj.AxesPropertyListeners);
            end

            if(~isempty(aindex)&&~isempty(bindex))
                obj.AxesListeners{aindex}=event.listener(ax,'MarkedDirty',inv);
                if(up.SetObservable)
                    obj.AxesPropertyListeners{bindex(1)}=event.proplistener(ax,up,'PostSet',upost);
                    obj.AxesPropertyListeners{bindex(2)}=event.proplistener(ax,up,'PreSet',upre);
                end

                obsp=mp([mp.SetObservable]);
                obj.AxesPropertyListeners{bindex(3)}=event.proplistener(ax,obsp,'PostSet',am);
                if isa(ax,'matlab.graphics.chartcontainer.mixin.internal.Positionable')
                    obj.AxesPropertyListeners{bindex(3)}=addlistener(ax,'OuterPositionChanged',am);
                end
            end
        end

        function removeFromListeners(obj,ax)
            n=numel(obj.AxesListeners);
            for i=1:n
                if~isempty(obj.AxesListeners{i})
                    if(obj.AxesListeners{i}.Source{1}==ax)
                        delete(obj.AxesListeners{i});
                        obj.AxesListeners{i}=[];
                    end
                end
            end
            n=numel(obj.AxesPropertyListeners);
            for i=1:n
                if~isempty(obj.AxesPropertyListeners{i})
                    if(isprop(obj.AxesPropertyListeners{i},'Object')&&obj.AxesPropertyListeners{i}.Object{1}==ax)||...
                        (~isprop(obj.AxesPropertyListeners{i},'Object')&&obj.AxesPropertyListeners{i}.Source{1}==ax)
                        delete(obj.AxesPropertyListeners{i});
                        obj.AxesPropertyListeners{i}=[];
                    end
                end
            end
        end

        function enable(obj)


            n=numel(obj.ContainerListeners);
            for i=1:n
                if~isempty(obj.ContainerListeners{i})
                    obj.ContainerListeners{i}.Enabled=true;
                end
            end
            n=numel(obj.AxesListeners);
            for i=1:n
                if~isempty(obj.AxesListeners{i})
                    obj.AxesListeners{i}.Enabled=true;
                end
            end
            n=numel(obj.AxesPropertyListeners);
            for i=1:n
                if~isempty(obj.AxesPropertyListeners{i})
                    obj.AxesPropertyListeners{i}.Enabled=true;
                end
            end

            if~isempty(obj.TitleListener)
                obj.TitleListener.Enabled=true;
            end
        end

        function disable(obj)



            n=numel(obj.ContainerListeners);
            for i=1:n
                if~isempty(obj.ContainerListeners{i})
                    obj.ContainerListeners{i}.Enabled=false;
                end
            end
            n=numel(obj.AxesListeners);
            for i=1:n
                if~isempty(obj.AxesListeners{i})
                    obj.AxesListeners{i}.Enabled=false;
                end
            end
            n=numel(obj.AxesPropertyListeners);
            for i=1:n
                if~isempty(obj.AxesPropertyListeners{i})
                    isunits=isprop(obj.AxesPropertyListeners{i}.Source{1},'Name')&&strcmp(obj.AxesPropertyListeners{i}.Source{1}.Name,'Units');
                    if~isunits
                        obj.AxesPropertyListeners{i}.Enabled=false;
                    end
                end
            end

            if~isempty(obj.TitleListener)
                obj.TitleListener.Enabled=false;
            end
        end

        function r=areListenersEnabled(obj)





            r=true(1,0);

            n=numel(obj.ContainerListeners);
            for i=1:n
                if~isempty(obj.ContainerListeners{i})
                    r=[r,obj.ContainerListeners{i}.Enabled];
                end
            end
            n=numel(obj.AxesListeners);
            for i=1:n
                if~isempty(obj.AxesListeners{i})
                    r=[r,obj.AxesListeners{i}.Enabled];
                end
            end
            n=numel(obj.AxesPropertyListeners);
            for i=1:n
                if~isempty(obj.AxesPropertyListeners{i})
                    isunits=isprop(obj.AxesPropertyListeners{i}.Source{1},'Name')&&strcmp(obj.AxesPropertyListeners{i}.Source{1}.Name,'Units');
                    if~isunits
                        r=[r,obj.AxesPropertyListeners{i}.Enabled];
                    end
                end
            end
        end
    end
end

function aindex=findemptycell(c)
    aindex=[];
    n=numel(c);
    for i=1:n
        if isempty(c{i})
            aindex=i;
            break;
        end
    end
end

function r=find3emptycells(c)
    r=[];
    n=numel(c);
    for i=1:n
        if isempty(c{i})
            r=[r(:)',i];
            if(numel(r)==3)
                break;
            end
        end
    end
    if(numel(r)~=3)
        r=[];
    end
end


