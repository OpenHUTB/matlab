classdef ImageOutputResizeHandler<matlab.graphics.internal.export.FigureResizeHandler




    methods
        function[currentInchWidth,currentInchHeight]=determineTightCropSize(obj)


            currentFigPosInInches=hgconvertunits(obj.printjob.ParentFig,get(obj.printjob.ParentFig,'Position'),...
            get(obj.printjob.ParentFig,'Units'),'Inches',groot);
            newFigPosInInches=currentFigPosInInches;
            newFigPosInInches(3)=obj.requestedWidthInInches;
            newFigPosInInches(4)=obj.requestedHeightInInches;

            obj.resizeFigure(newFigPosInInches);

            obj.fillPrintjobStruct();
            obj.setPaperProperties();
            exportable=obj.printjob.Handles{1};
            genMethod='JT';
            pjstruct=obj.printjob.tostruct;
            pjstruct.TextAsShapes='auto';

            output=obj.printjob.generateOutput(genMethod,exportable,pjstruct);

            obj.revertFigureAftertResize(currentFigPosInInches);
            outputSize=size(output);
            if~isnumeric(outputSize)||~isvector(outputSize)...
                ||~(length(outputSize)==2||length(outputSize)==3)...
                ||any(outputSize<=0)||any(isinf(outputSize))
                error(message('MATLAB:print:UnableToDetermineTightCroppedSize'))
            end


            outputCrop=matlab.graphics.internal.export.cropImage(...
            output,[],0);
            [cropHeight,cropWidth,~]=size(outputCrop);
            currentInchWidth=cropWidth/double(pjstruct.DPI);
            currentInchHeight=cropHeight/double(pjstruct.DPI);
        end

        function setPaperProperties(obj)

            figureHeight=obj.printjob.PixelOutputPosition(4);
            figureWidth=obj.printjob.PixelOutputPosition(3);






            requestedWidthInInches=(figureWidth/double(obj.printjob.CanvasDPI))*(obj.printjob.ScaledDPI/obj.printjob.DPI);
            requestedHeightInInches=(figureHeight/double(obj.printjob.CanvasDPI))*(obj.printjob.ScaledDPI/obj.printjob.DPI);



            obj.printjob.PaperPosition_Width=requestedWidthInInches;
            obj.printjob.PaperPosition_Height=requestedHeightInInches;
            obj.printjob.PaperSize_Width=requestedWidthInInches;
            obj.printjob.PaperSize_Height=requestedHeightInInches;
        end

        function figurePositionInInches=getFigureSizeForScaling(obj)


            figurePositionInInches=hgconvertunits(obj.printjob.ParentFig,get(obj.printjob.ParentFig,'Position'),...
            get(obj.printjob.ParentFig,'Units'),'Inches',groot);
            figurePositionInInches(3)=obj.requestedWidthInInches;
            figurePositionInInches(4)=obj.requestedHeightInInches;
        end


    end
end
