classdef VectorOutputResizeHandler<matlab.graphics.internal.export.FigureResizeHandler




    methods
        function[currentInchWidth,currentInchHeight]=determineTightCropSize(obj)
            if strcmp(obj.printjob.Renderer,'opengl')




                currentInchWidth=obj.printjob.PaperPosition_Width;
                currentInchHeight=obj.printjob.PaperPosition_Height;
            else

                obj.fillPrintjobStruct();


                exportable=obj.printjob.Handles{1};
                genMethod='JT';
                pjstruct=obj.printjob.tostruct;
                pjstruct.TextAsShapes='auto';
                pjstruct.DriverExt='bbox';
                output=obj.printjob.generateOutput(genMethod,exportable,pjstruct);
                if~isnumeric(output)||~isvector(output)...
                    ||length(output)~=2||any(output<=0)||any(isinf(output))
                    error(message('MATLAB:print:UnableToDetermineTightCroppedSize'))
                end
                outputWidth=output(1);
                outputHeight=output(2);
                currentInchWidth=outputWidth/double(pjstruct.CanvasDPI);
                currentInchHeight=outputHeight/double(pjstruct.CanvasDPI);
            end
        end

        function setPaperProperties(obj)
            obj.printjob.PaperPosition_Width=obj.requestedWidthInInches;
            obj.printjob.PaperPosition_Height=obj.requestedHeightInInches;
            obj.printjob.PaperSize_Width=obj.requestedWidthInInches;
            obj.printjob.PaperSize_Height=obj.requestedHeightInInches;
        end

        function figurePositionInInches=getFigureSizeForScaling(obj)

            figurePositionInInches=hgconvertunits(obj.printjob.ParentFig,get(obj.printjob.ParentFig,'Position'),...
            get(obj.printjob.ParentFig,'Units'),'Inches',groot);
        end
    end
end
