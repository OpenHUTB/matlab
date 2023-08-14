classdef VariablesController





    properties
Model
View
    end

    methods
        function obj=VariablesController(View,Model)
            obj.Model=Model;
            obj.View=View;
        end

        function addListeners(self)
            addlistener(self.View,'AddVariable',@(src,evt)self.Model.addVariable(evt));
            addlistener(self.View,'DeleteVariable',@(src,evt)self.Model.deleteVariable(evt));
            addlistener(self.View,'ChangeVariable',@(src,evt)self.Model.changeVariable(evt));
        end
    end
end

