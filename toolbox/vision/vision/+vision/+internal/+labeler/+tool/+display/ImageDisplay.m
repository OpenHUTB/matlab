



classdef ImageDisplay<vision.internal.labeler.tool.display.ImageVideoDisplay

    properties(Access=protected)




CurrentImageFilename
    end


    properties(Access=protected)
AxesLimitsListener
    end

    properties
PolygonToolAutomationRegion
    end


    events


ImageSelectedInBrowser


ImageRemovedInBrowser


ImageRotateInBrowser



AxesLimitsChanged

    end

    events


AutomationPolygonROIsChanged



AutomationPolygonROIsDeleted
    end

    methods

        function this=ImageDisplay(hFig,nameDisplayedInTab)

            this=this@vision.internal.labeler.tool.display.ImageVideoDisplay(hFig,nameDisplayedInTab);

        end


        function configure(this,...
            keyPressCallback,...
            labelChangedCallback,...
            roiInstanceSelectionCallback,...
            appWaitStartedCallback,...
            appWaitFinishedCallback,...
            drawingStartedCallback,...
            drawingFinishedCallback,...
            grabCutEditEnabledCallback,...
            grabCutEditDisabledCallback,...
            multipleROIMovingCallback,...
            toolbarButtonChangedCallback,...
            pasteROIMenuCallback,...
            pastePixelROIMenuCallback,...
            copyDisplayNameCallbackForPixelROI,...
            copyPixelROIMenuCallback,...
            cutPixelROIMenuCallback,...
            deletePixelROIMenuCallback)

            configure@vision.internal.labeler.tool.display.ImageVideoDisplay(this,...
            keyPressCallback,...
            labelChangedCallback,...
            roiInstanceSelectionCallback,...
            appWaitStartedCallback,...
            appWaitFinishedCallback,...
            drawingStartedCallback,...
            drawingFinishedCallback,...
            grabCutEditEnabledCallback,...
            grabCutEditDisabledCallback,...
            multipleROIMovingCallback,...
            toolbarButtonChangedCallback,...
            pasteROIMenuCallback,...
            pastePixelROIMenuCallback,...
            copyDisplayNameCallbackForPixelROI,...
            copyPixelROIMenuCallback,...
            cutPixelROIMenuCallback,...
            deletePixelROIMenuCallback);

            this.wireupAxesLimitsListeners();
        end


        function configureImageBrowserDisplay(this,...
            browserButtonDownCallback,...
            browserRemoveImageCallback,...
            browserRotateImageCallback)
            addlistener(this,'ImageSelectedInBrowser',browserButtonDownCallback);
            addlistener(this,'ImageRemovedInBrowser',browserRemoveImageCallback);
            addlistener(this,'ImageRotateInBrowser',browserRotateImageCallback);
        end


        function redrawPixelROIs(this,data)
            data.LabelMatrix=data.LabelMatrix{1};
            data.Placeholder=data.Placeholder{1};
            this.PixelLabeler.drawROIs(data);



            tempData.ForceRedraw=true;
            this.updateContextMenuCopyPastePixel(tempData);
            tempData.ImageFilename=...
            this.PixelLabeler.getImageFilename();
            this.drawImage(tempData)
        end


        function updatePixelLabelColorInCurrentFrame(this)


            data.ForceRedraw=true;
            this.updateContextMenuCopyPastePixel(data);
            data.ImageFilename=...
            this.PixelLabeler.getImageFilename();
            this.drawImage(data);
        end



        function initializePolygonToolAutomationRegion(this)
            blockedAutomationFlag=true;
            this.PolygonToolAutomationRegion=vision.internal.labeler.tool.PolygonLabeler(blockedAutomationFlag);

            addlistener(this.PolygonToolAutomationRegion,'LabelIsChanged',...
            @(~,evtData)notify(this,'AutomationPolygonROIsChanged',evtData));

            addlistener(this.PolygonToolAutomationRegion,'LabelIsDeleted',...
            @(~,evtData)notify(this,'AutomationPolygonROIsDeleted',evtData));

            addlistener(this.PolygonToolAutomationRegion,'LabelIsSelectedPre',...
            @this.updateSelectionAutomationPolygon);

            polyShape=labelType.Polygon;
            polyColor=[1,0,0];
            polyLabel="AutomationRegion";
            this.PolygonToolAutomationRegion.SelectedLabel=vision.internal.labeler.ROILabel(polyShape,...
            polyLabel,'','');
            this.PolygonToolAutomationRegion.SelectedLabel.Color=polyColor;
        end



        function configureAutomationPolygonDeleteCallback(this,DeleteCallback)


            this.PolygonToolAutomationRegion.addDeleteCallback(DeleteCallback);
        end

        function updateSelectionAutomationPolygon(this,varargin)
            this.MultiShapeLabelers.doLabelIsSelectedPre(this.PolygonToolAutomationRegion,varargin{:});
        end


        function deleteAutomationPolygonSelectedROIs(this,varargin)



            this.PolygonToolAutomationRegion.deleteSelectedROIs();
        end

        function deleteAllAutomationPolygonROIs(this)
            if~isempty(this.PolygonToolAutomationRegion)
                ROIList=this.PolygonToolAutomationRegion.CurrentROIs;
                for id=1:numel(ROIList)
                    currentROIUID=ROIList{id}.UserData{4};
                    this.PolygonToolAutomationRegion.deleteROIwithUID(currentROIUID);
                end

                delete(this.PolygonToolAutomationRegion);
                this.PolygonToolAutomationRegion=[];
            end
        end


        function enableDrawingPolygonForAutomationRegion(this)

            if~isempty(this.CurrentLabeler)
                deactivate(this.CurrentLabeler);
            end


            if~isempty(this.ImageHandle)&&~isempty(this.Fig)&&...
                ~isempty(this.AxesHandle)&&~isempty(this.PolygonToolAutomationRegion)
                activate(this.PolygonToolAutomationRegion,this.Fig,this.AxesHandle,this.ImageHandle);
            end

        end

        function disableDrawingPolygonForAutomationRegion(this)

            if~isempty(this.PolygonToolAutomationRegion)
                deactivate(this.PolygonToolAutomationRegion);
            end


            if~isempty(this.ImageHandle)&&~isempty(this.Fig)&&...
                ~isempty(this.AxesHandle)&&~isempty(this.CurrentLabeler)
                activate(this.CurrentLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
            end

        end


    end




    methods(Access=protected)




        function drawImage(this,data)









            if isfield(data,'LabelMatrix')
                this.PixelLabeler.reset(data);
            end

            imageInfo=getLabelAndColorData(this.PixelLabeler,data);

            forceRedraw=isfield(data,'ForceRedraw')&&data.ForceRedraw;

            isSameImage=strcmp(this.CurrentImageFilename,data.ImageFilename);

            if~forceRedraw&&isSameImage

            else
                if isempty(this.Image)||~isvalid(this.Image)


                    createAxes(this);
                end

                createImage(this,imageInfo);


                if ismissing(data.ImageFilename)
                    this.CurrentImageFilename='';
                else
                    this.CurrentImageFilename=data.ImageFilename;
                end



                if~isempty(this.CurrentLabeler)&&strcmp(this.Mode,'ROI')
                    activate(this.CurrentLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                end



                attachToImage(this.RectangleLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                attachToImage(this.LineLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                attachToImage(this.PolygonLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                attachToImage(this.ProjCuboidLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                attachToImage(this.PixelLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
            end



        end

    end


    methods

        function appendImage(this)
            hideHelperText(this);
        end


        function resetPixelLabeler(this,data)
            this.PixelLabeler.reset(data);
            data.ForceRedraw=true;
            drawImage(this,data);
        end

        function setAxesLimits(this,xLim,yLim)

            this.AxesLimitsListener.Enabled=false;

            panVector=this.computePanVectorFromAxesLimits(xLim,yLim);
            this.Image.panByDataSpaceCoordinates(panVector);

            this.AxesLimitsListener.Enabled=true;

        end

        function out=getAxesLimits(this)
            out=struct;

            out.CurrentXLim=this.Image.XLim;
            out.CurrentYLim=this.Image.YLim;
        end

    end


    methods(Access=protected)

        function wireupAxesLimitsListeners(this)
            this.AxesLimitsListener=addlistener(this.Image,'ViewChanged',@(~,evt)axesLimitsChanged(this,evt));
        end

        function axesLimitsChanged(this,evt)
            evtData=vision.internal.labeler.tool.AxesLimitsChangedEventData(evt.XLim,evt.YLim);
            this.notify('AxesLimitsChanged',evtData);
        end

        function panVector=computePanVectorFromAxesLimits(this,xLim,yLim)

            currCenter(1)=this.Image.XLim(1)+diff(this.Image.XLim)/2;
            currCenter(2)=this.Image.YLim(1)+diff(this.Image.YLim)/2;

            newPanCenter(1)=(xLim(1)+diff(xLim)/2);
            newPanCenter(2)=(yLim(1)+diff(yLim)/2);

            panVector=newPanCenter-currCenter;
            panVector(1)=-panVector(1);

        end

    end

    methods

        function drawImageNoROI(this,data)
            drawImage(this,data);
        end

        function drawImageWithInteractiveROIs(this,data)




            wipeROIs(this);



            drawImage(this,data);

            drawInteractiveROIs(this,data.Positions,data.LabelNames,data.SublabelNames,data.SelfUIDs,data.ParentUIDs,data.Colors,data.Shapes,data.ROIVisibility);
            drawnow('limitrate');

        end

        function freezeDrawingTools(this)
            this.disableDrawing();
        end

        function unfreezeDrawingTools(this)
            this.enableDrawing();
        end


        function clearImage(this)
            clearImageInDisplay(this);
        end
    end
end
