classdef Labels<images.internal.app.utilities.EntryPanel




    events


ColorChanged


NameChanged


LabelAdded


BringAppToFront

    end


    properties(GetAccess={?images.uitest.factory.Tester,...
        ?uitest.factory.Tester,...
        ?medical.internal.app.labeler.view.LabelBrowser},...
        SetAccess=protected,Transient)

AddButton

        NameListener event.listener

        Tag="Labels"

    end

    properties(Dependent,Hidden)

NumLabels
    end


    methods




        function self=Labels(hfig,pos)

            self@images.internal.app.utilities.EntryPanel(hfig,pos,'UseHeader',true);

            createAddButton(self,hfig,pos);

            if isa(getCanvas(self.Panel),'matlab.graphics.primitive.canvas.HTMLCanvas')

                self.NameListener=event.listener(hfig,'WindowMousePress',@(src,evt)nameClicked(self,evt));
                set(self.Panel,'AutoResizeChildren','off');

            end

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

    end


    methods(Access=protected)


        function reorderRequired=updateEntryData(self,names,color)

            reorderRequired=false;

            for idx=1:numel(names)



                if idx>numel(self.Entries)
                    addToEntryList(self,names{idx},color(idx+1,:));
                    reorderRequired=true;
                else

                    self.Entries(idx).Name=names{idx};
                    self.Entries(idx).Color=color(idx+1,:);

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


        function resizeHeader(self,pos)
            pos(2)=pos(4)-self.HeaderHeight+1;
            pos(4)=self.HeaderHeight;

            self.Header.Position=pos;
            set(self.AddButton,'Position',[self.Border+1,self.Border+1,self.Header.Position(4)-self.Border,self.Header.Position(4)-(2*self.Border)]);
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

            newEntry=images.internal.app.segmenter.volume.display.Entry(self.Panel,getNextLocation(self),varargin{1},varargin{2});

            addlistener(newEntry,'ColorChanged',@(src,evt)colorChanged(self,evt));
            addlistener(newEntry,'NameChanged',@(src,evt)nameChanged(self,evt));
            addlistener(newEntry,'EntryClicked',@(src,evt)entryClicked(self,src));
            addlistener(newEntry,'EntryRemoved',@(src,evt)entryRemoved(self,evt));
            addlistener(newEntry,'BringAppToFront',@(src,evt)notify(self,'BringAppToFront'));

        end


        function createAddButton(self,hfig,pos)

            pos(2)=pos(4)-self.HeaderHeight+1;
            pos(4)=self.HeaderHeight;

            self.Header=uipanel('Parent',hfig,...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'Position',pos,...
            'Tag','HeaderPanel');

            if isa(getCanvas(self.Header),'matlab.graphics.primitive.canvas.HTMLCanvas')
                set(self.Header,'AutoResizeChildren','off');
            end

            if isa(getCanvas(self.Header),'matlab.graphics.primitive.canvas.HTMLCanvas')
                self.AddButton=uibutton('push',...
                'Parent',self.Header,...
                'Enable','on',...
                'Position',[self.Border+1,self.Border+1,self.Header.Position(4)-self.Border,self.Header.Position(4)-(2*self.Border)],...
                'Text','',...
                'Icon',fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Add_24.png'),...
                'Tooltip',getString(message('images:segmenter:addLabelTooltip')),...
                'HorizontalAlignment','left',...
                'Tag','AddLabelButton',...
                'ButtonPushedFcn',@(~,~)notify(self,'LabelAdded'));

            else

                addIcon=im2double(imread(fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Add_24.png')));
                addIcon(addIcon==0)=NaN;

                self.AddButton=uicontrol('Style','pushbutton',...
                'Parent',self.Header,...
                'Units','pixels',...
                'Enable','on',...
                'Position',[self.Border+1,self.Border+1,self.Header.Position(4)-self.Border,self.Header.Position(4)-(2*self.Border)],...
                'CData',addIcon,...
                'Tooltip',getString(message('images:segmenter:addLabelTooltip')),...
                'HorizontalAlignment','left',...
                'Tag','AddLabelButton',...
                'Callback',@(~,~)notify(self,'LabelAdded'));
            end

        end

    end


    methods

        function numLabels=get.NumLabels(self)
            numLabels=numel(self.Entries);
        end

    end


end