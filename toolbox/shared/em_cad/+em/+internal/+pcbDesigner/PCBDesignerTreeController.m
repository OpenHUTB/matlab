classdef PCBDesignerTreeController<cad.TreeNodeController




    methods
        function self=PCBDesignerTreeController(View,Model)
            self@cad.TreeNodeController(View,Model);
        end

        function addListeners(obj)
            addListeners@cad.TreeNodeController(obj);
            addlistener(obj.View,'DeleteLayer',@(src,evt)obj.Model.deleteAct(evt));
            addlistener(obj.View,'DeleteShape',@(src,evt)obj.Model.deleteAct(evt));
            addlistener(obj.View,'DeleteObj',@(src,evt)obj.Model.deleteSelection());
            addlistener(obj.View,'DeleteFeed',@(src,evt)obj.Model.deleteAct(evt));
            addlistener(obj.View,'DeleteVia',@(src,evt)obj.Model.deleteAct(evt));
            addlistener(obj.View,'DeleteLoad',@(src,evt)obj.Model.deleteAct(evt));




            addlistener(obj.View,'Selected',@(src,evt)obj.Model.selectedAction(evt));
            addlistener(obj.View,'OverlayLayer',@(src,evt)obj.Model.overlay(evt));
            addlistener(obj.View,'ColorChanged',@(src,evt)obj.Model.valueChanged(evt));
            addlistener(obj.View,'Cut',@(src,evt)obj.Model.cut(evt));
            addlistener(obj.View,'Copy',@(src,evt)obj.Model.copy(evt));
            addlistener(obj.View,'CopyObj',@(src,evt)obj.Model.copy());
            addlistener(obj.View,'Paste',@(src,evt)obj.Model.paste(evt));
        end
    end
end
