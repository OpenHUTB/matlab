



classdef VideoDisplay<vision.internal.labeler.tool.display.ImageVideoDisplay

    methods

        function this=VideoDisplay(hFig,nameDisplayedInTab)

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
            pasteSelectedROIsCallback,...
            pasteSelectedPixelROIsCallback,...
            copyDisplayNameCallbackForPixelROI,...
            copySelectedPixelROIsCallback,...
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
            pasteSelectedROIsCallback,...
            pasteSelectedPixelROIsCallback,...
            copyDisplayNameCallbackForPixelROI,...
            copySelectedPixelROIsCallback,...
            cutPixelROIMenuCallback,...
            deletePixelROIMenuCallback);

        end


        function redrawPixelROIs(this,data)
            data.LabelMatrix=data.LabelMatrix{1};
            data.Placeholder=data.Placeholder{1};
            this.PixelLabeler.drawROIs(data);



            tempData.dummy=0;
            this.updateContextMenuCopyPastePixel(tempData);
            this.drawImage(tempData)
        end


        function updatePixelLabelColorInCurrentFrame(this)


            data.dummy=0;
            this.drawImage(data);
        end
    end




    methods(Access=protected)




        function drawImage(this,data)






            if isfield(data,'LabelMatrix')
                resetPixelLabeler(this,data);
            end

            imageInfo=getLabelAndColorData(this.PixelLabeler,data);



            originalTag=this.AxesHandle.Tag;

            if isempty(this.ImageHandle)


                createAxes(this);
            end

            createImage(this,imageInfo);

            this.AxesHandle.Tag=originalTag;



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
