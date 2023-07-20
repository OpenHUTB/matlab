classdef ScrollBar<handle




    properties(Dependent)

Enabled

    end


    properties(Transient)


        EnabledInternal(1,1)logical=false;


        Height(1,1)double{mustBePositive}=24;


        Width(1,1)double{mustBePositive}=5;


        ScrollBarHeight(1,1)double{mustBePositive}=5;


        Y(1,1)double{mustBePositive}=1;


        Range(1,2)double=[1,2];

    end


    properties(SetAccess=private,Transient)


        Panel matlab.ui.container.Panel


Bar

    end


    properties(Access=private,Hidden,Transient)

        MediumGray(1,3)double=[0.65,0.65,0.65];

    end


    methods




        function self=ScrollBar(hParent,pos)

            self.Width=pos(3);
            self.Height=pos(4);

            self.Panel=uipanel('Parent',hParent,...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'Position',pos,...
            'Tag','ScrollBarPanel',...
            'AutoResizeChildren','off');

            self.Bar=annotation(self.Panel,'rectangle',...
            'Units','pixels',...
            'LineStyle','none',...
            'FaceColor',self.MediumGray,...
            'Position',getBarPosition(self),...
            'Visible','off');

            setBarHeight(self);

        end




        function update(self,range)

            self.Range=range;
            setBarHeight(self);

        end




        function resize(self,pos)

            if~isequal(self.Panel.Position,pos)

                self.Panel.Position=pos;

                self.Width=pos(3);
                self.Height=pos(4);
                setBarHeight(self);

            end

        end




        function clear(self)

            self.Enabled=false;

        end

    end


    methods(Access=private)


        function pos=getBarPosition(self)

            pos=[1,self.Y,self.Width,self.ScrollBarHeight];

        end


        function setBarHeight(self)

            if~self.EnabledInternal
                return;
            end

            if self.Range(1)>1||self.Range(2)-self.Range(1)<=self.Height
                if strcmp(self.Bar.Visible,'on')
                    self.Bar.Visible='off';
                end
                return;
            end

            minVal=min([self.Range(1),1]);
            totalLength=max([self.Range(2),self.Height])-minVal;
            inViewLength=self.Height-1;

            self.ScrollBarHeight=max([round(self.Height*(inViewLength/totalLength)),round(self.Height/10),1]);
            self.Y=max([(self.Height-self.ScrollBarHeight)*(1-minVal)/(totalLength-inViewLength),1]);

            set(self.Bar,'Position',getBarPosition(self),'Visible','on');

        end

    end


    methods




        function set.Enabled(self,TF)

            if self.EnabledInternal==TF
                return;
            end

            self.EnabledInternal=TF;

            if TF
                setBarHeight(self);
            else
                if isvalid(self.Bar)&&strcmp(self.Bar.Visible,'on')
                    self.Bar.Visible='off';
                end
            end

        end

        function TF=get.Enabled(self)
            TF=self.EnabledInternal;
        end

    end

end