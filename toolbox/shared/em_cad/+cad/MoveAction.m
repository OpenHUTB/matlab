classdef MoveAction<cad.Actions












    methods

        function self=MoveAction(Model,evt)

            self.Model=Model;

            self.ActionInfo.Selection=evt.Data.Selection;

            self.ActionInfo.StartPoint=evt.Data.StartPoint;

            self.ActionInfo.EndPoint=evt.Data.EndPoint;
        end

        function undo(self)

            for i=1:numel(self.ActionInfo.Selection{1})

                object=getObject(self.Model,self.ActionInfo.Selection{1}{i},self.ActionInfo.Selection{2}(i));

                moveobject(self.Model,object,self.ActionInfo.EndPoint,self.ActionInfo.StartPoint)
            end

        end

        function execute(self)

            for i=1:numel(self.ActionInfo.Selection{1})

                object=getObject(self.Model,self.ActionInfo.Selection{1}{i},self.ActionInfo.Selection{2}(i));

                moveobject(self.Model,object,self.ActionInfo.StartPoint,self.ActionInfo.EndPoint)
            end
        end
    end
end
