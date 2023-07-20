classdef(Abstract)FigureResizeHandler




    properties
printjob
inputNameValuePairs
isImage
requestedWidth
requestedHeight
requestedUnits
requestedResolution
requestedWidthInInches
requestedHeightInInches
    end
    methods(Abstract)
        [currentInchWidth,currentInchHeight]=determineTightCropSize(obj)
        setPaperProperties(obj)
        figureSize=getFigureSizeForScaling()
    end
    methods

        function obj=FigureResizeHandler(printjob,inputNameValuePairs)
            obj.printjob=printjob;
            obj.inputNameValuePairs=inputNameValuePairs;
            obj.isImage=strcmp(obj.printjob.DriverClass,'IM');
            obj.requestedWidth=inputNameValuePairs.size(1);
            obj.requestedHeight=inputNameValuePairs.size(2);
            obj.requestedUnits=inputNameValuePairs.units;
            obj.requestedResolution=inputNameValuePairs.resolution;
            if obj.isImage&&strcmp(obj.requestedUnits,'pixels')


                obj.requestedWidthInInches=obj.requestedWidth/obj.requestedResolution;
                obj.requestedHeightInInches=obj.requestedHeight/obj.requestedResolution;
            else
                requestedSize=hgconvertunits(obj.printjob.ParentFig,...
                [0,0,obj.requestedWidth,obj.requestedHeight],obj.requestedUnits,...
                'inches',groot);
                obj.requestedWidthInInches=requestedSize(3);
                obj.requestedHeightInInches=requestedSize(4);
            end
        end

        function printjob=process(obj)


            [currentInchWidth,currentInchHeight]=obj.determineTightCropSize();



            widthScale=obj.requestedWidthInInches/currentInchWidth;
            heightScale=obj.requestedHeightInInches/currentInchHeight;


            newFigPosInInches=obj.getFigureSizeForScaling();
            newFigPosInInches(3)=newFigPosInInches(3)*widthScale;
            newFigPosInInches(4)=newFigPosInInches(4)*heightScale;


            obj.resizeFigure(newFigPosInInches);




            obj.fillPrintjobStruct();
            obj.setPaperProperties();
            printjob=obj.printjob;
        end

        function resizeFigure(obj,newFigPosInInches)

            newFigPosInPixels=hgconvertunits(obj.printjob.ParentFig,newFigPosInInches,...
            'Inches','Pixels',groot);


            obj.printjob.PixelOutputPosition=newFigPosInPixels;
            poSize=obj.printjob.PixelOutputPosition(3:4);
            scSize=obj.printjob.temp.ScreenSizeInPixels;

            [dpiAdjustment,outputPosition]=calculateDPIScaleAndOutputPosition(obj,poSize,scSize);

            obj.printjob.temp.dpiAdjustment=dpiAdjustment;
            obj.printjob.PixelOutputPosition(3:4)=outputPosition;





            allContents=unique(findall(obj.printjob.temp.exportInclude));
            if obj.printjob.temp.dpiAdjustment~=1||strcmp(obj.printjob.DriverClass,'IM')
                obj.printjob.temp.ObjUnitsModified=obj.printjob.modifyUnitsForPrint('modify',allContents,obj.printjob.temp.dpiAdjustment);
            end

            matlab.graphics.internal.export.updatePosition(obj.printjob);
            pause(1);
        end

        function revertFigureAftertResize(obj,oldFigPosInInches)

            obj.printjob.PixelOutputPosition=hgconvertunits(obj.printjob.ParentFig,oldFigPosInInches,...
            'Inches','Pixels',groot);

            obj.printjob.temp.ObjUnitsModified=obj.printjob.modifyUnitsForPrint('revert',obj.printjob.temp.ObjUnitsModified);

            matlab.graphics.internal.export.updatePosition(obj.printjob);
            pause(1);
        end

        function[dpiAdjustment,outputPosition]=calculateDPIScaleAndOutputPosition(~,poSize,scSize)
            outputPosition=poSize;
            widthAdjustment=1;
            heightAdjustment=1;
            if poSize(1)>scSize(1)

                aspectHtoW=poSize(2)/poSize(1);


                outputPosition(1)=scSize(1);
                outputPosition(2)=outputPosition(1)*aspectHtoW;
                widthAdjustment=poSize(1)/scSize(1);


                poSize=outputPosition;
            end
            if poSize(2)>scSize(2)

                aspectWtoH=poSize(1)/poSize(2);


                outputPosition(2)=scSize(2);
                outputPosition(1)=outputPosition(2)*aspectWtoH;
                heightAdjustment=poSize(2)/scSize(2);
            end
            dpiAdjustment=widthAdjustment*heightAdjustment;
        end

        function fillPrintjobStruct(obj)
            exportable=obj.printjob.Handles{1};

            viewportW=double(exportable.Viewport(3));
            viewportH=double(exportable.Viewport(4));
            obj.printjob.Original_Width=viewportW;
            obj.printjob.Original_Height=viewportH;
            obj.printjob.PixelOutputPosition=[0,0,viewportW,viewportH];



            desiredSizeScale=1.0;

            obj.printjob.Desired_Width=viewportW*desiredSizeScale;
            obj.printjob.Desired_Height=viewportH*desiredSizeScale;

            obj.printjob.ScaledDPI=obj.printjob.DPI;
            if(isfield(obj.printjob.temp,'dpiAdjustment'))
                obj.printjob.ScaledDPI=obj.printjob.ScaledDPI*obj.printjob.temp.dpiAdjustment;
            end
            paperPosScale=1/double(exportable.ScreenPixelsPerInch);
            obj.printjob.PaperPosition_Width=viewportW*paperPosScale;
            obj.printjob.PaperPosition_Height=viewportH*paperPosScale;
        end
    end
end
