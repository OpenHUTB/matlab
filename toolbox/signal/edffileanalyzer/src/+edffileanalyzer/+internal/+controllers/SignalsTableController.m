

classdef SignalsTableController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
UpdateSelectionComplete
    end

    properties(Constant)
        ControllerID="SignalsTableController";
    end


    methods
        function this=SignalsTableController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"updateselection",'callback',@this.cb_UpdateSelection);
            ];
        end
    end


    methods(Hidden)
        function cb_UpdateSelection(this,args)


            signalPropertiesTableData.messageID="signalPropertiesTable";
            signalPropertiesTableData.data=this.Model.getDataForSignalPropertiesTable(args.data.signalID);
            this.notify("UpdateSelectionComplete",sigwebappsutils.internal.EventData(signalPropertiesTableData));
        end
    end
end