classdef AddVariableAction<cad.Actions
    methods

        function self=AddVariableAction(Model,evt)
            self.Type="AddVariable";
            self.Model=Model;
            self.ActionInfo.Name=evt.Name;
            self.ActionInfo.Value=evt.Value;
        end

        function execute(self)
            evt=self.ActionInfo;
            self.Model.VariablesManager.addVariable(evt.Name,evt.Value);
            self.Model.notify('ModelChanged',cad.events.ModelChangedEventData(...
            'VariableAdded','Variable','Variable',evt,getInfo(self.Model),''))
        end

        function undo(self)
            evt=self.ActionInfo;
            self.Model.VariablesManager.removeVariable(evt.Name);
            self.Model.notify('ModelChanged',cad.events.ModelChangedEventData(...
            'VariableDeleted','Variable','Variable',evt,getInfo(self.Model),''));
        end
    end
end