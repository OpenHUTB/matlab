

classdef Scrollable2DImageSliceView<handle

    properties

hFig
hAx
hScrollpanel
hIm
hSlider
        sliderWidthInPixels;
    end


    methods

        function self=Scrollable2DImageSliceView(hFig)

            hFig.SizeChangedFcn=@(hObj,evt)self.manageResize(hObj);

            self.hSlider=uicontrol('Style','slider',...
            'Parent',hFig,...
            'Value',1,...
            'Min',1);

            self.hSlider.Units='pixels';
            self.hSlider.Visible='off';
            figPos=hFig.Position;
            self.sliderWidthInPixels=13;
            self.hSlider.Position=[figPos(3)-self.sliderWidthInPixels,0,self.sliderWidthInPixels,figPos(4)];
            self.hFig=hFig;

        end


        function manageResize(self,hFig)




            figPos=hFig.Position;
            self.hSlider.Position=[figPos(3)-self.sliderWidthInPixels,0,self.sliderWidthInPixels,figPos(4)];

        end

        function updateImageSlice(self,imData,selectedSlice)


            self.hIm.CData=convertGrayscaleToRGB(imData);
            self.hSlider.Value=selectedSlice;

        end

        function updateOverallImageDisplay(self,slice,maxNumSlices,selectedSlice)



            delete(self.hAx);
            self.hAx=axes('Parent',self.hFig,'Visible','off');
            s=warning('off','images:imshow:magnificationMustBeFitForDockedFigure');
            self.hIm=imshow(convertGrayscaleToRGB(slice),'Parent',self.hAx);
            warning(s);
            set(self.hSlider,'Max',maxNumSlices,'Value',selectedSlice);
            if maxNumSlices==2
                minStep=1;
                maxStep=1;
            else
                minStep=1/maxNumSlices;
                maxStep=min(0.5,5/maxNumSlices);
            end
            self.hSlider.SliderStep=[minStep,maxStep];
        end

        function updateNumberOfSlices(self,numSlices)
            self.hSlider.Max=numSlices;
        end

    end

end

function img=convertGrayscaleToRGB(imData)

    img=imData;
    if size(imData,3)==1
        img=cat(3,imData,imData,imData);
    end
end