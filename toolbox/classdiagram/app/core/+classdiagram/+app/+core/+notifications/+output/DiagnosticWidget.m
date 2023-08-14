classdef DiagnosticWidget<handle
    properties(Access=private)
        WidgetHandle=[];
        Hint=[0,0,0,1];
        DWRegistry;
    end

    properties
        id;
        targetId;
    end

    methods
        function set.id(this,value)
            this.id=value+"."+matlab.lang.internal.uuid;
        end
    end



    methods(Static)
        function config=getDefaultWidgetConfiguration()
            config=struct('Suppression',...
            struct('ClientHandlesJustification',false,...
            'isJustificationMandatory',true));
        end
    end


    methods(Access=public)
        function this=DiagnosticWidget(element,widgetData,positionSpec,registry)
            [position,moveOnResize]=classdiagram.app.core.notifications.output.utils.internal.getPositionForSpec(positionSpec);
            this.id=element;
            this.targetId=string(element);
            this.WidgetHandle=classdiagram.app.core.notifications.output.utils.internal.Widget(...
            this.id,widgetData,position,this.Hint,...
            classdiagram.app.core.notifications.output.DiagnosticWidget.getDefaultWidgetConfiguration,...
            moveOnResize);
            this.DWRegistry=registry;
            this.DWRegistry.register(this);
        end

        function start(this)
            this.WidgetHandle.start();
        end

        function pos=getPosition(this)
            pos=this.WidgetHandle.getPosition();
        end

        function notifications=getNotifications(this)
            notifications=[this.WidgetHandle.Diagnostics{:}];
        end

        function addNotification(this,options)
            this.WidgetHandle.addNotification(options);
        end

        function removeNotification(this,options)
            this.WidgetHandle.removeNotification(options);
            if this.WidgetHandle.isEmptyDiagnostics
                this.delete();
            end
        end

        function setCloseCallback(this,fh)
            this.WidgetHandle.setClientCloseCallback(fh);
        end

        function debugMode(this,isDebug)
            this.WidgetHandle.debugMode(isDebug);
        end

        function delete(this)
            this.WidgetHandle.delete();
            this.DWRegistry.unregister(this.id);
        end
    end

    methods(Hidden)

        function closeCallback(this)
            this.WidgetHandle.closeCallback();
        end
    end
end