classdef(Abstract)SetLabel<handle




    properties(Dependent)






Label








LabelAlpha






LabelTextColor










LabelVisible

    end

    properties(Hidden,Dependent)







Font

    end

    properties(Hidden,Access=protected)
        LabelInternal char='';
        LabelVisibleInternal logical=true;
        LabelVisibleOnHoverInternal logical=false;
        LabelVisibleInsideInternal logical=false;
        LabelTextColorInternal matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor
        LabelAlphaInternal(1,1)double{mustBeReal}=1;
    end

    methods(Abstract,Hidden)
        [x,y,z,xAlign,yAlign]=getLabelData(self)
    end

    methods(Sealed,Hidden,Access=protected)


        function doUpdateLabel(self,us,lab,color,edgeColor)

            [x,y,z,xAlign,yAlign]=getLabelData(self);














            if~isempty(self.LabelInternal)&&~isempty(x)...
                &&(self.LabelVisibleInternal||(self.LabelVisibleOnHoverInternal&&self.MouseHit))...
                &&showLabelIfROIIsSmall(self,us,lab)

                vd=images.roi.internal.transformPoints(us,x,y,z);
                [xAlign,yAlign]=doUpdateLabelOrientation(self,us,vd,lab,xAlign,yAlign);

                vis=self.Visible;
                lab.VertexData=vd;
                lab.String=self.LabelInternal;

            else
                vis='off';
            end

            if~isempty(self.LabelTextColorInternal)
                edgeColor(1:3)=uint8(self.LabelTextColorInternal*255);
            end

            color(4)=uint8(self.LabelAlphaInternal*255);

            set(lab,'BackgroundColor',color,...
            'ColorData',edgeColor,...
            'HorizontalAlignment',xAlign,...
            'VerticalAlignment',yAlign,...
            'Visible',vis);

            [pickableparts,hittest]=getLabelClickability(self);

            setPrimitiveClickability(self,lab,pickableparts,hittest);

        end

    end

    methods(Hidden,Access=protected)


        function[xAlign,yAlign]=doUpdateLabelOrientation(~,~,~,~,xAlign,yAlign)





        end


        function[pickableparts,hittest]=getLabelClickability(~)



            pickableparts='visible';
            hittest='on';
        end


        function validateLabelVisible(self,val)

            validStr=validatestring(val,{'on','off','hover'});

            switch validStr
            case 'on'
                self.LabelVisibleInternal=true;
                self.LabelVisibleOnHoverInternal=false;
                self.LabelVisibleInsideInternal=false;
            case 'off'
                self.LabelVisibleInternal=false;
                self.LabelVisibleOnHoverInternal=false;
                self.LabelVisibleInsideInternal=false;
            case 'hover'
                self.LabelVisibleInternal=false;
                self.LabelVisibleOnHoverInternal=true;
                self.LabelVisibleInsideInternal=false;
            end

        end


        function[xAlign,yAlign]=findLabelOrientation(self,us,vd,lab,xAlign,yAlign)

            if isempty(self.LabelInternal)||isempty(vd)||(strcmp(xAlign,'center')&&strcmp(yAlign,'middle'))



                return;
            end



            locationAsFraction=[(vd(1)-us.DataSpace.XLim(1))/(us.DataSpace.XLim(2)-us.DataSpace.XLim(1)),...
            (vd(2)-us.DataSpace.YLim(1))/(us.DataSpace.YLim(2)-us.DataSpace.YLim(1))];

            if any(~isfinite(locationAsFraction))
                return;
            end


            availableWidthInPoints=[locationAsFraction(1)*us.ViewerPosition(3),(1-locationAsFraction(1))*us.ViewerPosition(3)]/us.PixelsPerPoint;
            availableHeightInPoints=[locationAsFraction(2)*us.ViewerPosition(4),(1-locationAsFraction(2))*us.ViewerPosition(4)]/us.PixelsPerPoint;

            stringSizeInPoints=us.getStringBounds(self.LabelInternal,lab.Font,lab.Interpreter,lab.FontSmoothing);

            if availableWidthInPoints(2)<=stringSizeInPoints(1)

                xAlign='right';
            end

            if availableWidthInPoints(1)<=stringSizeInPoints(1)

                xAlign='left';
            end

            if availableHeightInPoints(2)<=stringSizeInPoints(2)

                if strcmp(us.DataSpace.YDir,'normal')
                    yAlign='top';
                else
                    yAlign='bottom';
                end
            end

            if availableHeightInPoints(1)<=stringSizeInPoints(2)

                if strcmp(us.DataSpace.YDir,'normal')
                    yAlign='bottom';
                else
                    yAlign='top';
                end
            end

        end


        function TF=showLabelIfROIIsSmall(self,us,lab)

            if self.LabelVisibleInsideInternal


                TF=willLabelFitInsideROI(self,us,lab);

            else
                TF=true;
            end

        end


        function TF=willLabelFitInsideROI(self,us,lab)



            [x,y,z]=getLineData(self);
            vd=images.roi.internal.transformPoints(us,x,y,z);

            if isempty(self.LabelInternal)||isempty(vd)
                TF=false;
                return;
            end

            widthAsFraction=((max(vd(1,:))-min(vd(1,:))))/(us.DataSpace.XLim(2)-us.DataSpace.XLim(1));
            heightAsFraction=((max(vd(2,:))-min(vd(2,:))))/(us.DataSpace.YLim(2)-us.DataSpace.YLim(1));

            if~isfinite(widthAsFraction)||~isfinite(heightAsFraction)
                TF=false;
                return;
            end


            widthInPoints=(widthAsFraction*us.ViewerPosition(3))/us.PixelsPerPoint;
            heightInPoints=(heightAsFraction*us.ViewerPosition(4))/us.PixelsPerPoint;

            stringSizeInPoints=us.getStringBounds(self.LabelInternal,lab.Font,lab.Interpreter,lab.FontSmoothing);



            if stringSizeInPoints(1)<0.75*widthInPoints&&stringSizeInPoints(2)<0.75*heightInPoints
                TF=true;
            else
                TF=false;
            end

        end

    end

    methods




        function set.Font(self,obj)

            validateattributes(obj,{'matlab.graphics.general.Font'},{'scalar'},...
            mfilename,'Font');

            setLabelFont(self,obj);


            update(self);

        end

        function obj=get.Font(self)
            obj=getLabelFont(self);
        end




        function set.Label(self,val)

            validateattributes(val,{'char','string'},{'scalartext'},...
            mfilename,'Label');

            val=char(val);
            if~isequal(self.LabelInternal,val)
                self.LabelInternal=val;

                update(self);
            end

        end

        function val=get.Label(self)
            val=self.LabelInternal;
        end




        function set.LabelAlpha(self,val)

            validateattributes(val,{'numeric'},...
            {'nonempty','real','scalar','nonsparse','>=',0,'<=',1},...
            mfilename,'LabelAlpha');

            val=double(val);
            if self.LabelAlphaInternal~=val
                self.LabelAlphaInternal=val;

                update(self);
            end

        end

        function val=get.LabelAlpha(self)
            val=self.LabelAlphaInternal;
        end




        function set.LabelTextColor(self,color)
            color=convertColorSpec(images.internal.ColorSpecToRGBConverter,color);
            if~isequal(self.LabelTextColorInternal,color)
                self.LabelTextColorInternal=color;

                update(self);
            end
        end

        function color=get.LabelTextColor(self)
            if isempty(self.LabelTextColorInternal)
                color=getTextColor(self);
            else
                color=self.LabelTextColorInternal;
            end
        end




        function set.LabelVisible(self,val)

            validateLabelVisible(self,val);


            update(self);

        end

        function val=get.LabelVisible(self)
            if self.LabelVisibleInternal
                if self.LabelVisibleInsideInternal
                    val='inside';
                else
                    val='on';
                end
            else
                if self.LabelVisibleOnHoverInternal
                    val='hover';
                else
                    val='off';
                end
            end
        end

    end

end