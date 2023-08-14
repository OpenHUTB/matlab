classdef Slider<handle




    events


NextPressed



PreviousPressed





SliderMoving



SliderMoved

    end


    properties(Dependent)

Enabled

Visible

    end


    properties(Transient)


        EnabledInternal(1,1)logical=false;


        VisibleInternal(1,1)logical=true;


        Height(1,1)double{mustBePositive}=24;


        Width(1,1)double{mustBePositive}=1;


        SliderWidth(1,1)double{mustBePositive}=80;


        X(1,1)double{mustBePositive}=1;


        Y(1,1)double{mustBePositive}=1;

    end


    properties(GetAccess={?images.uitest.factory.Tester,...
        ?uitest.factory.Tester},...
        SetAccess=private,Transient)


        Panel matlab.ui.container.Panel


Next


Previous


Slide


        Tag="Slider"

    end


    properties(Access=private,Hidden,Transient)


        SliderMotionListener event.listener
        SliderButtonUpListener event.listener
        SliderHoverListener event.listener

        NextListener event.listener
        PreviousListener event.listener
        ScrollBarListener event.listener

        PreviousIndex(1,1)double

        Border(1,1)double=1;

        StartPoint=[];

        LightGray(1,3)double=[0.75,0.75,0.75];
        MediumGray(1,3)double=[0.65,0.65,0.65];
        DarkGray(1,3)double=[0.4,0.4,0.4];

    end

    properties(SetAccess=private,Hidden,Transient,...
        GetAccess={?uitest.factory.Tester,...
        ?medical.internal.app.labeler.view.sliceView.ScrollableSliceView})


        Max(1,1)double{mustBePositive}=1;


        Current(1,1)double=1;

    end


    methods




        function self=Slider(hParent,pos)

            self.Width=pos(3);
            self.Height=pos(4);

            setSliderWidth(self);

            self.Panel=uipanel('Parent',hParent,...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'Position',pos,...
            'Tag','SliderPanel',...
            'AutoResizeChildren','off');

            hfig=ancestor(hParent,'figure');

            if isa(getCanvas(self.Panel),'matlab.graphics.primitive.canvas.HTMLCanvas')

                self.Next=uibutton(self.Panel,'push',...
                'Position',getNextPosition(self),...
                'ButtonPushedFcn',@(~,~)next(self),...
                'Tag','SliderNext',...
                'Text','','Icon',fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_NextArrow_10.png'));

                self.Previous=uibutton(self.Panel,'push',...
                'Position',getPreviousPosition(self),...
                'ButtonPushedFcn',@(~,~)previous(self),...
                'Tag','SliderPrevious',...
                'Text','','Icon',fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_PreviousArrow_10.png'));

            else

                self.Next=uicontrol(self.Panel,'Style','pushbutton',...
                'Units','pixels',...
                'Enable','off',...
                'Position',getNextPosition(self),...
                'Tag','SliderNext',...
                'Callback',@(~,~)next(self),...
                'CData',self.getArrowIcon());

                self.Previous=uicontrol(self.Panel,'Style','pushbutton',...
                'Units','pixels',...
                'Enable','off',...
                'Position',getPreviousPosition(self),...
                'Callback',@(~,~)previous(self),...
                'Tag','SliderPrevious',...
                'CData',fliplr(self.getArrowIcon()));

            end

            self.SliderHoverListener=event.listener(hfig,'WindowMouseMotion',@(src,evt)hoveringOverSlider(self,evt));
            self.SliderHoverListener.Enabled=false;
            sliderColor=self.LightGray;

            set(self.Panel,'ButtonDownFcn',@(src,evt)scrollAreaClicked(self,evt));

            self.Slide=annotation(self.Panel,'rectangle',...
            'Units','pixels',...
            'LineStyle','none',...
            'Tag','SliderBar',...
            'FaceColor',sliderColor,...
            'Position',getSliderPosition(self));

            self.ScrollBarListener=event.listener(self.Slide,'Hit',@(src,evt)sliderClicked(self,evt));
            self.ScrollBarListener.Enabled=false;

            self.SliderMotionListener=event.listener(hfig,'WindowMouseMotion',@(src,evt)sliderMoving(self,evt));
            self.SliderMotionListener.Enabled=false;

            self.SliderButtonUpListener=event.listener(hfig,'WindowMouseRelease',@(src,evt)sliderStopped(self,evt));
            self.SliderButtonUpListener.Enabled=false;

        end




        function update(self,currentSlice,maxSlice)

            self.Max=maxSlice;
            self.Current=currentSlice;

        end




        function reset(self,sz)

            self.Current=1;
            self.Max=sz;

        end




        function next(self)

            if self.Current<self.Max
                previousIndex=self.Current;
                self.Current=self.Current+1;
                notify(self,'NextPressed',images.internal.app.segmenter.volume.events.SliderMovingEventData(self.Current,previousIndex));
            end

        end




        function previous(self)

            if self.Current>1
                previousIndex=self.Current;
                self.Current=self.Current-1;
                notify(self,'PreviousPressed',images.internal.app.segmenter.volume.events.SliderMovingEventData(self.Current,previousIndex));
            end

        end




        function resize(self,pos)

            if~isequal(self.Panel.Position,pos)

                self.Panel.Position=pos;

                self.Width=pos(3);
                self.Height=pos(4);
                setSliderWidth(self);

                set(self.Next,'Position',getNextPosition(self));
                set(self.Previous,'Position',getPreviousPosition(self));
                set(self.Slide,'Position',getSliderPosition(self));

            end

        end




        function clear(self)

            reset(self,1);
            self.EnabledInternal=false;

        end

    end


    methods(Access=private)


        function scrollAreaClicked(self,evt)

            if~self.EnabledInternal
                return;
            end

            previousIndex=self.Current;

            hfig=ancestor(evt.Source,'figure');

            maxAllowed=self.Width-self.SliderWidth-self.Height;
            minAllowed=self.X+self.Height;

            if hfig.CurrentPoint(1)-self.Panel.Position(1)>=maxAllowed
                idx=self.Max;
            elseif hfig.CurrentPoint(1)-self.Panel.Position(1)<=minAllowed
                idx=1;
            else
                idx=round(self.Max*(hfig.CurrentPoint(1)-self.Panel.Position(1)-minAllowed)/(maxAllowed-minAllowed));
            end

            if idx~=self.Current

                if idx>self.Current
                    self.Current=min(self.Current+10,self.Max);
                else
                    self.Current=max(self.Current-10,1);
                end

                notify(self,'SliderMoving',images.internal.app.segmenter.volume.events.SliderMovingEventData(self.Current,previousIndex));

            end

        end


        function sliderClicked(self,evt)

            if~self.EnabledInternal
                return;
            end

            self.SliderHoverListener.Enabled=false;

            set(self.Slide,'FaceColor',self.DarkGray);

            hfig=ancestor(evt.Source,'figure');
            self.StartPoint=hfig.CurrentPoint(1)-self.Panel.Position(1)-self.Slide.Position(1);
            self.PreviousIndex=self.Current;
            self.SliderMotionListener.Enabled=true;
            self.SliderButtonUpListener.Enabled=true;

        end


        function sliderMoving(self,evt)

            idx=setSliderPosition(self,evt);
            previousIndex=self.Current;

            if idx~=self.Current

                self.Current=idx;
                notify(self,'SliderMoving',images.internal.app.segmenter.volume.events.SliderMovingEventData(self.Current,previousIndex));

            end

        end


        function sliderStopped(self,evt)

            self.SliderMotionListener.Enabled=false;
            self.SliderButtonUpListener.Enabled=false;

            self.SliderHoverListener.Enabled=self.Enabled;
            hoveringOverSlider(self,evt);

            notify(self,'SliderMoved',images.internal.app.segmenter.volume.events.SliderMovingEventData(self.Current,self.PreviousIndex));

        end


        function hoveringOverSlider(self,evt)

            if~self.EnabledInternal
                return;
            end

            if evt.HitObject==self.Slide
                set(self.Slide,'FaceColor',self.MediumGray);
            else
                set(self.Slide,'FaceColor',self.LightGray);
            end

        end


        function setButtonState(self)

            if self.EnabledInternal
                if self.Current==1
                    set(self.Next,'Enable','on');
                    set(self.Previous,'Enable','off');
                elseif self.Current==self.Max
                    set(self.Next,'Enable','off');
                    set(self.Previous,'Enable','on');
                else
                    set(self.Next,'Enable','on');
                    set(self.Previous,'Enable','on');
                end
            else
                set(self.Next,'Enable','off');
                set(self.Previous,'Enable','off');
            end

        end


        function idx=setSliderPosition(self,evt)

            maxAllowed=self.Width-self.SliderWidth-self.Height;
            minAllowed=self.X+self.Height;

            if evt.Point(1)-self.Panel.Position(1)-self.StartPoint>=maxAllowed
                idx=self.Max;
            elseif evt.Point(1)-self.Panel.Position(1)-self.StartPoint<=minAllowed
                idx=1;
            else
                idx=round(self.Max*(evt.Point(1)-self.Panel.Position(1)-self.StartPoint-minAllowed)/(maxAllowed-minAllowed));
            end

        end


        function pos=getNextPosition(self)
            pos=[self.Width-self.Height,self.Y,self.Height,self.Height];
        end


        function pos=getPreviousPosition(self)
            pos=[self.X,self.Y,self.Height,self.Height];
        end


        function pos=getSliderPosition(self)

            maxAllowed=self.Width-self.SliderWidth-self.Height;
            minAllowed=self.X+self.Height;

            if self.Max>1
                frac=(self.Current-1)/(self.Max-1);
            else
                frac=0;
            end
            xloc=minAllowed+round(frac*(maxAllowed-minAllowed));

            pos=[xloc,self.Y+self.Border,self.SliderWidth,self.Height-(2*self.Border)];

        end


        function setSliderWidth(self)

            self.SliderWidth=max(round(self.Width/10),1);

        end

    end


    methods




        function set.Enabled(self,TF)

            self.EnabledInternal=TF;
            setButtonState(self);

            self.ScrollBarListener.Enabled=TF;
            self.SliderHoverListener.Enabled=TF;

        end

        function TF=get.Enabled(self)
            TF=self.EnabledInternal;
        end




        function set.Visible(self,TF)

            self.VisibleInternal=TF;

            if TF
                self.Panel.Visible='on';
            else
                self.Panel.Visible='off';
            end

        end

        function TF=get.Visible(self)
            TF=self.VisibleInternal;
        end




        function set.Current(self,idx)

            if idx<1
                idx=1;
            elseif idx>self.Max
                idx=self.Max;
            end

            maxAllowed=self.Width-self.SliderWidth-self.Height;
            minAllowed=self.X+self.Height;

            frac=(idx-1)/(self.Max-1);
            xloc=minAllowed+round(frac*(maxAllowed-minAllowed));

            pos=self.Slide.Position;

            if isnan(xloc)
                xloc=minAllowed;
            end

            pos(1)=xloc;

            set(self.Slide,'Position',pos);

            self.Current=idx;

            setButtonState(self);

        end

    end


    methods(Static)

        function icon=getArrowIcon()
            arrowIcon=load(fullfile(matlabroot,'toolbox','images','icons','binary_arrow_icon.mat'));
            icon=double(repmat(arrowIcon.arrow,[1,1,3]));
            icon(icon==1)=NaN;
            icon(icon==0)=0.65;
        end

    end

end