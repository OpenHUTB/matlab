classdef PCBDesignerCanvasController<cad.Cad2DController




    methods
        function self=PCBDesignerCanvasController(View,Model)
            self@cad.Cad2DController(View,Model);
        end

        function addListeners(obj)
            addListeners@cad.Cad2DController(obj);
            addlistener(obj.View,'AddLayer',@(src,evt)obj.Model.add(evt));
            addlistener(obj.View,'AddFeed',@(src,evt)obj.Model.add(evt));
            addlistener(obj.View,'AddVia',@(src,evt)obj.Model.add(evt));
            addlistener(obj.View,'AddLoad',@(src,evt)obj.Model.add(evt));
            addlistener(obj.View,'MoveFeed',@(src,evt)obj.Model.valueChanged(evt));
            addlistener(obj.View,'ResizeFeed',@(src,evt)obj.Model.valueChanged(evt));
            addlistener(obj.View,'MoveVia',@(src,evt)obj.Model.valueChanged(evt));
            addlistener(obj.View,'ResizeVia',@(src,evt)obj.Model.valueChanged(evt));
            addlistener(obj.View,'MoveLoad',@(src,evt)obj.Model.valueChanged(evt));
            addlistener(obj.View,'ResizeLoad',@(src,evt)obj.Model.valueChanged(evt));
            addlistener(obj.View,'Delete',@(src,evt)obj.Model.deleteAct(evt));
        end
    end
end
