classdef(Sealed,Hidden)FigureOutputPackager<matlab.internal.editor.BaseOutputPackager





    methods(Static)



        function[outputType,outputData,lineNumbers]=packageOutput(evalStruct,editorId,~)

            import matlab.internal.editor.figure.FigureDataTransporter
            import matlab.internal.editor.OutputPackagerUtilities
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.FigureManager

            currentFigureData=evalStruct.payload;



            unsortedLines=currentFigureData.lineNumbers;
            if numel(unsortedLines)==1||...
                numel(unsortedLines)==2&&unsortedLines(1)<unsortedLines(2)
                lineNumbers=unsortedLines;
            else

                lineNumbers=unique(unsortedLines);
            end

            outputData.lineNumbers=OutputPackagerUtilities.formatForJsonArray(lineNumbers-1);

            outputData.figureId=currentFigureData.figId;
            outputData.figureSize=currentFigureData.figureSize;
            outputData.isPending=currentFigureData.isPending;
            outputData.serverID=currentFigureData.serverID;
            if isfield(currentFigureData,'alt')&&currentFigureData.alt.strlength>0
                outputData.alt=currentFigureData.alt;
            end

            outputData.useEmbedded=0;



            idsMap=EODataStore.getEditorField(editorId,FigureManager.ANIMATED_FIGURE_UID);
            outputData.showPlaybackControls=~isempty(idsMap)&&isKey(idsMap,outputData.figureId)&&idsMap(outputData.figureId)>9;

            if isfield(currentFigureData,'useEmbedded')
                outputData.useEmbedded=currentFigureData.useEmbedded;
            end

            outputData.figureData=struct();

            if~isempty(currentFigureData.figureData)&&~isempty(currentFigureData.figureData.iFigureMetaData)
                mData=currentFigureData.mData;

                if~outputData.useEmbedded


                    iFigureMetaData.iMode=mData.CurrentMode;
                    iFigureMetaData.iZoomDirection=mData.Direction;

                    iFigureMetaData.iTitles=OutputPackagerUtilities.formatForJsonArray(FigureDataTransporter.stringifyCellEntries(mData.Titles));
                    iFigureMetaData.iXLabels=OutputPackagerUtilities.formatForJsonArray(FigureDataTransporter.stringifyCellEntries(mData.XLabels));
                    iFigureMetaData.iYLabels=OutputPackagerUtilities.formatForJsonArray(FigureDataTransporter.stringifyCellEntries(mData.YLabels));
                    iFigureMetaData.iChartType=OutputPackagerUtilities.formatForJsonArray(mData.chartType);
                    iFigureMetaData.iModeStateData=OutputPackagerUtilities.formatForJsonArray(mData.ModeStateData);
                    iFigureMetaData.iIs2D=OutputPackagerUtilities.formatForJsonArray(mData.is2D);
                    iFigureMetaData.iIsPZREnabled=OutputPackagerUtilities.formatForJsonArray(mData.isPZREnabled);
                    iFigureMetaData.iEnableAxesToolbar=OutputPackagerUtilities.formatForJsonArray(mData.EnableAxesToolbar);


                    iFigureMetaData.iLegendPositions=OutputPackagerUtilities.formatForJson2dArray(mData.LegendPositions);
                    iFigureMetaData.iXLabelPositions=OutputPackagerUtilities.formatForJson2dArray(mData.XLabelPositions);
                    iFigureMetaData.iYLabelPositions=OutputPackagerUtilities.formatForJson2dArray(mData.YLabelPositions);
                    iFigureMetaData.iTitlePositions=OutputPackagerUtilities.formatForJson2dArray(mData.TitlePositions);
                    iFigureMetaData.iAxesPositions=OutputPackagerUtilities.formatForJson2dArray(mData.Positions);
                    iFigureMetaData.iAnnotationPositions=OutputPackagerUtilities.formatForJson2dArray(mData.AnnotationPositions);
                    iFigureMetaData.iAnnotationTextPositions=OutputPackagerUtilities.formatForJson2dArray(mData.AnnotationTextPositions);
                end

                iFigureMetaData.iBackgroundColor=mData.BackgroundColor;
                iFigureMetaData.iIsSubplotCase=mData.isSubplotCase;
                iFigureMetaData.iEnableFigureToolstrip=mData.EnableFigureToolstrip;

                iFigureMetaData.iEnableMOLFigureToolstrip=currentFigureData.figureData.iFigureMetaData.iEnableMOLFigureToolstrip;
                iFigureMetaData.iIsXlabelSupported=mData.isXlabelSupported;
                iFigureMetaData.iIsYlabelSupported=mData.isYlabelSupported;
                iFigureMetaData.iIsZlabelSupported=mData.isZlabelSupported;
                iFigureMetaData.iIsTitleSupported=mData.isTitleSupported;
                iFigureMetaData.iIsGridSupported=mData.isGridSupported;
                iFigureMetaData.iIsXGridSupported=mData.isXGridSupported;
                iFigureMetaData.iIsYGridSupported=mData.isYGridSupported;
                iFigureMetaData.iIsColorbarSupported=mData.isColorbarSupported;
                iFigureMetaData.iIsLegendSupported=mData.isLegendSupported;

                outputData.figureData.iFigureMetaData=iFigureMetaData;
            end

            if~isempty(currentFigureData.figureImage)

                if currentFigureData.figureImage.useBackgroundThread
                    outputData.isDeferredSnapshotImage=true;
                    currentFigureData.figureImage.asyncUpdateURI(editorId,currentFigureData.figId);
                else
                    outputData.figureImage=currentFigureData.figureImage.getFigureURI;
                    outputData.isUi=true;
                end
            end

            outputType='figure';
        end

    end
end
