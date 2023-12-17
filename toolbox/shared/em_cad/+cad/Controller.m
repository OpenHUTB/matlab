classdef Controller<handle

    properties
View
Model
    end


    methods
        function self=Controller(View,Model)
            self.Model=Model;
            self.View=View;
            for i=1:numel(View)
                addlistener(self.Model,'ModelChanged',@(src,evt)modelChanged(self.View(i),evt));
                setModel(self.View(i),self.Model);
            end
        end


        function addTooltipHandler(self)
            addlistener(self.View,'Hover',@(src,evt)self.View.setCursorText(src,evt));
        end
    end
    events
    end
end
