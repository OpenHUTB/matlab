classdef WidgetContainer<handle

    properties(Dependent)
Widgets
    end

    properties(Access=private)
        WidgetStore=metric.dashboard.widgets.WidgetBase.empty(0,0)
        StoreDirty=true
    end

    properties(Access=protected,Abstract)
Configuration
    end

    methods
        function returnWidget=addWidget(this,type,num)

            if nargin==1
                error(message('dashboard:uidatamodel:AtLeastInput',1));
            end

            metric.dashboard.Verify.ScalarCharOrString(type);

            container=this.getMF0Object().Widgets;
            needToMove=true;

            if nargin==2
                num=container.Size+1;
                needToMove=false;
            else
                if(num<1)||(floor(num)~=num)||~isfinite(num)
                    error(message('dashboard:uidatamodel:PositiveInteger'));
                end

                if num>container.Size
                    num=container.Size+1;
                    needToMove=false;
                end
            end

            factory=metric.dashboard.WidgetFactory(this.Configuration);
            newWidget=factory.createMF0Widget(type,mf.zero.getModel(this.getMF0Object()));

            newWidget.Position=num;


            if needToMove
                for i=1:container.Size
                    if container(i).Position>=num
                        container(i).Position=container(i).Position+1;
                    end
                end
            end

            container.add(newWidget);
            this.StoreDirty=true;

            returnWidget=this.createMLWidget(newWidget,factory);
        end

        function allWidgets=get.Widgets(this)
            if this.StoreDirty
                cont=this.getMF0Object.Widgets;
                this.WidgetStore=metric.dashboard.widgets.WidgetBase.empty(0,0);
                factory=metric.dashboard.WidgetFactory(this.Configuration);

                for i=1:cont.Size
                    this.WidgetStore(i)=this.createMLWidget(cont(i),factory);
                end

                if~isempty(this.WidgetStore)
                    [~,idx]=sort([this.WidgetStore.Position]);
                    this.WidgetStore=this.WidgetStore(idx);
                end
                this.StoreDirty=false;
            end

            allWidgets=this.WidgetStore;
        end

        function removeWidget(this,widget)
            cont=this.getMF0Object.Widgets;
            idx=cont.indexOf(widget.getMF0Widget);
            if idx<0
                error(message('dashboard:uidatamodel:NonExistingWidgetInLayout'));
            end

            pos=widget.Position;
            if pos<cont.Size
                for i=1:cont.Size
                    if cont(i).Position>pos
                        cont(i).Position=cont(i).Position-1;
                    end
                end
            end

            cont.remove(widget.getMF0Widget());
            this.StoreDirty=true;
        end

        function repositionWidget(this,widget,newpos)
            container=this.getMF0Object().Widgets;
            widget=widget.getMF0Widget();


            if newpos>widget.Position
                offset=-1;
                lb=widget.Position;
                ub=newpos;
            else
                offset=1;
                lb=newpos-1;
                ub=widget.Position;
            end

            for i=1:container.Size
                if(container(i).Position>lb)...
                    &&(container(i).Position<=ub)
                    container(i).Position=container(i).Position+offset;
                end
            end

            widget.Position=newpos;

            this.StoreDirty=true;
        end

        function out=getContainerSize(this)
            out=this.getMF0Object().Widgets.Size;
        end

    end



    methods(Abstract,Access=protected)
        container=getMF0Object(this)
    end

    methods(Access=private)
        function mlwidget=createMLWidget(this,mf0Widget,factory)
            mlwidget=factory.createMLWidget(mf0Widget);
            mlwidget.RepositionFcn=@this.repositionWidget;
            mlwidget.ParentSizeFcn=@this.getContainerSize;
        end
    end

end

