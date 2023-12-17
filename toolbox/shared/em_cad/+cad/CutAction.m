classdef CutAction<cad.SelectionDeleteAction


    methods

        function self=CutAction(Model,evt)

            self@cad.SelectionDeleteAction(Model,evt);

            self.Type='Cut';
            self.Model=Model;
            self.ActionObjectType=self.Model.SelectedObj.CategoryType;
            self.ActionInfo.Id=self.Model.SelectedObj.Id;
            self.ActionInfo.SelectionView=self.Model.SelectionView;

            self.ActionInfo.ShapeId=self.Model.SelectedObj.Id(strcmpi(self.Model.SelectedObj.CategoryType,'Shape'));
            self.ActionInfo.OperationId=[];
            self.ActionInfo.LayerId=self.Model.SelectedObj.Id(strcmpi(self.Model.SelectedObj.CategoryType,'Layer'));
            self.ActionInfo.OrphanOperationsId=[];
            if~strcmpi(self.ActionInfo.SelectionView,'Canvas')
                self.ActionInfo.OrphanOperationsId=getOrphanOperationsId(self);
            end

            self.ActionInfo.FeedId=self.Model.SelectedObj.Id(strcmpi(self.Model.SelectedObj.Type,'Feed'));
            self.ActionInfo.ViaId=self.Model.SelectedObj.Id(strcmpi(self.Model.SelectedObj.Type,'Via'));
            self.ActionInfo.LoadId=self.Model.SelectedObj.Id(strcmpi(self.Model.SelectedObj.Type,'Load'));

        end


        function undo(self)
            undo@cad.SelectionDeleteAction(self)
            self.Model.ClipBoard=[];
            self.Model.ClipBoardType='';
        end


        function execute(self)
            execute@cad.SelectionDeleteAction(self);
            cutobject=[self.ActionInfo.ShapeObj,self.ActionInfo.LayerObj,...
            self.ActionInfo.FeedObj,self.ActionInfo.ViaObj,self.ActionInfo.LoadObj];

            self.ActionObject=cutobject;
            self.Model.ClipBoard=cutobject;
            self.Model.ClipBoardType='Cut';
        end

    end
end
