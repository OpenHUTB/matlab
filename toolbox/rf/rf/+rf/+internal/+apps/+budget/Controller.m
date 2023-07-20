classdef Controller<handle





    properties(Hidden)
Model
View
Listeners
    end

    methods

        function self=Controller(model,view)


            self.Model=model;
            self.View=view;
            self.listenFileButtons()
            self.listenAddGallery()
            self.listenDeleteButton()
            self.listenHBButton()
            self.listenPlotFrequency();
            self.listenPlotButton()
            self.listen2DPlotButton()
            self.listenSmithPlotButton()
            self.listenViewButton()
            self.listenExportButton()
            self.Listeners.SystemParameterChanged=...
            addlistener(self.View.Parameters,'SystemParameterChanged',...
            @(h,data)systemParameterChanged(self.Model,data));
            self.Listeners.ElementParameterChanged=...
            addlistener(self.View.Parameters,'ElementParameterChanged',...
            @(h,data)elementParameterChanged(self.Model,data));
            self.Listeners.IconUpdate=...
            addlistener(self.View.Parameters,'IconUpdate',...
            @(h,data)iconUpdate(self.View,data));
            self.Listeners.DisableCanvas=...
            addlistener(self.View.Parameters,'DisableCanvas',...
            @(h,data)disableCanvas(self.View,data));
            self.Listeners.NameChanged=...
            addlistener(self.View.Parameters,'NameChanged',...
            @(h,data)nameChanged(self.View,data));
            self.Listeners.InsertionRequested=...
            addlistener(self.View,'InsertionRequested',...
            @(h,data)insertionRequested(self.Model,data));
            self.Listeners.DeletionRequested=...
            addlistener(self.View,'DeletionRequested',...
            @(h,data)deletionRequested(self.Model,data));
            self.Listeners.ElementSelected=...
            addlistener(self.View.Canvas,'ElementSelected',...
            @(h,data)elementSelected(self.Model,data));
            self.Listeners.SystemParameterInvalid=...
            addlistener(self.Model,'SystemParameterInvalid',...
            @(h,data)systemParameterInvalid(self.View,data));
            self.Listeners.ElementParameterInvalid=...
            addlistener(self.Model,'ElementParameterInvalid',...
            @(h,data)elementParameterInvalid(self.View,data));
            self.Listeners.ParameterChanged=...
            addlistener(self.Model,'ParameterChanged',...
            @(h,data)parameterChanged(self.View,data));
            self.Listeners.BandwidthResolutionChanged=...
            addlistener(self.Model,'BandwidthResolutionChanged',...
            @(h,data)bandwidthResolutionChanged(self.View,data));
            self.Listeners.NewModel=...
            addlistener(self.Model,'NewModel',...
            @(h,data)newModel(self,data));
            self.Listeners.NewName=...
            addlistener(self.Model,'NewName',...
            @(h,data)newName(self.View,data.Name));
            self.Listeners.ElementInserted=...
            addlistener(self.Model,'ElementInserted',...
            @(h,data)elementInserted(self.View,data));
            self.Listeners.ElementDeleted=...
            addlistener(self.Model,'ElementDeleted',...
            @(h,data)elementDeleted(self.View,data));
            self.Listeners.SelectedElement=...
            addlistener(self.Model,'SelectedElement',...
            @(h,data)selectedElement(self.View,data));
            if self.View.UseAppContainer
            else
                self.Listeners.ClientAction=...
                addlistener(self.View.Toolstrip.ToolGroup,...
                'ClientAction',...
                @(src,evt)clientActionListener(self.View,src,evt));
            end
        end
    end


    methods(Access=private)

        function listenFileButtons(self)

            items=self.View.Toolstrip.NewBtn.Popup.getChildByIndex();
            if self.View.UseAppContainer
                addlistener(self.View.Toolstrip.NewBtn,'ButtonPushed',...
                @(h,e)newPopupActions(self.Model,items(1).Text,self.View.CanvasFig.Figure));
            else
                addlistener(self.View.Toolstrip.NewBtn,'ButtonPushed',...
                @(h,e)newPopupActions(self.Model,items(1).Text));
            end
            for i=1:numel(items)
                if self.View.UseAppContainer
                    addlistener(items(i),'ItemPushed',...
                    @(h,e)newPopupActions(self.Model,items(i).Text,self.View.CanvasFig.Figure));
                else
                    addlistener(items(i),'ItemPushed',...
                    @(h,e)newPopupActions(self.Model,items(i).Text));
                end
            end
            if self.View.UseAppContainer
                addlistener(self.View.Toolstrip.OpenBtn,'ButtonPushed',...
                @(h,e)openAction(self.Model,self.View.CanvasFig.Figure));
            else
                addlistener(self.View.Toolstrip.OpenBtn,'ButtonPushed',...
                @(h,e)openAction(self.Model));
            end
            addlistener(self.View.Toolstrip.SaveBtn,'ButtonPushed',...
            @(h,e)saveAction(self.Model));
            items=self.View.Toolstrip.SaveBtn.Popup.getChildByIndex();
            for i=1:numel(items)
                addlistener(items(i),'ItemPushed',...
                @(h,e)savePopupActions(self.Model,items(i).Text));
            end
        end

        function listenAddGallery(self)

            addlistener(self.View.Toolstrip.ElementGalleryItems.Modulator,'ItemPushed',...
            @(h,e)addAction(self.View,'modulator'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.Demodulator,'ItemPushed',...
            @(h,e)addAction(self.View,'demodulator'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.Amplifier,'ItemPushed',...
            @(h,e)addAction(self.View,'amplifier'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.seriesRLC,'ItemPushed',...
            @(h,e)addAction(self.View,'seriesRLC'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.shuntRLC,'ItemPushed',...
            @(h,e)addAction(self.View,'shuntRLC'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.Attenuator,'ItemPushed',...
            @(h,e)addAction(self.View,'Attenuator'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.RFantenna,'ItemPushed',...
            @(h,e)addAction(self.View,'RFantenna'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.S_Parameters,'ItemPushed',...
            @(h,e)addAction(self.View,'nport'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.generic,'ItemPushed',...
            @(h,e)addAction(self.View,'rfelement'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.filter,'ItemPushed',...
            @(h,e)addAction(self.View,'filter'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.txline,'ItemPushed',...
            @(h,e)addAction(self.View,'txline'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.Phaseshift,'ItemPushed',...
            @(h,e)addAction(self.View,'Phaseshift'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.MixerIMT,'ItemPushed',...
            @(h,e)addAction(self.View,'MixerIMT'));

            addlistener(self.View.Toolstrip.ElementGalleryItems.Receiver,'ItemPushed',...
            @(h,e)addAction(self.View,'Receiver'));
            addlistener(self.View.Toolstrip.ElementGalleryItems.TxRxAntenna,'ItemPushed',...
            @(h,e)addAction(self.View,'TxRxAntenna'));

            addlistener(self.View.Toolstrip.ElementGalleryItems.lcladder,'ItemPushed',...
            @(h,e)addAction(self.View,'lcladder'));


        end

        function listenDeleteButton(self)

            addlistener(self.View.Toolstrip.DeleteBtn,'ButtonPushed',...
            @(h,e)deleteAction(self.View));
        end

        function listenHBButton(self)

            addlistener(self.View.Toolstrip.HBBtn,'ButtonPushed',...
            @(h,e)HBClicked(self.View.Parameters));
            addlistener(self.View.Toolstrip.AutoUpdateCheckbox,'ValueChanged',...
            @(h,e)AutoUpdateToggled(self.View.Parameters));
        end

        function listenPlotFrequency(self)


            addlistener(self.View.Toolstrip.PlotBandwidthEdit,'ValueChanged',...
            @(h,e)parameterChanged(self.View.Parameters.SystemDialog,e));
            addlistener(self.View.Toolstrip.PlotBandwidthUnits,'ValueChanged',...
            @(h,e)parameterChanged(self.View.Parameters.SystemDialog,e));
            addlistener(self.View.Toolstrip.PlotResolutionEdit,'ValueChanged',...
            @(h,e)parameterChanged(self.View.Parameters.SystemDialog,e));
        end

        function listenPlotButton(self)

            items=self.View.Toolstrip.PlotBtn.Popup.getChildByIndex();
            addlistener(self.View.Toolstrip.PlotBtn,'ButtonPushed',...
            @(h,e)addPlotFigure(self.View,self.Model.Budget,items(1),1,0));
            for i=1:numel(items)
                if isa(items(i),'matlab.ui.internal.toolstrip.ListItem')
                    addlistener(items(i),'ItemPushed',...
                    @(h,e)addPlotFigure(self.View,self.Model.Budget,items(i),1,0));
                elseif isa(items(i),...
                    'matlab.ui.internal.toolstrip.ListItemWithPopup')
                    subItems=items(i).Popup.getChildByIndex();
                    for j=1:numel(subItems)
                        addlistener(subItems(j),'ItemPushed',...
                        @(h,e)addPlotFigure(self.View,self.Model.Budget,...
                        subItems(j),0,0));
                    end
                end
            end
        end

        function listen2DPlotButton(self)

            items=self.View.Toolstrip.PlotBtn2D.Popup.getChildByIndex();
            addlistener(self.View.Toolstrip.PlotBtn2D,'ButtonPushed',...
            @(h,e)addPlotFigure(self.View,self.Model.Budget,items(1),1,1));
            for i=1:numel(items)
                addlistener(items(i),'ItemPushed',...
                @(h,e)addPlotFigure(self.View,self.Model.Budget,items(i),1,1));
            end
        end

        function listenSmithPlotButton(self)

            addlistener(self.View.Toolstrip.SmithBtn,'ButtonPushed',...
            @(h,e)addSParameterFigure(self.View,self.Model.Budget,self.View.Toolstrip.SmithBtn));
        end

        function listenPolarPlotButton(self)

            items=self.View.Toolstrip.PolarBtn.Popup.getChildByIndex();
            addlistener(self.View.Toolstrip.PolarBtn,'ButtonPushed',...
            @(h,e)addPolarFigure(self.View,self.Model.Budget,...
            items(1)));
            for i=1:numel(items)
                addlistener(items(i),'ItemPushed',...
                @(h,e)addPolarFigure(self.View,self.Model.Budget,...
                items(i)));
            end
        end

        function listenSettingsButton(self)

            addlistener(self.View.Toolstrip.SettingsBtn,'ButtonPushed',...
            @(h,e)SettingsButtonClicked(self.View.Toolstrip.SystemParameters));
        end

        function listenViewButton(self)

            addlistener(self.View.Toolstrip.DefaultLayoutBtn,'ButtonPushed',...
            @(h,e)tileDefaultLayout(self.View));
        end

        function listenExportButton(self)

            addlistener(self.View.Toolstrip.ExportBtn,...
            'ButtonPushed',@(h,e)exportAction(self.Model));
            items=self.View.Toolstrip.ExportBtn.Popup.getChildByIndex();
            for i=1:numel(items)
                if i~=1&&i~=4
                    addlistener(items(i),'ItemPushed',...
                    @(h,e)exportPopupActions(self.Model,items(i).Text));
                end
            end
        end
    end


    methods(Hidden)

        function newModel(self,data)

            self.Listeners.SystemParameterChanged.Enabled=false;
            newView(self.View,data.Name,data.Budget)
            self.Listeners.SystemParameterChanged.Enabled=true;
        end
    end
end





