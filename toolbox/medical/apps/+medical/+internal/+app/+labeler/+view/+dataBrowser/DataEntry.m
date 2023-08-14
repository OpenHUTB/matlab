classdef DataEntry<handle&matlab.mixin.SetGet




    properties(Dependent)

DataName

LabelStatus

Selected

Enabled

    end

    properties

Panel
Grid
ContextMenu

NameUI
LabelStatusBadge

        SelectedInternal(1,1)logical=false;

    end

    properties(Access=protected)

        UnselectedColor(1,3)single
        UnselectedTextColor(1,3)single

        SelectedColor(1,3)single=[0.349,0.667,0.847];
        SelectedTextColor(1,3)single=[1,1,1];

    end

    properties(Access=protected,Constant)

        LeftBorder(1,1)double=5;

    end

    events

ReadDataRequested

CopyDataLocationRequested
CopyLabelLocationRequested

RemoveDataRequested
RemoveLabelsRequested

    end

    methods

        function self=DataEntry(hPanel,dataName,hasLabels)


            hFig=ancestor(hPanel,'figure');
            if~isempty(hFig.Theme)
                self.UnselectedColor=hFig.Theme.ContainerColor;
                self.UnselectedTextColor=hFig.Theme.BaseTextColor;
            else
                self.UnselectedColor=[0.94,0.94,0.94];
                self.UnselectedTextColor=[0,0,0];
            end

            self.Panel=hPanel;

            self.create();

            self.DataName=dataName;
            self.LabelStatus=hasLabels;

        end


        function delete(self)

            delete(self.Panel)
            delete(self.Grid)
            delete(self.NameUI)

        end

    end

    methods(Access=private)

        function create(self)

            self.createContextMenu()

            self.Grid=uigridlayout('Parent',self.Panel,...
            'RowHeight',{22},...
            'ColumnWidth',{'1x',20},...
            'RowSpacing',2,...
            'Padding',[self.LeftBorder,0,0,0],...
            'Scrollable','off',...
            'Tag','EntryGrid',...
            'ContextMenu',self.ContextMenu);

            self.NameUI=uilabel('Parent',self.Grid,...
            'HorizontalAlignment','left',...
            'FontColor',self.UnselectedTextColor,...
            'ContextMenu',self.ContextMenu,...
            'Tag','DataName');
            self.NameUI.Layout.Row=1;
            self.NameUI.Layout.Column=1;

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','NoLabelDataBadgeUnselected_16.png');
            self.LabelStatusBadge=uiimage('Parent',self.Grid,...
            'ImageSource',icon,...
            'HorizontalAlignment','center',...
            'VerticalAlignment','center',...
            'ScaleMethod','none',...
            'Visible','off',...
            'Tooltip',getString(message('medical:medicalLabeler:hasLabelsDescription')),...
            'ContextMenu',self.ContextMenu,...
            'Tag','NoLabelsBadge');
            self.LabelStatusBadge.Layout.Row=1;
            self.LabelStatusBadge.Layout.Column=2;

            set(self.Panel,'ButtonDownFcn',@(src,evt)self.entryClicked());

        end

        function createContextMenu(self)

            self.ContextMenu=uicontextmenu('Parent',ancestor(self.Panel,'figure'));

            uimenu('Parent',self.ContextMenu,...
            'Label',getString(message('medical:medicalLabeler:copyDataLoc')),...
            'MenuSelectedFcn',@(~,~)copyDataLocationRequested(self),...
            'Tag','CopyDataLocation');

            uimenu('Parent',self.ContextMenu,...
            'Label',getString(message('medical:medicalLabeler:copyLabelLoc')),...
            'MenuSelectedFcn',@(~,~)copyLabelLocationRequested(self),...
            'Tag','CopyLabelLocation');









            uimenu('Parent',self.ContextMenu,...
            'Label',getString(message('medical:medicalLabeler:removeLabels')),...
            'Separator',true,...
            'MenuSelectedFcn',@(~,~)removeLabelsRequested(self),...
            'Tag','RemoveLabels');

        end

    end


    methods(Access=protected)

        function readDataRequested(self)
            evt=medical.internal.app.labeler.events.ValueEventData(self.DataName);
            self.notify('ReadDataRequested',evt);
        end

        function copyDataLocationRequested(self)
            evt=medical.internal.app.labeler.events.ValueEventData(self.DataName);
            self.notify('CopyDataLocationRequested',evt);
        end

        function copyLabelLocationRequested(self)
            evt=medical.internal.app.labeler.events.ValueEventData(self.DataName);
            self.notify('CopyLabelLocationRequested',evt);
        end

        function removeDataRequested(self)
            evt=medical.internal.app.labeler.events.ValueEventData(self.DataName);
            self.notify('RemoveDataRequested',evt);
        end

        function removeLabelsRequested(self)
            evt=medical.internal.app.labeler.events.ValueEventData(self.DataName);
            self.notify('RemoveLabelsRequested',evt);
        end

        function entryClicked(self)
            evtData=images.internal.app.volview.events.SelectionChangedEventData(self.Index,true);
            self.notify('EntrySelectionChanged',evtData);
        end

    end


    methods


        function set.DataName(self,dataName)
            self.NameUI.Text=dataName;
        end

        function dataName=get.DataName(self)
            dataName=self.NameUI.Text;
        end


        function set.LabelStatus(self,hasLabels)

            self.LabelStatusBadge.Visible=~hasLabels;



            menuItems=findobj(self.ContextMenu.Children,...
            {'Tag','CopyLabelLocation','-or','Tag','RemoveLabels'});
            if hasLabels
                set(menuItems,'Enable','on');
            else
                set(menuItems,'Enable','off');
            end

        end

        function hasLabels=get.LabelStatus(self)
            hasLabels=~self.LabelStatusBadge.Visible;
        end


        function set.Selected(self,TF)

            if self.SelectedInternal==TF
                return
            end

            if TF

                set(self.Grid,'BackgroundColor',self.SelectedColor);
                set(self.NameUI,'FontColor',self.SelectedTextColor);
                set(self.NameUI,'BackgroundColor',self.SelectedColor);
                set(self.LabelStatusBadge,'BackgroundColor',self.SelectedColor);

                icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','NoLabelDataBadgeSelected_16.png');
                self.LabelStatusBadge.ImageSource=icon;

                self.readDataRequested();

            else

                set(self.Grid,'BackgroundColor',self.Grid.Parent.BackgroundColor);
                set(self.NameUI,'FontColor',self.UnselectedTextColor);
                set(self.NameUI,'BackgroundColor',self.Grid.Parent.BackgroundColor);
                set(self.LabelStatusBadge,'BackgroundColor',self.Grid.Parent.BackgroundColor);

                icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','NoLabelDataBadgeUnselected_16.png');
                self.LabelStatusBadge.ImageSource=icon;

            end

            self.SelectedInternal=TF;

        end

        function TF=get.Selected(self)

            TF=self.SelectedInternal;

        end


        function set.Enabled(self,TF)

            if TF
                self.Grid.ContextMenu=self.ContextMenu;
                self.NameUI.ContextMenu=self.ContextMenu;
                self.LabelStatusBadge.ContextMenu=self.ContextMenu;
            else
                self.Grid.ContextMenu=[];
                self.NameUI.ContextMenu=[];
                self.LabelStatusBadge.ContextMenu=[];
            end
            self.NameUI.Enable=TF;
            self.LabelStatusBadge.Enable=TF;

        end

    end

end
