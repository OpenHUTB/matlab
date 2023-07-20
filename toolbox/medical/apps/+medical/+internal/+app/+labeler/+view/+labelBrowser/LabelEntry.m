classdef LabelEntry<handle&matlab.mixin.SetGet




    events


ColorChanged


NameChanged


EntryRemoved


EntryClicked


BringAppToFront


LabelVisibilityChanged

    end


    properties(Dependent)

Selected


Editable


Deletable


Selectable

    end


    properties


        Color(1,3)single=[0,0,0];


        Name char='';


        LabelVisible(1,1)logical=true;


        Width(1,1)double{mustBePositive}=1;


        Y(1,1)double=1;

        HighlightColor(1,3)single=[0.94,0.94,0.94];

    end


    properties(GetAccess={...
        ?medical.internal.app.labeler.view.labelBrowser.LabelBrowser
        ?uitest.factory.Tester
        },...
        SetAccess=protected,Transient)

        Panel matlab.ui.container.Panel

LabelVisibleUI
NameUI
ColorUI

ContextMenu

    end


    properties(Access=protected,Hidden,Transient)

        ColorListener event.listener
        NameListener event.listener
        VisibleListener event.listener

        Dirty(1,1)logical=false;

        SelectedInternal(1,1)logical=false;

    end

    properties(Access=protected)

        SelectedColor(1,3)single=[0.349,0.667,0.847];
        SelectedTextColor(1,3)single=[1,1,1];

UnselectedColor
UnselectedTextColor

    end

    properties(Constant,Hidden)


        X=1;


        Height=20;


        Border=2;

    end


    methods


        function self=LabelEntry(hpanel,yloc,name,color,visible)


            hFig=ancestor(hpanel,'figure');
            if~isempty(hFig.Theme)
                self.UnselectedColor=hFig.Theme.ContainerColor;
                self.UnselectedTextColor=hFig.Theme.BaseTextColor;
            else
                self.UnselectedColor=[0.94,0.94,0.94];
                self.UnselectedTextColor=[0,0,0];
            end

            self.Width=hpanel.Position(3);
            self.Y=yloc;

            self.createUI(hpanel);

            self.Name=name;
            self.Color=color;
            self.LabelVisible=visible;

        end


        function enable(self)

            self.NameListener.Enabled=true;
            self.ColorListener.Enabled=true;
            self.VisibleListener.Enabled=true;

        end


        function disable(self)

            self.NameListener.Enabled=false;
            self.ColorListener.Enabled=false;
            self.VisibleListener.Enabled=false;

        end


        function delete(self)

            delete(self.Panel)
            delete(self.NameUI)
            delete(self.ColorUI)
            delete(self.LabelVisibleUI)

        end


        function deactivate(self)



            if self.Dirty






                self.Dirty=false;
                set(self.NameUI,'Editable','off');

            end

        end

    end


    methods(Hidden)


        function nameClicked(self,src)

            if strcmp(images.roi.internal.getClickType(ancestor(src,'figure')),'left')

                self.Dirty=true;
                set(self.NameUI,'Editable','on','BackgroundColor',[1,1,1],'FontColor',[0,0,0]);

            end

            notify(self,'EntryClicked');

        end

    end


    methods(Access=private)


        function colorClicked(self,src)

            if strcmp(images.roi.internal.getClickType(ancestor(src,'figure')),'double')||...
                (isa(src,'matlab.ui.control.Image')&&self.Selected)

                RGB=uisetcolor(self.Color);
                self.notify('BringAppToFront');

                if~isequal(self.Color,RGB)

                    self.Color=RGB;
                    notify(self,'ColorChanged',images.internal.app.segmenter.volume.events.ColorChangedEventData(...
                    self.Name,self.Color));

                end

            end

            notify(self,'EntryClicked');

        end


        function labelVisibleClicked(self,src)

            if strcmp(images.roi.internal.getClickType(ancestor(src,'figure')),'left')

                self.LabelVisible=~self.LabelVisible;

                evt=medical.internal.app.labeler.events.LabelChangedEventData(self.Name,self.LabelVisible);
                self.notify('LabelVisibilityChanged',evt);

            end

            notify(self,'EntryClicked');

        end


        function nameChanged(self)

            self.NameUI.Editable='off';
            val=self.NameUI.Value;
            if isempty(val)
                self.NameUI.Value=self.Name;
                return
            end

            oldName=self.Name;
            self.Name=val;

            self.Selected=true;



            notify(self,'NameChanged',images.internal.app.segmenter.volume.events.NameChangedEventData(...
            oldName,val));

        end


        function createUI(self,hpanel)

            cmenu=uicontextmenu(ancestor(hpanel,'figure'),'ContextMenuOpeningFcn',@(src,evt)openContextMenu(self,src));
            uimenu(cmenu,'Label',getString(message('images:segmenter:delete')),...
            'MenuSelectedFcn',@(~,~)removeEntry(self),'Tag','Delete');
            self.ContextMenu=cmenu;

            self.Panel=uipanel('Parent',hpanel,...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'BorderType','none',...
            'Position',getPanelPosition(self),...
            'ContextMenu',self.ContextMenu);

            try %#ok<TRYNC>
                set(self.Panel,'ButtonDownFcn',@(src,evt)nameClicked(self,src));
            end


            self.LabelVisibleUI=uiimage('Parent',self.Panel,...
            'ScaleMethod','fill',...
            'Position',getVisibleIconPosition(self),...
            'Tag','LabelVisible',...
            'ContextMenu',self.ContextMenu);

            self.NameUI=uieditfield(...
            'Parent',self.Panel,...
            'Enable','on',...
            'Editable','off',...
            'Position',getNamePosition(self),...
            'Value',self.Name,...
            'HorizontalAlignment','left',...
            'ValueChangingFcn',@(src,evt)nameClicked(self,src),...
            'ValueChangedFcn',@(~,~)nameChanged(self),...
            'Tag','LabelName',...
            'ContextMenu',self.ContextMenu);

            self.ColorUI=uiimage('Parent',self.Panel,...
            'ScaleMethod','fill',...
            'Position',getColorPosition(self),...
            'Tag','LabelColor',...
            'ImageSource',zeros([20,20,3]),...
            'ContextMenu',self.ContextMenu);

            self.NameListener=event.listener(self.NameUI,'ButtonDown',@(src,evt)nameClicked(self,src));
            self.ColorListener=event.listener(self.ColorUI,'ImageClicked',@(src,evt)colorClicked(self,src));
            self.VisibleListener=event.listener(self.LabelVisibleUI,'ImageClicked',@(src,evt)labelVisibleClicked(self,src));

        end


        function pos=getNamePosition(self)

            pos=[1+self.Border+self.Height+(2*self.Border),...
            1+self.Border,...
            self.Width-(1+self.Border+self.Height+(2*self.Border))-self.Border-self.Height,...
            self.Height];

        end


        function pos=getPanelPosition(self)
            pos=[self.X,self.Y,self.Width,self.Height+(2*self.Border)];
        end


        function pos=getColorPosition(self)
            pos=[self.Width-self.Height-self.Border,...
            1+self.Border,...
            self.Height,...
            self.Height];
        end


        function pos=getVisibleIconPosition(self)
            pos=[1+self.Border,...
            1+self.Border,...
            self.Height,...
            self.Height];
        end


        function updateColor(self)
            self.ColorUI.ImageSource=repmat(permute(self.Color,[1,3,2]),[20,20,1]);
        end


        function updateName(self)
            self.NameUI.Value=self.Name;
        end


        function updateLabelVisible(self)
            if self.LabelVisible
                icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','Show_20.png');
            else
                icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','Hide_20.png');
            end
            self.LabelVisibleUI.ImageSource=icon;
        end


        function updatePosition(self)
            if~isempty(self.NameUI)
                set(self.Panel,'Position',getPanelPosition(self));
                set(self.NameUI,'Position',getNamePosition(self));
                set(self.ColorUI,'Position',getColorPosition(self));
                set(self.LabelVisibleUI,'Position',getVisibleIconPosition(self));
            end
        end


        function openContextMenu(self,src)



            if self.NameListener.Enabled
                set(src.Children,'Enable','on');
            else
                set(src.Children,'Enable','off');
            end

        end


        function removeEntry(self)
            notify(self,'EntryRemoved',images.internal.app.segmenter.volume.events.LabelEventData(...
            self.Name));
        end

    end


    methods




        function set.Color(self,color)
            self.Color=color;
            updateColor(self);
        end




        function set.Name(self,name)
            self.Name=name;
            updateName(self);
        end




        function set.LabelVisible(self,TF)
            self.LabelVisible=TF;
            updateLabelVisible(self);
        end




        function set.Width(self,val)
            self.Width=val;
            updatePosition(self);
        end




        function set.Y(self,val)
            self.Y=val;
            updatePosition(self);
        end




        function set.Selected(self,TF)

            if TF

                set(self.Panel,'BackgroundColor',self.SelectedColor);
                set(self.NameUI,'BackgroundColor',self.SelectedColor);
                set(self.NameUI,'FontColor',self.SelectedTextColor);
                set(self.ColorUI,'BackgroundColor',self.SelectedColor);
                set(self.LabelVisibleUI,'BackgroundColor',self.SelectedColor);

            else

                set(self.Panel,'BackgroundColor',self.UnselectedColor);
                set(self.NameUI,'BackgroundColor',self.UnselectedColor);
                set(self.NameUI,'FontColor',self.UnselectedTextColor);
                set(self.ColorUI,'BackgroundColor',self.UnselectedColor);
                set(self.LabelVisibleUI,'BackgroundColor',self.UnselectedColor);

            end

            self.SelectedInternal=TF;

        end

        function TF=get.Selected(self)

            TF=self.SelectedInternal;

        end

    end


end