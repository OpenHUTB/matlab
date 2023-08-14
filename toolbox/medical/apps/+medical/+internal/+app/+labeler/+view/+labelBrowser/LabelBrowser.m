classdef LabelBrowser<images.internal.app.utilities.EntryPanel




    events


ColorChanged


NameChanged


LabelAdded


BringAppToFront


LabelVisibilityChanged

    end


    properties(Access=protected,Transient)

AddButton

StartupPanel
StartupLabel

        NameListener event.listener

        Tag="LabelBrowser"

    end

    properties(Dependent,Hidden)

NumLabels
    end

    properties(Access=protected,Constant)
        AddButtonWidth=190;
    end

    methods


        function self=LabelBrowser(hParent)

            pos=[1,1,hParent.Position(3:4)];

            self@images.internal.app.utilities.EntryPanel(hParent,pos,'UseHeader',true);

            self.createAddButton(hParent,pos);
            self.createStartupLabel(hParent,pos);

            hFig=ancestor(hParent,'figure');

            self.NameListener=event.listener(hFig,'WindowMousePress',@(src,evt)nameClicked(self,evt));
            set(self.Panel,'AutoResizeChildren','off');

        end


        function disable(self)

            if~isempty(self.NameListener)
                self.NameListener.Enabled=false;
            end

            self.AddButton.Enable='off';

            for idx=1:numel(self.Entries)
                disable(self.Entries(idx));
            end

        end


        function enable(self)

            self.AddButton.Enable='on';

            for idx=1:numel(self.Entries)
                enable(self.Entries(idx));
            end

            if~isempty(self.NameListener)
                self.NameListener.Enabled=true;
            end

        end


        function color=getCurrentColor(self)
            if self.Current>0
                color=get(self.Entries(self.Current),'Color');
            else
                color=[0,0,0];
            end
        end


        function TF=isCurrentVisible(self)
            if self.Current>0
                TF=get(self.Entries(self.Current),'LabelVisible');
            else
                TF=false;
            end
        end


        function resize(self,pos)%# Overload

            headerpos=pos;

            pos(4)=getPixelsAllowed(self,pos);
            pos(3)=pos(3)-self.ScrollBarWidth;

            if any(pos<1)
                return;
            end

            if self.UseHeader
                resizeHeader(self,headerpos);
            end
            resizeStartupPanel(self,headerpos);

            scrollbarPosition=[pos(3)+1,pos(2),self.ScrollBarWidth,pos(4)];
            resize(self.ScrollBar,scrollbarPosition);

            positionEntries(self,pos);

        end


        function showStartupMessage(self,TF)
            self.StartupPanel.Visible=TF;
        end

    end


    methods(Access=protected)


        function reorderRequired=updateEntryData(self,names,color,labelVisible)%# Overload

            reorderRequired=false;

            for idx=1:numel(names)

                if idx>numel(self.Entries)
                    addToEntryList(self,names{idx},color(idx,:),labelVisible(idx,:));
                    reorderRequired=true;
                else

                    self.Entries(idx).Name=names{idx};
                    self.Entries(idx).Color=color(idx,:);
                    self.Entries(idx).LabelVisible=labelVisible(idx,:);

                end

            end

            if idx<numel(self.Entries)

                delete(self.Entries(idx+1:end));
                self.Entries(idx+1:end)=[];
                reorderRequired=true;

            end

        end


        function evt=packageEntrySelectedEventData(self)
            evt=images.internal.app.segmenter.volume.events.LabelSelectedEventData(...
            self.Entries(self.Current).Name,self.Entries(self.Current).Color);
        end


        function nameClicked(self,evt)


            if isa(evt.HitObject,'matlab.ui.control.EditField')&&strcmp(evt.HitObject.Editable,'off')
                if numel(self.Entries)>1
                    idx=find(cellfun(@(x)eq(evt.HitObject,x),get(self.Entries,'NameUI')));
                    nameClicked(self.Entries(idx),evt.HitObject);
                elseif numel(self.Entries)==1
                    nameClicked(self.Entries(1),evt.HitObject);
                end
            end

        end


        function nameChanged(self,evt)
            notify(self,'NameChanged',evt);
        end


        function colorChanged(self,evt)
            notify(self,'ColorChanged',evt);
        end


        function newEntry=createEntry(self,varargin)

            newEntry=medical.internal.app.labeler.view.labelBrowser.LabelEntry(self.Panel,getNextLocation(self),varargin{1},varargin{2},varargin{3});

            addlistener(newEntry,'ColorChanged',@(src,evt)notify(self,'ColorChanged',evt));
            addlistener(newEntry,'NameChanged',@(src,evt)notify(self,'NameChanged',evt));
            addlistener(newEntry,'EntryClicked',@(src,evt)entryClicked(self,src));
            addlistener(newEntry,'EntryRemoved',@(src,evt)entryRemoved(self,evt));
            addlistener(newEntry,'BringAppToFront',@(src,evt)notify(self,'BringAppToFront'));
            addlistener(newEntry,'LabelVisibilityChanged',@(src,evt)notify(self,'LabelVisibilityChanged',evt));

        end


        function createAddButton(self,hfig,pos)%# Overload

            pos(2)=pos(4)-self.HeaderHeight+1;
            pos(4)=self.HeaderHeight;

            self.Header=uipanel('Parent',hfig,...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'Position',pos,...
            'Tag','HeaderPanel',...
            'AutoResizeChildren','off');

            self.AddButton=uibutton('push',...
            'Parent',self.Header,...
            'Enable','on',...
            'Position',[self.Border+1,self.Border+1,self.AddButtonWidth,self.Header.Position(4)-(2*self.Border)],...
            'Text',getString(message('medical:medicalLabeler:createLabelDefinition')),...
            'Icon',fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Add_24.png'),...
            'Tooltip',getString(message('medical:medicalLabeler:createLabelDefinitionDescription')),...
            'HorizontalAlignment','left',...
            'Tag','AddLabelButton',...
            'ButtonPushedFcn',@(~,~)notify(self,'LabelAdded'));

        end


        function createStartupLabel(self,hParent,pos)

            startupPanelHeight=100;
            border=15;

            pos(2)=pos(4)-startupPanelHeight-border+1;
            if self.UseHeader
                pos(2)=pos(2)-self.HeaderHeight;
            end

            pos(4)=100;

            labelPos=[border,1,pos(3)-(2*border),pos(4)];
            labelPos(labelPos<1)=1;

            self.StartupPanel=uipanel('Parent',hParent,...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'Position',pos,...
            'Tag','StartupMessagePanel',...
            'AutoResizeChildren','off');

            self.StartupLabel=uilabel('Parent',self.StartupPanel,...
            'Position',labelPos,...
            'VerticalAlignment','top',...
            'HorizontalAlignment','left',...
            'Tag','StartupLabel',...
            'WordWrap','on',...
            'Text',getString(message('medical:medicalLabeler:startupMsgLabelBrowser')));
            self.StartupLabel.FontSize=self.StartupLabel.FontSize+1;

        end


        function resizeHeader(self,pos)%# Overload
            pos(2)=pos(4)-self.HeaderHeight+1;
            pos(4)=self.HeaderHeight;

            self.Header.Position=pos;
            self.AddButton.Position=[self.Border+1,self.Border+1,self.AddButtonWidth,self.Header.Position(4)-(2*self.Border)];
        end


        function resizeStartupPanel(self,pos)

            startupPanelHeight=100;
            border=15;

            pos(2)=pos(4)-startupPanelHeight-border+1;
            if self.UseHeader
                pos(2)=pos(2)-self.HeaderHeight;
            end

            pos(4)=100;

            labelPos=[border,1,self.StartupPanel.Position(3)-(2*border),self.StartupLabel.Position(4)];
            labelPos(labelPos<1)=1;

            self.StartupPanel.Position=pos;
            self.StartupLabel.Position=labelPos;

        end

    end


    methods

        function numLabels=get.NumLabels(self)
            numLabels=numel(self.Entries);
        end

    end


end