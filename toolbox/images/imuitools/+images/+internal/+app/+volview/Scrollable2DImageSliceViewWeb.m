



classdef Scrollable2DImageSliceViewWeb<handle

    properties(SetAccess=private,GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.volview.View})
        Panel matlab.ui.container.Panel
    end

    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)

        hFig matlab.ui.Figure
hAx

        hIm matlab.graphics.primitive.Image
        hSlider matlab.ui.control.Slider

    end

    properties(Access=private,Constant)
        Border=10;
    end

    events
SliderValueChanged
    end

    methods

        function self=Scrollable2DImageSliceViewWeb(hFig)

            self.hFig=hFig;

            pos=[1,1,self.hFig.Position(3:4)];
            pos(pos<1)=1;
            self.Panel=uipanel('Parent',self.hFig,...
            'Visible','off',...
            'Units','pixels',...
            'BackgroundColor',[0,0,0],...
            'AutoResizeChildren','off',...
            'Position',pos);
            self.hFig.SizeChangedFcn=@(~,~)self.manageResize();

            self.hSlider=uislider('Parent',self.Panel,...
            'Value',1,...
            'Orientation','vertical',...
            'Visible','on',...
            'MajorTicks',[],...
            'MajorTickLabels',{},...
            'MinorTicks',[],...
            'ValueChangingFcn',@(~,evt)self.notify('SliderValueChanged',evt));

            parentPos=self.Panel.Position;
            pos=[parentPos(3)-2*self.Border,self.Border,parentPos(4)-2*self.Border];
            pos(pos<1)=1;
            self.hSlider.Position([1,2,4])=pos;

            drawnow;
            self.manageResize();

        end

        function updateImageSlice(self,imData,~)


            self.hIm.CData=convertGrayscaleToRGB(imData);

        end

        function updateOverallImageDisplay(self,slice,maxNumSlices,selectedSlice)



            if isgraphics(self.hAx)
                delete(self.hAx);
            end

            figPos=self.hFig.Position;
            pos=[2*self.Border,2*self.Border,figPos(3)-4*self.Border,figPos(4)-4*self.Border];
            pos(pos<1)=1;
            self.hAx=axes('Parent',self.Panel,...
            'Visible','on',...
            'Units','pixels',...
            'Position',pos);

            s=warning('off','images:imshow:magnificationMustBeFitForDockedFigure');
            self.hIm=imshow(convertGrayscaleToRGB(slice),'Parent',self.hAx);
            self.hIm.Tag='SliceView';
            warning(s);
            set(self.hSlider,'Limits',[1,maxNumSlices],'Value',selectedSlice);


            self.hAx.Toolbar=[];
            disableDefaultInteractivity(self.hAx);

        end

        function updateNumberOfSlices(self,numSlices)
            self.hSlider.Limits(2)=numSlices;
        end

        function setSliderTag(self,tag)
            self.hSlider.Tag=tag;
        end

        function reset(self)
            self.Panel.Visible='off';
            self.hIm.CData=[];
        end

    end


    methods(Access=private)

        function manageResize(self)

            if~isgraphics(self.Panel)
                return
            end

            newPos=[1,1,self.hFig.Position(3:4)];
            newPos(newPos<1)=1;

            if~isequal(self.Panel.Position,newPos)

                self.Panel.Position=newPos;

                parentPos=self.Panel.Position;

                sliderPos=[parentPos(3)-2*self.Border,self.Border,parentPos(4)-2*self.Border];
                axesPos=[self.Border,self.Border,parentPos(3)-4*self.Border,parentPos(4)-2*self.Border];

                sliderPos(sliderPos<1)=1;
                axesPos(axesPos<1)=1;

                self.hSlider.Position([1,2,4])=sliderPos;
                self.hAx.Position=axesPos;
            end

        end

    end

end

function img=convertGrayscaleToRGB(imData)

    img=imData;
    if size(imData,3)==1
        img=cat(3,imData,imData,imData);
    end
end
