classdef Entry<handle&matlab.mixin.SetGet




    events


EntrySelectionChanged


EntrySelected

    end


    properties(Dependent)

Selected


Color


Name

    end


    properties


Index


        Width(1,1)double{mustBePositive}=1;


        Y(1,1)double=1;

        HighlightColor(1,3)single=[0.94,0.94,0.94];

    end


    properties(Transient,SetAccess=private,GetAccess=?uitest.factory.Tester)

        Panel matlab.ui.container.Panel

SelectedUI

ColorUI

    end

    properties(Transient,SetAccess=private,GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.volview.LabelsBrowserWeb})

NameUI

    end


    properties(Access=private,Hidden,Transient)

        SelectionListener event.listener
        NameListener event.listener

        Dirty(1,1)logical=false;

    end


    properties(Constant,Hidden)


        X=1;


        Height=20;


        Border=2;

    end


    methods




        function self=Entry(hpanel,yloc,index,name,color)

            self.Width=hpanel.Position(3);
            self.Y=yloc;

            self.Index=index;
            createUI(self,hpanel,name,color);

        end




        function delete(self)

            delete(self.Panel)
            delete(self.NameUI)
            delete(self.ColorUI)
            delete(self.SelectedUI)

        end




        function deactivate(self)%#ok<MANU>

        end

    end


    methods(Access=private)

        function entryCheckboxToggled(self,TF)

            self.reactToEntrySelection(TF);

            evtData=images.internal.app.volview.events.SelectionChangedEventData(self.Index,TF);
            self.notify('EntrySelected',evtData);

        end

        function reactToEntrySelection(self,TF)

            if TF
                self.HighlightColor=[0.349,0.667,0.847];
                set(self.Panel,'BackgroundColor',self.HighlightColor);
                set(self.NameUI,'BackgroundColor',[0.349,0.667,0.847],...
                'FontColor',[1,1,1]);
            else
                self.HighlightColor=[0.94,0.94,0.94];
                set(self.Panel','BackgroundColor',self.HighlightColor);
                set(self.NameUI,'BackgroundColor',[0.939,0.939,0.939],...
                'FontColor',[0,0,0]);
            end
        end

        function entryClicked(self)
            evtData=images.internal.app.volview.events.SelectionChangedEventData(self.Index,true);
            self.notify('EntrySelectionChanged',evtData);
        end


        function createUI(self,hpanel,name,color)

            self.Panel=uipanel('Parent',hpanel,...
            'BorderType','line',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'BorderType','none',...
            'Tag','EntryPanel',...
            'Position',self.getPanelPosition());

            self.SelectedUI=uicheckbox('Parent',self.Panel,...
            'Value',0,...
            'Text','',...
            'Position',self.getSelectedCheckboxPosition(),...
            'ValueChangedFcn',@(src,evt)self.entryCheckboxToggled(evt.Value));

            self.ColorUI=uiimage('Parent',self.Panel,...
            'ScaleMethod','fill',...
            'ImageSource',repmat(permute(color,[1,3,2]),[20,20,1]),...
            'Position',self.getColorPosition());

            self.NameUI=uilabel('Parent',self.Panel,...
            'Text',name,...
            'HorizontalAlignment','left',...
            'Position',self.getNamePosition(),'BackgroundColor','r');

            addlistener(self.ColorUI,'ImageClicked',@(src,evt)self.entryClicked());
            set(self.Panel,'ButtonDownFcn',@(src,evt)self.entryClicked());

        end

        function pos=getSelectedCheckboxPosition(self)
            pos=[1+self.Border,1+self.Border,self.Height,self.Height];
            pos(pos<1)=1;
        end


        function pos=getColorPosition(self)
            pos=[1+self.Border+self.Height+self.Border,...
            1+self.Border,...
            self.Height,...
            self.Height];
        end

        function pos=getNamePosition(self)

            colorPos=getColorPosition(self);
            pos=[colorPos(1)+colorPos(3)+self.Border+15,...
            1+self.Border,...
            self.Width-(colorPos(1)+colorPos(3)+2*self.Border+15),...
            self.Height];
            pos(pos<1)=1;
        end


        function pos=getPanelPosition(self)
            pos=[self.X,self.Y,self.Width,self.Height+(2*self.Border)];
        end


        function cmap=getDisabledColormap(self)
            cmap=[0.7,0.7,0.7;self.HighlightColor];
        end


        function updateColor(self,color)
            self.ColorUI.ImageSource=repmat(permute(color,[1,3,2]),[20,20,1]);
        end


        function updateName(self,name)
            self.NameUI.Value=name;
        end

        function updatePosition(self)
            if~isempty(self.NameUI)
                set(self.Panel,'Position',self.getPanelPosition());

                set(self.ColorUI,'Position',self.getColorPosition());
                set(self.SelectedUI,'Position',self.getSelectedCheckboxPosition());
                set(self.NameUI,'Position',self.getNamePosition());
            end
        end

    end


    methods




        function set.Color(self,color)
            self.ColorUI.ImageSource=repmat(permute(color,[1,3,2]),[20,20,1]);
        end

        function color=get.Color(self)
            color=self.ColorUI.ImageSource;
            color=squeeze(color(:,:,1))';
        end




        function set.Name(self,name)
            self.NameUI.Value=name;
        end

        function name=get.Name(self)
            name=self.NameUI.Value;
        end




        function set.Selected(self,TF)

            if self.SelectedUI.Value==TF
                return
            end

            self.SelectedUI.Value=TF;
            self.reactToEntrySelection(TF);

        end

        function TF=get.Selected(self)
            TF=self.SelectedUI.Value;
        end




        function set.Width(self,val)
            self.Width=val;
            updatePosition(self);
        end




        function set.Y(self,val)
            self.Y=val;
            updatePosition(self);
        end

    end


end
