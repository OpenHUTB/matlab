classdef LabelsBrowserWeb<images.internal.app.utilities.EntryPanel




    properties(Dependent)

SelectedEntires

LabelConfiguration

    end

    properties(Access=private)

LabelConfigurationInternal

SelectedEntiresInternal

LabelScrollWheelListener
MousePressListener

    end

    events

SelectionChange

    end

    methods

        function self=LabelsBrowserWeb(hPanel)

            self@images.internal.app.utilities.EntryPanel(hPanel,hPanel.Position,'UseHeader',false);

            set(hPanel,'Units','pixels');
            set(self.Panel,'AutoResizeChildren','off');

            pos=[1,1,hPanel.Position(3:4)];
            pos(pos<1)=1;
            self.resize(pos);

            hFig=ancestor(hPanel,'figure');
            self.LabelScrollWheelListener=event.listener(hFig,'WindowScrollWheel',@(src,evt)self.scroll(evt.VerticalScrollCount));
            self.MousePressListener=event.listener(hFig,'WindowMousePress',@(src,evt)self.mousePressed(evt));

        end

        function updateColor(self,idx,newColor)


            set(self.Entries(idx),'Color',newColor);

        end

        function setSelection(self,idx)


            if all(idx<=numel(self.Entries))
                self.SelectedEntires=idx;
                self.notify('SelectionChange');
            end

        end

    end

    methods(Access=private)

        function addLabelEntries(self)

            numLabels=self.LabelConfigurationInternal.NumLabels;

            for idx=1:numLabels

                name=self.LabelConfigurationInternal.LabelNames(idx);
                color=self.LabelConfigurationInternal.LabelColors(idx,:);

                self.add(idx,name,color);
            end

        end

    end


    methods(Access=protected)

        function evt=packageEntrySelectedEventData(self)
            evt=images.internal.app.volview.events.SelectionChangedEventData(self.Current,true);
        end

        function newEntry=createEntry(self,varargin)

            loc=getNextLocation(self);
            newEntry=images.internal.app.volview.Entry(self.Panel,loc,varargin{1},varargin{2},varargin{3});

            addlistener(newEntry,'EntrySelectionChanged',@(src,evt)self.reactToSelectionChanged(evt.Index,evt.Selected));
            addlistener(newEntry,'EntrySelected',@(src,evt)self.reactToSelectionUpdated(evt.Index,evt.Selected));

        end

        function reorderRequired=updateEntryData(~,varargin)


            reorderRequired=false;

        end

    end


    methods(Access=private)

        function reactToSelectionChanged(self,idx,~)

            self.SelectedEntires=idx;
            self.notify('SelectionChange');

        end

        function reactToSelectionUpdated(self,idx,TF)

            selectedEntries=self.SelectedEntires;

            currentIdx=find(selectedEntries==idx);

            if TF

                if isempty(currentIdx)
                    selectedEntries(end+1)=idx;
                    selectedEntries=sort(selectedEntries);
                end

            else
                if~isempty(currentIdx)
                    selectedEntries(currentIdx)=[];
                end

            end

            self.SelectedEntiresInternal=selectedEntries;
            self.notify('SelectionChange');

        end

        function mousePressed(self,evt)


            if isa(evt.HitObject,'matlab.ui.control.Label')
                idx=find(cellfun(@(x)eq(evt.HitObject,x),get(self.Entries,'NameUI')));
                self.reactToSelectionChanged(idx,true);
            end

        end

    end


    methods




        function set.LabelConfiguration(self,labelConfig)

            if isempty(labelConfig)
                self.Entries=images.internal.app.volview.Entry.empty();
                return
            end

            if isempty(self.LabelConfigurationInternal)

                self.LabelConfigurationInternal=labelConfig;

                self.addLabelEntries();


                self.top();

                self.SelectedEntires=1;
                self.notify('SelectionChange');

            else
                if self.LabelConfigurationInternal.NumLabels~=labelConfig.NumLabels

                    self.Entries=images.internal.app.volview.Entry.empty();
                    self.LabelConfigurationInternal=labelConfig;

                    self.addLabelEntries();


                    self.top();

                    self.SelectedEntires=1;
                    self.notify('SelectionChange');

                    self.SelectedEntires=1;

                else

                    self.LabelConfigurationInternal=labelConfig;


                    for idx=1:numel(self.Entries)

                        newColor=self.LabelConfigurationInternal.LabelColors(idx,:);
                        oldColor=self.Entries(idx).Color;
                        if~isequal(newColor,oldColor)
                            self.Entries(idx).Color=newColor;
                        end

                    end

                end

            end


        end

        function labelConfig=get.LabelConfiguration(self)
            labelConfig=self.LabelConfigurationInternal;
        end




        function set.SelectedEntires(self,selectedIdx)

            self.SelectedEntiresInternal=selectedIdx;

            selectionMask=false(1,numel(self.Entries));
            selectionMask(selectedIdx)=true;


            for idx=1:numel(selectionMask)
                self.Entries(idx).Selected=selectionMask(idx);
            end

        end

        function selectedEntries=get.SelectedEntires(self)
            selectedEntries=self.SelectedEntiresInternal;
        end




        function height=getUsedHeight(self)



            height=self.EntryHeight*numel(self.Entries);
            if self.UseHeader
                height=height+self.HeaderHeight;
            end
        end

    end

end
