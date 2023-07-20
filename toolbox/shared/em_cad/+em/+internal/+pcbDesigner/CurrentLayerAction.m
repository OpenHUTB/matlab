classdef CurrentLayerAction<cad.Actions





    methods

        function self=CurrentLayerAction(Model,evt)
            self.Type='Layer';
            self.Model=Model;
            self.ActionObjectType='Layer';
            self.ActionInfo.PreviousLayerId=evt.PreviousLayer.Id;
            self.ActionInfo.PreviousLayer=evt.PreviousLayer;
            self.ActionInfo.CurrentLayerId=evt.CurrentLayer.Id;
            self.ActionInfo.CurrentLayer=evt.CurrentLayer;
        end

        function undo(self)
            if~isvalid(self.ActionInfo.PreviousLayer)
                self.ActionInfo.PreviousLayer=findlayerobj(self.Model,self.ActionInfo.PreviousLayerId);
            end
            setGroup(self.Model,self.ActionInfo.PreviousLayer);
            currentLayerChanged(self.Model);


            evt=[];
            evt.Data={{'Layer'},self.ActionInfo.PreviousLayerId};
            evt.SelectionView=self.Model.SelectionViewType;
            self.Model.selected(evt);
        end

        function execute(self)
            if~isvalid(self.ActionInfo.CurrentLayer)
                self.ActionInfo.CurrentLayer=findlayerobj(self.Model,self.ActionInfo.CurrentLayerId);
            end
            setGroup(self.Model,self.ActionInfo.CurrentLayer);
            currentLayerChanged(self.Model);


            evt=[];
            evt.Data={{'Layer'},self.ActionInfo.CurrentLayerId};
            evt.SelectionView=self.Model.SelectionViewType;
            self.Model.selected(evt);
        end

    end
end
