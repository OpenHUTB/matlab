classdef TwoImageScrollPanel<handle



    properties(SetAccess=private,...
        GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.registration.Controller,...
        ?images.internal.app.registration.ui.View,...
        ?images.internal.app.registration.ui.DocumentArea,...
        ?images.internal.app.registration.ImageRegistration})
imPanel
Image

FixedMarkers
MovingMarkers
    end

    properties(SetAccess=private,SetObservable,GetAccess=public)
OverlayCData
FixedCData
MovingCData
    end

    properties(Access=private)
ImageSize
FlickerTimer
FeatureVector
        TimerFlag(1,1)logical=true;
    end

    methods

        function self=TwoImageScrollPanel(hFig)

            pos=hFig.Position;

            self.imPanel=uipanel(...
            'Parent',hFig,...
            'Units','pixels',...
            'Position',pos,...
            'HandleVisibility','off',...
            'BorderType','none',...
            'tag','ImagePanel',...
            'AutoResizeChildren','off');

            self.Image=images.internal.app.utilities.Image(self.imPanel);

            hAx=self.Image.ImageHandle.Parent;


            self.FeatureVector=line('Parent',hAx,...
            'XData',[],...
            'YData',[],...
            'PickableParts','none',...
            'Marker','none',...
            'LineStyle','-',...
            'HitTest','off',...
            'HandleVisibility','off',...
            'Color','y',...
            'LineWidth',1);

            self.FixedMarkers=line('Parent',hAx,...
            'XData',[],...
            'YData',[],...
            'PickableParts','none',...
            'Marker','.',...
            'MarkerSize',15,...
            'LineStyle','none',...
            'MarkerEdgeColor',[1,0,0],...
            'HitTest','off',...
            'HandleVisibility','off');

            self.MovingMarkers=line('Parent',hAx,...
            'XData',[],...
            'YData',[],...
            'PickableParts','none',...
            'Marker','.',...
            'MarkerSize',15,...
            'LineStyle','none',...
            'HitTest','off',...
            'HandleVisibility','off',...
            'MarkerEdgeColor',[0,1,0]);

        end

        function resize(self)
            resize(self.Image);
        end

        function scroll(self,scrollCount)
            scroll(self.Image,scrollCount);
        end

        function clear(self)
            set(self.FeatureVector,'XData',[],'YData',[]);
            set(self.FixedMarkers,'XData',[],'YData',[]);
            set(self.MovingMarkers,'XData',[],'YData',[]);
        end

        function layoutScrollPanel(self,imFixed,imMoving,fixedRefObj,movingRefObj)

            self.Image.Enabled=true;
            self.Image.Visible=true;
            self.OverlayCData=imfuse(imFixed,fixedRefObj,imMoving,movingRefObj,'falsecolor');
            [self.FixedCData,self.MovingCData,~]=calculateOverlayImages(imFixed,imMoving,fixedRefObj,movingRefObj);
            self.ImageSize=size(self.FixedCData);

        end

        function updateScrollPanel(self,val,fixed,moving,fixedRefObj,movingRefObj,featureData)

            self.deleteFlickerTimer();


            [self.FixedCData,self.MovingCData,refObjPad]=calculateOverlayImages(fixed,moving,fixedRefObj,movingRefObj);
            oldSize=self.ImageSize;
            self.ImageSize=size(self.FixedCData);

            if~all(isequal(oldSize(1:2),self.ImageSize(1:2)))
                resize(self.Image);
            end

            self.setViewStateCallback(val,self.FixedCData,self.MovingCData);



            fixedAdjustment=[fixedRefObj.XWorldLimits(1)-refObjPad.XWorldLimits(1),fixedRefObj.YWorldLimits(1)-refObjPad.YWorldLimits(1)];
            movingAdjustment=[movingRefObj.XWorldLimits(1)-refObjPad.XWorldLimits(1),movingRefObj.YWorldLimits(1)-refObjPad.YWorldLimits(1)];
            featureData.fixed(:,1)=featureData.fixed(:,1).*fixedRefObj.PixelExtentInWorldX;
            featureData.fixed(:,2)=featureData.fixed(:,2).*fixedRefObj.PixelExtentInWorldY;
            featureData.moving(:,1)=featureData.moving(:,1).*movingRefObj.PixelExtentInWorldX;
            featureData.moving(:,2)=featureData.moving(:,2).*movingRefObj.PixelExtentInWorldY;
            featureData.fixed=featureData.fixed+fixedAdjustment;
            featureData.moving=featureData.moving+movingAdjustment;

            self.setFeatureLines(featureData);

        end

        function setViewStateCallback(self,val,fixed,moving)

            switch val
            case 'Green-Magenta'
                self.setFalseColorView(fixed,moving);
                set(self.MovingMarkers,'MarkerEdgeColor',[1,0,1]);
                set(self.FixedMarkers,'MarkerEdgeColor',[0,1,0]);
                self.setFeatureLineVisiblity('on')
            case 'Red-Cyan'
                self.setRedCyanView(fixed,moving);
                set(self.MovingMarkers,'MarkerEdgeColor',[0,1,1]);
                set(self.FixedMarkers,'MarkerEdgeColor',[1,0,0]);
                self.setFeatureLineVisiblity('on')
            case 'Difference'
                self.setDifferenceView(fixed,moving);
                self.setFeatureLineVisiblity('off')
            case 'Checkerboard'
                self.setCheckerboardView(fixed,moving);
                self.setFeatureLineVisiblity('off')
            case 'Flicker'
                self.setFlickerView();
                self.setFeatureLineVisiblity('off')
            end

        end

        function deleteFlickerTimer(self)
            if~isempty(self.FlickerTimer)
                stop(self.FlickerTimer);
                delete(self.FlickerTimer);
                self.FlickerTimer=[];
            end
        end

    end

    methods(Access=private)

        function setFalseColorView(self,fixed,moving)

            self.deleteFlickerTimer();
            imOverlay=imfuse(fixed,moving,'falsecolor');
            draw(self.Image,imOverlay,uint8.empty,[],[]);

        end

        function setRedCyanView(self,fixed,moving)

            self.deleteFlickerTimer();
            imOverlay=imfuse(fixed,moving,'falsecolor','ColorChannels','red-cyan');
            draw(self.Image,imOverlay,uint8.empty,[],[]);

        end

        function setDifferenceView(self,fixed,moving)

            self.deleteFlickerTimer();
            imOverlay=imfuse(fixed,moving,'diff');
            draw(self.Image,imOverlay,uint8.empty,[],[]);

        end

        function setCheckerboardView(self,fixed,moving)

            self.deleteFlickerTimer();
            imOverlay=imfuse(fixed,moving,'checkerboard');
            draw(self.Image,imOverlay,uint8.empty,[],[]);

        end

        function setFlickerView(self)

            self.deleteFlickerTimer();

            self.FlickerTimer=timer;
            self.FlickerTimer.Name='FlickerTimer';
            self.FlickerTimer.TimerFcn=@(~,~)self.flickerCallback();
            self.FlickerTimer.Period=1;
            self.FlickerTimer.ObjectVisibility='off';
            self.FlickerTimer.ExecutionMode='fixedRate';

            start(self.FlickerTimer);

        end

        function flickerCallback(self)

            if isvalid(self.FlickerTimer)

                if self.TimerFlag
                    self.TimerFlag=false;
                    img=im2single(self.MovingCData);
                else
                    self.TimerFlag=true;
                    img=im2single(self.FixedCData);
                end

                draw(self.Image,img,uint8.empty,[],[min(img,[],'all'),max(img,[],'all')]);

            end

        end

        function setFeatureLines(self,featureData)

            set(self.FixedMarkers,'XData',featureData.fixed(:,1),...
            'YData',featureData.fixed(:,2));
            set(self.MovingMarkers,'XData',featureData.moving(:,1),...
            'YData',featureData.moving(:,2));
            xData=getLineData(featureData.fixed(:,1),featureData.moving(:,1));
            yData=getLineData(featureData.fixed(:,2),featureData.moving(:,2));
            set(self.FeatureVector,'XData',xData,'YData',yData);

        end

        function setFeatureLineVisiblity(self,TF)
            set(self.FixedMarkers,'Visible',TF)
            set(self.MovingMarkers,'Visible',TF)
            set(self.FeatureVector,'Visible',TF)
        end

    end

end

function[A_padded,B_padded,R_output]=calculateOverlayImages(A,B,RA,RB)







    outputWorldLimitsX=[min(RA.XWorldLimits(1),RB.XWorldLimits(1)),...
    max(RA.XWorldLimits(2),RB.XWorldLimits(2))];

    outputWorldLimitsY=[min(RA.YWorldLimits(1),RB.YWorldLimits(1)),...
    max(RA.YWorldLimits(2),RB.YWorldLimits(2))];

    goalResolutionX=min(RA.PixelExtentInWorldX,RB.PixelExtentInWorldX);
    goalResolutionY=min(RA.PixelExtentInWorldY,RB.PixelExtentInWorldY);

    widthOutputRaster=ceil(diff(outputWorldLimitsX)/goalResolutionX);
    heightOutputRaster=ceil(diff(outputWorldLimitsY)/goalResolutionY);

    R_output=imref2d([heightOutputRaster,widthOutputRaster]);
    R_output.XWorldLimits=outputWorldLimitsX;
    R_output.YWorldLimits=outputWorldLimitsY;

    fillVal=0;
    A_padded=images.spatialref.internal.resampleImageToNewSpatialRef(A,RA,R_output,'bilinear',fillVal);
    B_padded=images.spatialref.internal.resampleImageToNewSpatialRef(B,RB,R_output,'bilinear',fillVal);

end

function result=getLineData(fixed,moving)

    result=[fixed,moving,nan(size(fixed))]';
    result=result(:);

end
