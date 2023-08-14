classdef DataBrowser<handle




    properties(Dependent,Hidden)

NumEntries

Enabled

    end

    properties(Access=protected)

        CurrentIdx=0;

        AddSeparatorAfterEntry(1,1)logical{mustBeNonempty}=true

ContextMenu

    end

    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)

Panel

EntryGrid

        DataEntries medical.internal.app.labeler.view.dataBrowser.DataEntry
        IndividualEntryGrids matlab.ui.container.GridLayout

MousePressListener

    end

    properties(Access=private,Constant)

        EntryHeight=24;

        SeparatorHeight=2;
        SeparatorColor=[0.75,0.75,0.75];

    end

    events

ReadDataRequested

CopyDataLocationRequested
CopyLabelLocationRequested

RemoveDataRequested
RemoveLabelsRequested

    end

    methods

        function self=DataBrowser(hParent)

            self.create(hParent);

        end


        function add(self,dataNames,hasLabels)

            if self.AddSeparatorAfterEntry
                entryHeight=self.EntryHeight+self.SeparatorHeight;
                newEntryGridRowHeight={self.EntryHeight,self.SeparatorHeight};
            else
                entryHeight=self.EntryHeight;
                newEntryGridRowHeight={self.EntryHeight};
            end

            numEntries=length(dataNames);

            for idx=1:numEntries

                self.EntryGrid.RowHeight{end}=entryHeight;
                self.EntryGrid.RowHeight{end+1}='1x';

                rowIdx=length(self.EntryGrid.RowHeight)-1;


                currEntryGrid=uigridlayout('Parent',self.EntryGrid,...
                'RowHeight',newEntryGridRowHeight,...
                'ColumnWidth',{'1x'},...
                'Padding',0,...
                'RowSpacing',0,...
                'ColumnSpacing',0,...
                'Scrollable','of');
                currEntryGrid.Layout.Row=rowIdx;
                currEntryGrid.Layout.Column=1;

                entryPanel=uipanel('Parent',currEntryGrid,...
                'BorderType','none');
                entryPanel.Layout.Row=1;
                entryPanel.Layout.Column=1;

                if self.AddSeparatorAfterEntry
                    separatorRowIdx=2;
                    self.addSeparator(currEntryGrid,separatorRowIdx);
                end

                dataEntry=medical.internal.app.labeler.view.dataBrowser.DataEntry(entryPanel,dataNames(idx),hasLabels(idx));
                self.DataEntries(end+1)=dataEntry;
                self.IndividualEntryGrids(end+1)=currEntryGrid;

                addlistener(dataEntry,'ReadDataRequested',@(src,evt)self.notify('ReadDataRequested',evt));
                addlistener(dataEntry,'CopyDataLocationRequested',@(src,evt)self.notify('CopyDataLocationRequested',evt));
                addlistener(dataEntry,'CopyLabelLocationRequested',@(src,evt)self.notify('CopyLabelLocationRequested',evt));
                addlistener(dataEntry,'RemoveDataRequested',@(src,evt)self.notify('RemoveDataRequested',evt));
                addlistener(dataEntry,'RemoveLabelsRequested',@(src,evt)self.notify('RemoveLabelsRequested',evt));

                if length(self.DataEntries)==1

                    dataEntry.Selected=true;
                    self.CurrentIdx=1;

                end

            end

        end


        function remove(self,dataName)

            numEntries=length(self.DataEntries);

            removeIdx=self.findDataEntryIndex(dataName);



            for idx=removeIdx+1:numEntries
                self.IndividualEntryGrids(idx).Layout.Row=idx-1;
            end


            currRowHeights=self.EntryGrid.RowHeight;
            currRowHeights{end-1}='1x';
            currRowHeights(end)=[];
            self.EntryGrid.RowHeight=currRowHeights;


            removeEntry=self.DataEntries(removeIdx);
            delete(self.IndividualEntryGrids(removeIdx));
            delete(removeEntry);

            self.DataEntries(removeIdx)=[];
            self.IndividualEntryGrids(removeIdx)=[];


            if isempty(self.DataEntries)
                self.CurrentIdx=[];
            else
                self.DataEntries(self.CurrentIdx).Selected=true;
            end

        end


        function updateLabelStatus(self,dataName,hasLabels)

            idx=self.findDataEntryIndex(dataName);
            self.DataEntries(idx).LabelStatus=hasLabels;

        end


        function clear(self)

            delete(self.DataEntries);
            delete(self.IndividualEntryGrids);

            self.DataEntries=medical.internal.app.labeler.view.dataBrowser.DataEntry.empty;
            self.IndividualEntryGrids=matlab.ui.container.GridLayout.empty;
            self.CurrentIdx=0;


            self.EntryGrid.RowHeight={'1x'};
            self.EntryGrid.ColumnWidth={'1x'};

        end


        function enable(self)
            self.Enabled=true;
        end


        function disable(self)
            self.Enabled=false;
        end

    end


    methods


        function numEntries=get.NumEntries(self)
            numEntries=numel(self.DataEntries);
        end


        function set.Enabled(self,TF)

            self.MousePressListener.Enabled=TF;

            for idx=1:self.NumEntries
                self.DataEntries(idx).Enabled=TF;
            end

        end

    end

    methods(Access=private)


        function create(self,hParent)

            grid=uigridlayout('Parent',hParent,...
            'RowHeight',{'1x'},...
            'ColumnWidth',{'1x'},...
            'Padding',0,...
            'RowSpacing',0,...
            'ColumnSpacing',0,...
            'Scrollable','off');

            self.EntryGrid=uigridlayout('Parent',grid,...
            'RowHeight',{'1x'},...
            'ColumnWidth',{'1x'},...
            'Padding',0,...
            'RowSpacing',0,...
            'ColumnSpacing',5,...
            'Scrollable','on');
            self.EntryGrid.Layout.Row=1;
            self.EntryGrid.Layout.Column=1;

            hFig=ancestor(hParent,'figure');
            self.MousePressListener=event.listener(hFig,'WindowMousePress',@(src,evt)self.mousePressed(evt));

        end


        function addSeparator(self,hParent,rowIdx)

            columnIdx=1;
            totalColumns=length(hParent.ColumnWidth);
            if totalColumns>1
                columnIdx=[1,totalColumns];
            end

            hPanel=uipanel('Parent',hParent,...
            'BorderType','none',...
            'Title','',...
            'Units','normalized',...
            'BackgroundColor',self.SeparatorColor);
            hPanel.Layout.Row=rowIdx;
            hPanel.Layout.Column=columnIdx;

        end


        function idx=findDataEntryIndex(self,dataName)

            dataName=string(dataName);

            dataNames=get(self.DataEntries,'DataName');
            if~iscell(dataNames)
                dataNames={dataNames};
            end
            idx=find(cellfun(@(x)ismember(x,dataName),dataNames));

        end

    end


    methods(Access=protected)


        function mousePressed(self,evt)

            if isequal(evt.Source.SelectionType,'alt')

                return
            end



            if isa(evt.HitObject,'matlab.ui.control.Label')

                switch evt.HitObject.Tag

                case 'DataName'
                    entries=get(self.DataEntries,'NameUI');
                otherwise
                    entries={};

                end

            elseif isa(evt.HitObject,'matlab.ui.container.GridLayout')&&isequal(evt.HitObject,'EntryGrid')
                entries=get(self.DataEntries,'Grid');

            elseif isa(evt.HitObject,'matlab.ui.control.Image')
                entries=get(self.DataEntries,'LabelStatusBadge');

            else
                entries={};

            end

            if isempty(entries)
                return
            end


            if~iscell(entries)
                entries={entries};
            end
            idx=find(cellfun(@(x)eq(evt.HitObject,x),entries));

            if isempty(idx)||idx==self.CurrentIdx

                return
            end

            self.DataEntries(self.CurrentIdx).Selected=false;

            self.DataEntries(idx).Selected=true;
            self.CurrentIdx=idx;

        end

    end

end
