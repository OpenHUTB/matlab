classdef Cad2DController





    properties
Model
View
    end

    methods
        function obj=Cad2DController(View,Model)
            obj.Model=Model;
            obj.View=View;
        end

        function addListeners(self)
            addlistener(self.View,'AddShape',@(src,evt)self.Model.add(evt));
            addlistener(self.View,'DeleteShape',@(src,evt)self.Model.deleteAct(evt));
            addlistener(self.View,'AddOperation',@(src,evt)self.Model.add(evt));
            addlistener(self.View,'MoveShape',@(src,evt)self.Model.add(evt));
            addlistener(self.View,'Move',@(src,evt)self.Model.move(evt));
            addlistener(self.View,'ResizeShape',@(src,evt)self.Model.add(evt));
            addlistener(self.View,'RotateShape',@(src,evt)self.Model.add(evt));
            addlistener(self.View,'Undo',@(src,evt)self.Model.undo());
            addlistener(self.View,'Redo',@(src,evt)self.Model.redo());


            addlistener(self.View,'Selected',@(src,evt)self.Model.selectedAction(evt));
            addlistener(self.View,'Cut',@(src,evt)self.Model.cut(evt));
            addlistener(self.View,'Copy',@(src,evt)self.Model.copy(evt));
            addlistener(self.View,'Paste',@(src,evt)self.Model.paste(evt));
        end
    end
end

