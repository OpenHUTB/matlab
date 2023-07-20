classdef ViewModel<handle




    properties












        MainModel em.internal.pcbDesigner.PCBModel
    end

    methods
        function modelChanged(self,evt)

            if strcmpi(evt.EventType,'SessionCleared')


                self.notify('SessionCleared');
            end
        end

        function rtn=getSettings(self)

            rtn=struct('Grid',self.MainModel.Grid,'Units',self.MainModel.Units);
        end

        function rtn=getLayersInfo(self)

            c=cell(numel(self.MainModel.LayerStack),1);
            for i=1:numel(self.MainModel.LayerStack)
                c{i}=self.MainModel.LayerStack(i).getLayerInfo();
            end
            rtn=c;
        end

        function rtn=getSelectedObjInfo(self)

            if isempty(self.MainModel.SelectedObj)||...
                (isfield(self.MainModel.SelectedObj,'Data')&&isempty(self.MainModel.SelectedObj.Data))

                if isfield(self.MainModel.SelectedObj,'Type')&&~isempty(self.MainModel.SelectedObj.Type)
                    evt.Data={self.MainModel.SelectedObj.Type,...
                    self.MainModel.SelectedObj.Id};

                    if~isempty(self.MainModel.SelectionViewType)
                        evt.SelectionView=self.MainModel.SelectionViewType;
                    else
                        evt.SelectionView='Canvas';
                    end

                    self.MainModel.selected(evt);

                    rtn={self.MainModel.SelectedObj.Type,...
                    self.MainModel.SelectedObj.Id,...
                    self.MainModel.SelectedObj.Args,...
                    self.MainModel.SelectedObj.ModelInfo};
                else
                    rtn=[];
                end
            else

                evt.Data={self.MainModel.SelectedObj.Type,...
                self.MainModel.SelectedObj.Id};

                if~isempty(self.MainModel.SelectionViewType)
                    evt.SelectionView=self.MainModel.SelectionViewType;
                else
                    evt.SelectionView='Canvas';
                end

                self.MainModel.selected(evt,1);

                rtn={self.MainModel.SelectedObj.Type,...
                self.MainModel.SelectedObj.Id,...
                self.MainModel.SelectedObj.Args,...
                self.MainModel.SelectedObj.ModelInfo};

            end
        end


        function rtn=getCurrentLayerInfo(self)

            rtn=self.MainModel.Group.getLayerInfo();
        end

        function rtn=getLayerInfo(self,id)

            layerobj=self.MainModel.findlayerobj(id);
            try
                rtn=layerobj.getLayerInfo();
            catch me
                rtn=[];
            end
        end

        function rtn=getModelInfo(self)

            rtn=getInfo(self.MainModel);
        end

        function actionStarted(self)



        end

        function actionEnded(self)


            self.notify('UpdateView');
        end

    end

    events
UpdateView
SessionCleared
    end

end
