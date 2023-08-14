classdef Entry<handle&matlab.mixin.SetGet





    events


EntryRemoved


EntryClicked

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

App

    end


    properties(SetAccess=private,Transient)

        Panel matlab.ui.container.Panel
ColorUI
EditBtnUI
DeleteBtnUI

    end


    properties(GetAccess={?phased.apps.internal.interaction.SubarrayLabels},SetAccess=private,Transient)

NameUI

    end


    properties(Access=private,Hidden,Transient)

        ColorListener event.listener
        NameListener event.listener


        SelectedInternal(1,1)logical=false;

    end


    properties(Constant,Hidden)


        X=1;


        Height=20;


        Border=2;

    end


    methods




        function self=Entry(hpanel,hApp,yloc,name,color)

            self.Width=hpanel.Position(3);
            self.Y=yloc;
            self.App=hApp;
            createUI(self,hpanel);

            self.Name=name;
            self.Color=color;

        end





        function delete(self)

            delete(self.Panel)
            delete(self.NameUI)
            delete(self.ColorUI)
            delete(self.EditBtnUI)
            delete(self.DeleteBtnUI)

        end

    end


    methods(Hidden)




        function nameClicked(self,~)

            setAppStatus(self.App,true);


            set(self.NameUI,'Enable','on','BackgroundColor',[1,1,1],'ForegroundColor',[0,0,0]);

            notify(self,'EntryClicked');

            setAppStatus(self.App,false);
        end

    end

    methods(Access=private)

        function labelEdit(self)
            currentIndex=find(cellfun(@(x)strcmp(x,self.Name),self.App.SubarrayLabels.Names));
            currentName=self.Name;
            phased.apps.internal.interaction.EditButtonDialog(self.App,currentIndex,currentName);
        end


        function removeEntry(self)
            notify(self,'EntryRemoved',phased.apps.internal.interaction.LabelEventData(...
            self.Name));
        end


        function createUI(self,hpanel)

            self.Panel=uipanel('Parent',hpanel,...
            'AutoResizeChildren','off',...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'BorderType','none',...
            'Tag','EntryPanel',...
            'BackgroundColor',[0.94,0.94,0.94],...
            'Position',getPanelPosition(self));

            self.NameUI=uicontrol('Style','text',...
            'Parent',self.Panel,...
            'Units','pixels',...
            'Enable','inactive',...
            'Position',getNamePosition(self),...
            'BackgroundColor',[0.939,0.939,0.939],...
            'String',self.Name,...
            'Tag','subarrayname',...
            'HorizontalAlignment','left',...
            'Callback',@(src,evt)nameClicked(self,src));











            colorAxes=axes('Parent',self.Panel,...
            'Visible','on',...
            'Units','pixels',...
            'Position',getColorPosition(self),...
            'HitTest','off',...
            'Colormap',self.Color,...
            'HandleVisibility','off');

            self.ColorUI=imshow(zeros(self.Height),'Parent',colorAxes,'InitialMagnification','fit','Interpolation','nearest');
            set(colorAxes,'Toolbar',[]);
            editIcon=fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Edit.png');
            if strcmp(self.App.Container,'ToolGroup')
                editIcon=double(imread(editIcon))/255;
                editIcon(editIcon==0)=NaN;
                self.EditBtnUI=uicontrol('Style','pushbutton',...
                'Parent',self.Panel,...
                'Units','pixels',...
                'Enable','on',...
                'Position',getLabelPosition(self),...
                'CData',editIcon,...
                'Tag','subarrayeditbutton',...
                'Tooltip',getString(message('phased:apps:arrayapp:subarrayeditTT')),...
                'HorizontalAlignment','left',...
                'Callback',@(~,~)labelEdit(self));
            else

                self.EditBtnUI=uibutton('Parent',self.Panel,...
                'Text','',...
                'Enable','on',...
                'Position',getLabelPosition(self),...
                'Icon',editIcon,...
                'Tag','subarrayeditbutton',...
                'Tooltip',getString(message('phased:apps:arrayapp:subarrayeditTT')),...
                'HorizontalAlignment','left',...
                'ButtonPushedFcn',@(~,~)labelEdit(self));
            end

            deleteIcon=fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Close_16.png');
            if strcmp(self.App.Container,'ToolGroup')
                deleteIcon=double(imread(deleteIcon))/255;
                deleteIcon(deleteIcon==0)=NaN;
                self.DeleteBtnUI=uicontrol('Style','pushbutton',...
                'Parent',self.Panel,...
                'Units','pixels',...
                'Enable','on',...
                'Position',getDeletePosition(self),...
                'CData',deleteIcon,...
                'Tag','subarraydeletebutton',...
                'Tooltip',getString(message('phased:apps:arrayapp:subarraydeleteTT')),...
                'HorizontalAlignment','left',...
                'Callback',@(~,~)removeEntry(self));
            else
                self.DeleteBtnUI=uibutton('Parent',self.Panel,...
                'Text','',...
                'Enable','on',...
                'Position',getDeletePosition(self),...
                'Icon',deleteIcon,...
                'Tag','subarraydeletebutton',...
                'Tooltip',getString(message('phased:apps:arrayapp:subarraydeleteTT')),...
                'HorizontalAlignment','left',...
                'ButtonPushedFcn',@(~,~)removeEntry(self));
            end

            self.NameListener=event.listener(self.NameUI,'ButtonDown',@(src,evt)nameClicked(self,src));

        end


        function pos=getNamePosition(self)
            pos=[self.Border,self.Border,self.Width-3*self.Height-(4*self.Border),self.Height];
            pos(pos<1)=1;
        end


        function pos=getPanelPosition(self)
            pos=[self.X,self.Y,self.Width,self.Height+(2*self.Border)];
        end


        function pos=getColorPosition(self)
            pos=[self.Width-3*self.Height-4*self.Border,...
            1+self.Border,...
            self.Height,...
            self.Height];
        end


        function pos=getLabelPosition(self)
            pos=[self.Width-self.Height-self.Border-self.Height,...
            1+self.Border,...
            self.Height,...
            self.Height];
        end


        function pos=getDeletePosition(self)
            pos=[self.Width-self.Height-self.Border,...
            1+self.Border,...
            self.Height,...
            self.Height];
        end



        function updateColor(self)


            self.ColorUI.Parent.Colormap=self.Color;
        end


        function updateName(self)

            self.NameUI.String=self.Name;
            self.NameUI.Enable='inactive';



        end


        function updatePosition(self)
            if~isempty(self.NameUI)
                set(self.Panel,'Position',getPanelPosition(self));
                set(self.NameUI,'Position',getNamePosition(self));
                set(self.ColorUI.Parent,'Position',getColorPosition(self));
                set(self.EditBtnUI,'Position',getLabelPosition(self));
                set(self.DeleteBtnUI,'Position',getDeletePosition(self));
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



                self.HighlightColor=[0.349,0.667,0.847];
                set(self.Panel','BackgroundColor',self.HighlightColor);

                set(self.NameUI,'BackgroundColor',[0.349,0.667,0.847],...
                'ForegroundColor',[1,1,1]);




            else



                self.HighlightColor=[0.94,0.94,0.94];
                set(self.Panel','BackgroundColor',self.HighlightColor);

                set(self.NameUI,'BackgroundColor',[0.939,0.939,0.939],...
                'ForegroundColor',[0,0,0]);




            end

            self.SelectedInternal=TF;

        end

        function TF=get.Selected(self)

            TF=self.SelectedInternal;

        end

    end


end