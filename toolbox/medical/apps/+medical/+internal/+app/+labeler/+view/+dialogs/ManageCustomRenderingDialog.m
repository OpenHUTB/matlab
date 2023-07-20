classdef ManageCustomRenderingDialog<images.internal.app.utilities.OkCancelDialog




    properties

        RemoveRenderingList=string.empty();
    end


    properties(Access=protected)

RenderingListUI
RemoveUI

    end

    methods

        function self=ManageCustomRenderingDialog(loc,names,tags)

            dlgTitle=getString(message('medical:medicalLabeler:manageCustomRendering'));
            self=self@images.internal.app.utilities.OkCancelDialog(loc,dlgTitle);

            self.Size=[350,260];

            self.create();
            self.layoutDialog(names,tags);

        end




        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);

            self.Ok.Enable='off';

        end

    end

    methods(Access=protected)

        function layoutDialog(self,names,tags)

            border=5;
            topBorder=10;
            controlSize=self.ButtonSize(2);

            bottomStart=self.Ok.Position(2)+self.Ok.Position(4)+border;

            pos=[border,...
            bottomStart,...
            self.FigureHandle.Position(3)-2*border,...
            self.FigureHandle.Position(4)-bottomStart-topBorder];
            panel=uipanel('Parent',self.FigureHandle,...
            'Position',pos,...
            'BorderType','none',...
            'HandleVisibility','off');

            grid=uigridlayout('Parent',panel,...
            'RowHeight',{controlSize,'1x',controlSize,15},...
            'ColumnWidth',{self.ButtonSize(1),'1x'},...
            'Padding',0,...
            'RowSpacing',5,...
            'ColumnSpacing',0);

            headingLabel=uilabel('Parent',grid,...
            'Text',getString(message('medical:medicalLabeler:renderingName')),...
            'HandleVisibility','off',...
            'Enable','on',...
            'Tag','HeadingLabel',...
            'HorizontalAlignment','left');
            headingLabel.Layout.Row=1;
            headingLabel.Layout.Column=[1,2];

            self.RenderingListUI=uilistbox('Parent',grid,...
            'Items',names,...
            'ItemsData',tags,...
            'FontSize',12,...
            'Value',{},...
            'MultiSelect','on',...
            'Tag','RenderingList',...
            'ValueChangedFcn',@(~,~)selectFromList(self));
            self.RenderingListUI.Layout.Row=2;
            self.RenderingListUI.Layout.Column=[1,2];

            self.RemoveUI=uibutton('Parent',grid,...
            'ButtonPushedFcn',@(~,~)removeFromList(self),...
            'FontSize',12,...
            'Enable','off',...
            'Text',getString(message('images:segmenter:remove')),...
            'Tag','Remove');
            self.RemoveUI.Layout.Row=3;
            self.RemoveUI.Layout.Column=1;

        end

        function selectFromList(self)

            if isempty(self.RenderingListUI.Value)
                self.RemoveUI.Enable='off';
            else
                self.RemoveUI.Enable='on';
            end

        end

        function removeFromList(self)

            idx=true(size(self.RenderingListUI.Items));

            if~isempty(self.RenderingListUI.Value)

                for i=1:numel(self.RenderingListUI.Value)

                    j=find(self.RenderingListUI.ItemsData==self.RenderingListUI.Value{i});

                    if~isempty(j)
                        self.RemoveRenderingList=[self.RemoveRenderingList,string(self.RenderingListUI.Value{i})];
                        idx(j)=false;
                    end

                end

                self.RenderingListUI.Items=self.RenderingListUI.Items(idx);
                self.RenderingListUI.ItemsData=self.RenderingListUI.ItemsData(idx);
                self.RenderingListUI.Value={};

            end

            self.Ok.Enable='on';
            self.RemoveUI.Enable='off';

        end

    end

end
