classdef(Abstract)ToolstripSectionController<handle







    methods
        function setup(this)




            updateView(this);
            updateWidgetStates(this);


            installModelListeners(this);
            installViewListeners(this);
        end

        function updateWidgetStates(~)



        end
    end

    methods(Access=protected)
        function createProgressDialog(this,title)
            app=this.AppController.AppView;
            app.createProgressDialog(title);
        end

        function closeProgressDialog(this)
            app=this.AppController.AppView;
            app.closeProgressDialog;
        end

        function cancelled=setAppStatus(this,value,message)
            app=this.AppController.AppView;
            cancelled=app.setAppStatus(value,message);
        end
    end

    methods(Abstract,Access=protected)
        updateView(this);
        installModelListeners(this);
        installViewListeners(this);
    end

    methods(Static,Access=protected)
        function logButtonClickEvent(buttonString)
            import matlab.ddux.internal.*;
            eventId=UIEventIdentification(...
            "Design Evolution","Design Evolution Manager",...
            EventType.CLICK,ElementType.BUTTON,buttonString);
            logUIEvent(eventId,struct());
        end

        function logListItemSelectedEvent(itemString,data)
            import matlab.ddux.internal.*;
            eventId=UIEventIdentification(...
            "Design Evolution","Design Evolution Manager",...
            EventType.CLICK,ElementType.LIST_ITEM,itemString);
            logUIEvent(eventId,data);
        end
    end

end


