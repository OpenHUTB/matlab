classdef(Sealed,ConstructOnLoad)BasemapAttributionText<matlab.graphics.primitive.world.Group




    properties(Transient,NonCopyable)
        TileZoomLevel=[]
    end

    properties(AffectsObject,Transient,NonCopyable)
        FontSize=get(groot,'DefaultGeoaxesFontSize')
        BasemapChanged=true
    end

    properties(Hidden,Transient,NonCopyable)
TextObject
        IsPrinting=false
    end

    properties(Access=private,Constant)
        AttributionFontSizeMultiplier=0.5
        MinAttributionFontSize=8
        AttributionMarginInDevicePixels=[4,4]
    end


    methods
        function obj=BasemapAttributionText()

            addDependencyConsumed(obj,{'dataspace','view','ref_frame','xyzdatalimits'});

            colorDataRGBA=uint8([50,50,50,255]');

            backgroundColor=[1,1,1];
            backgroundAlpha=0.65;
            backgroundRGBA=uint8(255*[backgroundColor,backgroundAlpha]');

            font=matlab.graphics.general.Font;
            font.Size=attributionFontSize(obj);
            font.Name=get(groot,'DefaultGeoaxesFontName');


            vertexData=single([1,0,0]');

            txt=matlab.graphics.primitive.world.Text;
            txt.Visible='off';
            txt.ColorData=colorDataRGBA;
            txt.BackgroundColor=backgroundRGBA;
            txt.HorizontalAlignment='left';
            txt.VerticalAlignment='bottom';
            txt.Font=font;
            txt.Margin=1;
            txt.PickableParts='none';
            txt.VertexData=vertexData;
            txt.Layer='front';
            txt.Clipping='on';
            addNode(obj,txt)
            obj.TextObject=txt;
        end


        function doUpdate(obj,updateState)


            ax=ancestor(obj,'matlab.graphics.axis.GeographicAxes','node');
            plotboxInDevicePixels=ax.PlotboxInDevicePixels;

            latlim=updateState.DataSpace.LatitudeLimits;
            lonlim=updateState.DataSpace.LongitudeLimits;
            attributionString=generateAttributionString(obj,...
            ax,latlim,lonlim);

            txt=obj.TextObject;
            if strlength(attributionString)==0||strcmp(ax.Visible,'off')

                txt.String='';
                txt.Visible='off';
            else

                font=txt.Font;
                fontSize=attributionFontSize(obj);
                font.Size=fontSize;
                font.Name=ax.FontName;
                txt.Font=font;


                extentInPoints=getStringBounds(updateState,...
                attributionString,txt.Font,txt.Interpreter,txt.FontSmoothing);
                extentInDevicePixels=updateState.convertUnits(...
                'canvas','devicepixels','points',[0,0,extentInPoints]);
                widthInDevicePixels=extentInDevicePixels(3);
                availableWidth=plotboxInDevicePixels(3)/2;

                tooWide=widthInDevicePixels>availableWidth;
                if tooWide


                    plotboxInChars=updateState.convertUnits(...
                    'canvas','characters','devicepixels',plotboxInDevicePixels);
                    widthInChars=plotboxInChars(3);
                    charFontSize=get(groot,'FactoryUiControlFontSize');
                    widthInSizedChars=widthInChars*charFontSize/fontSize;
                    availableWidthInChars=round(widthInSizedChars/2);



                    attributionString=string(...
                    matlab.internal.display.printWrapped(...
                    attributionString,availableWidthInChars));


                    extentInPoints=getStringBounds(updateState,...
                    attributionString,txt.Font,txt.Interpreter,txt.FontSmoothing);
                    extentInDevicePixels=updateState.convertUnits(...
                    'canvas','devicepixels','points',[0,0,extentInPoints]);
                    widthInDevicePixels=extentInDevicePixels(3);



                    attributionString=convertStringsToChars(splitlines(attributionString(:)));




                    attributionString(end)=[];
                else


                    attributionString=convertStringsToChars(splitlines(attributionString(:)));
                end



                margin=obj.AttributionMarginInDevicePixels;
                xText=1-(widthInDevicePixels+margin(1))/max(1,plotboxInDevicePixels(3));
                yText=margin(2)/max(1,plotboxInDevicePixels(4));
                txt.VertexData=single([xText;yText;0]);

                txt.String=attributionString;
                txt.Visible='on';
            end
            obj.BasemapChanged=false;
        end


        function fontsize=attributionFontSize(obj)
            if~obj.IsPrinting
                fontsize=max(obj.MinAttributionFontSize,...
                obj.AttributionFontSizeMultiplier*obj.FontSize);
            else
                fontsize=obj.AttributionFontSizeMultiplier*obj.FontSize;
            end
        end


        function attributionString=generateAttributionString(obj,...
            ax,latlim,lonlim)


            bdisp=ax.BasemapDisplay;
            reader=bdisp.TileReader;
            if~isempty(reader)
                attributionString=readDynamicAttribution(...
                reader,latlim,lonlim,obj.TileZoomLevel);
            else
                attributionString="";
            end
        end
    end
end
