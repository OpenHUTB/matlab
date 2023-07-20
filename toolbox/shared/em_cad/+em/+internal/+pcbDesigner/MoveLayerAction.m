classdef MoveLayerAction<cad.Actions









    methods

        function self=MoveLayerAction(Model,evt)
            self.Model=Model;
            self.ActionInfo=evt.Data;
            self.ActionInfo.Id=evt.Data.Layer.Id;

        end

        function undo(self)

            switch self.ActionInfo.Direction
            case 'Up'
                moveLayerObj(self.Model,self.ActionInfo.Layer,'Down');
            case 'Down'
                moveLayerObj(self.Model,self.ActionInfo.Layer,'Up');
            end

        end

        function execute(self)

            moveLayerObj(self.Model,self.ActionInfo.Layer,self.ActionInfo.Direction);
        end
    end
end
