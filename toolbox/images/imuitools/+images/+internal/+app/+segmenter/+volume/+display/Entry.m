classdef Entry<handle&matlab.mixin.SetGet




    events


ColorChanged


NameChanged


EntryRemoved


EntryClicked


BringAppToFront

    end


    properties(Dependent)

Selected

    end


    properties


        Color(1,3)single=[0,0,0];


        Name char='';


        Width(1,1)double{mustBePositive}=1;


        Y(1,1)double=1;

        HighlightColor(1,3)single=[0.94,0.94,0.94];

    end


    properties(GetAccess={?images.uitest.factory.Tester,...
        ?uitest.factory.Tester},...
        SetAccess=private,Transient)

        Panel matlab.ui.container.Panel
ColorUI

ContextMenu

    end

    properties(GetAccess={...
        ?images.uitest.factory.Tester,...
        ?uitest.factory.Tester,...
        ?images.internal.app.segmenter.volume.display.Labels,...
        ?medical.internal.app.home.labeler.display.LabelBrowser},SetAccess=private,Transient)

NameUI

    end


    properties(Access=private,Hidden,Transient)

        ColorListener event.listener
        NameListener event.listener

        Dirty(1,1)logical=false;

        SelectedInternal(1,1)logical=false;

    end


    properties(Constant,Hidden)


        X=1;


        Height=20;


        Border=2;

    end

    properties(Access=protected)

        SelectedColor(1,3)single=[0.349,0.667,0.847];
        SelectedTextColor(1,3)single=[1,1,1];

UnselectedColor
UnselectedTextColor

    end


    methods




        function self=Entry(hpanel,yloc,name,color)


            hFig=ancestor(hpanel,'figure');
            if isa(getCanvas(hFig),'matlab.graphics.primitive.canvas.HTMLCanvas')&&~isempty(hFig.Theme)
                self.UnselectedColor=hFig.Theme.ContainerColor;
                self.UnselectedTextColor=hFig.Theme.BaseTextColor;
            else
                self.UnselectedColor=[0.94,0.94,0.94];
                self.UnselectedTextColor=[0,0,0];
            end

            self.Width=hpanel.Position(3);
            self.Y=yloc;

            createUI(self,hpanel);

            self.Name=name;
            self.Color=color;

        end




        function enable(self)

            self.NameListener.Enabled=true;
            self.ColorListener.Enabled=true;

        end




        function disable(self)

            self.NameListener.Enabled=false;
            self.ColorListener.Enabled=false;

        end




        function delete(self)

            delete(self.Panel)
            delete(self.NameUI)
            delete(self.ColorUI)

        end




        function deactivate(self)



            if self.Dirty






                self.Dirty=false;
                if isa(self.NameUI,'matlab.ui.control.EditField')
                    set(self.NameUI,'Editable','off');
                else
                    set(self.NameUI,'Enable','off');
                    drawnow;
                    set(self.NameUI,'Enable','inactive');
                end

            end

        end

    end


    methods(Hidden)




        function nameClicked(self,src)

            if strcmp(images.roi.internal.getClickType(ancestor(src,'figure')),'left')

                self.Dirty=true;

                if isa(self.NameUI,'matlab.ui.control.EditField')
                    set(self.NameUI,'Editable','on','BackgroundColor',[1,1,1],'FontColor',[0,0,0]);
                else
                    set(self.NameUI,'Enable','on','BackgroundColor',[1,1,1],'ForegroundColor',[0,0,0]);
                end

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


        function nameChanged(self)



            if~isa(self.NameUI,'matlab.ui.control.EditField')
                set(self.NameUI,'Enable','inactive');
                val=self.NameUI.String;
            else
                set(self.NameUI,'Editable','off');
                val=self.NameUI.Value;
            end

            oldName=self.Name;
            self.Name=val;

            self.Selected=true;

            notify(self,'NameChanged',images.internal.app.segmenter.volume.events.NameChangedEventData(...
            oldName,val));

        end


        function removeEntry(self)
            notify(self,'EntryRemoved',images.internal.app.segmenter.volume.events.LabelEventData(...
            self.Name));
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
            'BackgroundColor',[0.94,0.94,0.94],...
            'Position',getPanelPosition(self),...
            'UIContextMenu',cmenu);

            try %#ok<TRYNC>
                set(self.Panel,'ButtonDownFcn',@(src,evt)nameClicked(self,src));
            end

            if isa(getCanvas(self.Panel),'matlab.graphics.primitive.canvas.HTMLCanvas')

                self.NameUI=uieditfield(...
                'Parent',self.Panel,...
                'Enable','on',...
                'Editable','off',...
                'Position',getNamePosition(self),...
                'BackgroundColor',[0.939,0.939,0.939],...
                'Value',self.Name,...
                'HorizontalAlignment','left',...
                'ValueChangingFcn',@(src,evt)nameClicked(self,src),...
                'ValueChangedFcn',@(~,~)nameChanged(self),...
                'Tag','LabelName',...
                'UIContextMenu',cmenu);

                self.ColorUI=uiimage('Parent',self.Panel,...
                'ScaleMethod','fill',...
                'ContextMenu',cmenu,...
                'Position',getColorPosition(self),...
                'Tag','LabelColor',...
                'ImageSource',zeros([20,20,3]));

                self.ColorListener=event.listener(self.ColorUI,'ImageClicked',@(src,evt)colorClicked(self,src));

            else

                self.NameUI=uicontrol('Style','edit',...
                'Parent',self.Panel,...
                'Units','pixels',...
                'Enable','inactive',...
                'Position',getNamePosition(self),...
                'BackgroundColor',[0.939,0.939,0.939],...
                'String',self.Name,...
                'HorizontalAlignment','left',...
                'Callback',@(~,~)nameChanged(self),...
                'Tag','LabelName',...
                'UIContextMenu',cmenu);

                colorAxes=axes('Parent',self.Panel,...
                'Visible','off',...
                'Units','pixels',...
                'Position',getColorPosition(self),...
                'HitTest','off',...
                'Colormap',self.Color,...
                'Tag','LabelColor',...
                'HandleVisibility','off');

                self.ColorUI=imshow(zeros(self.Height),'Parent',colorAxes,'InitialMagnification','fit','Interpolation','nearest');
                self.ColorListener=event.listener(self.ColorUI,'Hit',@(src,evt)colorClicked(self,src));
                set(self.ColorUI,'UIContextMenu',cmenu);

                set(colorAxes,'Toolbar',[]);

            end

            self.NameListener=event.listener(self.NameUI,'ButtonDown',@(src,evt)nameClicked(self,src));

        end


        function pos=getNamePosition(self)
            pos=[1+self.Border,1+self.Border,self.Width-self.Height-(4*self.Border),self.Height];
            pos(pos<1)=1;
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


        function updateColor(self)
            if isa(self.ColorUI,'matlab.ui.control.Image')
                self.ColorUI.ImageSource=repmat(permute(self.Color,[1,3,2]),[20,20,1]);
            else
                self.ColorUI.Parent.Colormap=self.Color;
            end
        end


        function updateName(self)
            if isa(self.NameUI,'matlab.ui.control.EditField')
                self.NameUI.Value=self.Name;
            else
                self.NameUI.String=self.Name;
            end
        end


        function updatePosition(self)
            if~isempty(self.NameUI)
                set(self.Panel,'Position',getPanelPosition(self));
                set(self.NameUI,'Position',getNamePosition(self));

                if isa(self.ColorUI,'matlab.ui.control.Image')
                    set(self.ColorUI,'Position',getColorPosition(self));
                else
                    set(self.ColorUI.Parent,'Position',getColorPosition(self));
                end
            end
        end


        function openContextMenu(self,src)



            if self.NameListener.Enabled
                set(src.Children,'Enable','on');
            else
                set(src.Children,'Enable','off');
            end

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
                if~isa(self.NameUI,'matlab.ui.control.EditField')
                    set(self.NameUI,'BackgroundColor',self.SelectedColor,...
                    'ForegroundColor',self.SelectedTextColor);
                else
                    set(self.NameUI,'BackgroundColor',self.SelectedColor,...
                    'FontColor',self.SelectedTextColor);
                    set(self.ColorUI,'BackgroundColor',self.SelectedColor);
                end

            else

                set(self.Panel,'BackgroundColor',self.UnselectedColor);
                if~isa(self.NameUI,'matlab.ui.control.EditField')
                    set(self.NameUI,'BackgroundColor',self.UnselectedColor,...
                    'ForegroundColor',self.UnselectedTextColor);
                else
                    set(self.NameUI,'BackgroundColor',self.UnselectedColor,...
                    'FontColor',self.UnselectedTextColor);
                    set(self.ColorUI,'BackgroundColor',self.UnselectedColor);
                end

            end

            self.SelectedInternal=TF;

        end

        function TF=get.Selected(self)

            TF=self.SelectedInternal;

        end

    end


end