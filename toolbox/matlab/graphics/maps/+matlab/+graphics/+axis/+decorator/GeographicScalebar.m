classdef(ConstructOnLoad,Sealed)GeographicScalebar<matlab.graphics.primitive.world.Group




    properties(Dependent,AffectsObject)
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive
        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor
        BackgroundColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor
        BackgroundAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne
        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName
        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive
        FontColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor
        FontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeight
        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle
        FontSmoothing matlab.internal.datatype.matlab.graphics.datatype.on_off
    end

    properties(Hidden)
        LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        EdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        BackgroundColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        BackgroundAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        FontNameMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        FontSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        FontColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        FontWeightMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        FontAngleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        FontSmoothingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'



        FontColor_I=[.15,.15,.15]
        EdgeColor_I=[.15,.15,.15]
        FontSize_I=8
    end

    properties(Access=private)
        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5
        BackgroundColor_I=[1,1,1]
        BackgroundAlpha_I=0.45
        FontName_I matlab.internal.datatype.matlab.graphics.datatype.FontName=get(groot,'FactoryGeoaxesFontName')
        FontWeight_I matlab.internal.datatype.matlab.graphics.datatype.FontWeight='normal'
        FontAngle_I matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal'
        FontSmoothing_I='on'
    end

    properties(Access=private,Transient,NonCopyable)


        SpaceForScalebar=true



        LengthDistortion=1
    end

    properties(Access=private,Constant)
        FootInMeters=0.3048
        MileInFeet=5280
        MileInMeters=5280*0.3048
        KilometerInMeters=1000
    end

    properties(Access={?tGeographicScalebar,?tGeographicAxes,?tGeographicAxesCopySaveLoad},Transient)

LowerScaleBox
LowerScaleLine
LowerScaleText

UpperScaleBox
UpperScaleLine
UpperScaleText
    end

    methods
        function obj=GeographicScalebar()
            setupScalebar(obj)
            addDependencyConsumed(obj,{'dataspace','view','ref_frame','xyzdatalimits'});
        end



        function set.LineWidth(obj,w)
            obj.LineWidthMode='manual';
            obj.LineWidth_I=w;
        end


        function w=get.LineWidth(obj)
            w=obj.LineWidth_I;
        end

        function set.LineWidth_I(obj,w)
            upperLine=obj.UpperScaleLine;%#ok<MCSUP>
            upperLine.LineWidth=w;
            lowerLine=obj.LowerScaleLine;%#ok<MCSUP>
            lowerLine.LineWidth=w;

            obj.LineWidth_I=w;
        end


        function set.EdgeColor(obj,c)
            obj.EdgeColorMode='manual';
            obj.EdgeColor_I=c;
        end


        function c=get.EdgeColor(obj)
            c=obj.EdgeColor_I;
        end


        function set.EdgeColor_I(obj,c)
            upperLine=obj.UpperScaleLine;%#ok<MCSUP>
            hgfilter('RGBAColorToGeometryPrimitive',upperLine,c);
            lowerLine=obj.LowerScaleLine;%#ok<MCSUP>
            hgfilter('RGBAColorToGeometryPrimitive',lowerLine,c);

            obj.EdgeColor_I=c;
        end


        function set.BackgroundColor(obj,bc)
            obj.BackgroundColorMode='manual';
            obj.BackgroundColor_I=bc;
        end


        function sz=get.BackgroundColor(obj)
            sz=obj.BackgroundColor_I;
        end


        function set.BackgroundColor_I(obj,bc)
            upperBox=obj.UpperScaleBox;%#ok<MCSUP>
            hgfilter('RGBAColorToGeometryPrimitive',upperBox,[bc,obj.BackgroundAlpha_I]);%#ok<MCSUP>
            lowerBox=obj.LowerScaleBox;%#ok<MCSUP>
            hgfilter('RGBAColorToGeometryPrimitive',lowerBox,[bc,obj.BackgroundAlpha_I]);%#ok<MCSUP>

            obj.BackgroundColor_I=bc;
        end


        function set.BackgroundAlpha(obj,ba)
            obj.BackgroundAlphaMode='manual';
            obj.BackgroundAlpha_I=ba;
        end


        function ba=get.BackgroundAlpha(obj)
            ba=obj.BackgroundAlpha_I;
        end


        function set.BackgroundAlpha_I(obj,ba)
            a=uint8(255*ba);

            upperBox=obj.UpperScaleBox;%#ok<MCSUP>
            upperBox.ColorData_I(4)=a;
            lowerBox=obj.LowerScaleBox;%#ok<MCSUP>
            lowerBox.ColorData_I(4)=a;

            obj.BackgroundAlpha_I=ba;
        end


        function set.FontName(obj,fontname)
            obj.FontNameMode='manual';
            obj.FontName_I=fontname;
        end


        function fontname=get.FontName(obj)
            fontname=obj.FontName_I;
        end


        function set.FontName_I(obj,fontname)
            upperText=obj.UpperScaleText;%#ok<MCSUP>
            upperText.Font.Name=fontname;
            lowerText=obj.LowerScaleText;%#ok<MCSUP>
            lowerText.Font.Name=fontname;
            obj.FontName_I=fontname;
        end


        function set.FontSize(obj,sz)
            obj.FontSizeMode='manual';
            obj.FontSize_I=sz;
        end


        function sz=get.FontSize(obj)
            sz=obj.FontSize_I;
        end


        function set.FontSize_I(obj,sz)
            upperText=obj.UpperScaleText;%#ok<MCSUP>
            upperText.Font.Size=sz;
            lowerText=obj.LowerScaleText;%#ok<MCSUP>
            lowerText.Font.Size=sz;
            obj.FontSize_I=sz;
        end


        function set.FontColor(obj,c)
            obj.FontColorMode='manual';
            obj.FontColor_I=c;
        end


        function sz=get.FontColor(obj)
            sz=obj.FontColor_I;
        end


        function set.FontColor_I(obj,c)
            upperText=obj.UpperScaleText;%#ok<MCSUP>
            lowerText=obj.LowerScaleText;%#ok<MCSUP>



            if isnumeric(c)
                rgba=uint8(255*[c(1:3)';1]);
                upperText.ColorData=rgba;
                lowerText.ColorData=rgba;
                upperText.Visible='on';
                lowerText.Visible='on';
            else
                upperText.Visible='off';
                lowerText.Visible='off';
            end

            obj.FontColor_I=c;
        end


        function set.FontWeight(obj,fontweight)
            obj.FontWeightMode='manual';
            obj.FontWeight_I=fontweight;
        end


        function fontweight=get.FontWeight(obj)
            fontweight=obj.FontWeight_I;
        end


        function set.FontWeight_I(obj,fontweight)
            upperText=obj.UpperScaleText;%#ok<MCSUP>
            upperText.Font.Weight=fontweight;
            lowerText=obj.LowerScaleText;%#ok<MCSUP>
            lowerText.Font.Weight=fontweight;
            obj.FontWeight_I=fontweight;
        end


        function set.FontAngle(obj,fontangle)
            obj.FontAngleMode='manual';
            obj.FontAngle_I=fontangle;
        end


        function fontangle=get.FontAngle(obj)
            fontangle=obj.FontAngle_I;
        end


        function set.FontAngle_I(obj,fontangle)
            upperText=obj.UpperScaleText;%#ok<MCSUP>
            upperText.Font.Angle=fontangle;
            lowerText=obj.LowerScaleText;%#ok<MCSUP>
            lowerText.Font.Angle=fontangle;
            obj.FontAngle_I=fontangle;
        end


        function set.FontSmoothing(obj,fontsmoothing)
            obj.FontSmoothingMode='manual';
            obj.FontSmoothing_I=fontsmoothing;
        end


        function fontsmoothing=get.FontSmoothing(obj)
            fontsmoothing=obj.FontSmoothing_I;
        end


        function set.FontSmoothing_I(obj,fontsmoothing)
            upperText=obj.UpperScaleText;%#ok<MCSUP>
            upperText.FontSmoothing=fontsmoothing;
            lowerText=obj.LowerScaleText;%#ok<MCSUP>
            lowerText.FontSmoothing=fontsmoothing;
            obj.FontSmoothing_I=fontsmoothing;
        end
    end

    methods(Hidden)
        function doUpdate(obj,updateState)















            obj.SpaceForScalebar=true;

            obj.LengthDistortion=lengthDistortionAtMapCenter(updateState.DataSpace);
            mapWidthInProjectedX=diff(updateState.DataSpace.XMapLimits);

            marginInDevicePixels=[0,0,10,10];
            marginInNormalized=updateState.convertUnits(...
            'canvas','normalized','devicepixels',marginInDevicePixels);
            xmargin=marginInNormalized(3);
            ymargin=marginInNormalized(4);



            [upperWidth,hWorld]=updateScale(obj,updateState,mapWidthInProjectedX,"meters");

            hspace=1.35;
            upperVertexData=zeros(3,4,'single');
            upperVertexData(1,:)=([0,0,upperWidth,upperWidth]/mapWidthInProjectedX)+xmargin;
            upperVertexData(2,:)=hspace*[hWorld,0,0,hWorld]+hspace*hWorld+ymargin;
            updatePrimitives(upperVertexData,...
            obj.UpperScaleBox,obj.UpperScaleText,obj.UpperScaleLine)



            [lowerWidth,hWorld]=updateScale(obj,updateState,mapWidthInProjectedX,"feet");

            lowerVertexData=zeros(3,4,'single');
            lowerVertexData(1,:)=([0,0,lowerWidth,lowerWidth]/mapWidthInProjectedX)+xmargin;
            lowerVertexData(2,:)=hspace*[0,hWorld,hWorld,0]+ymargin;
            updatePrimitives(lowerVertexData,...
            obj.LowerScaleBox,obj.LowerScaleText,obj.LowerScaleLine)


            if obj.VisibleMode=="auto"
                ax=obj.Parent;
                if obj.SpaceForScalebar&&~strcmp(ax.Visible,'off')




                    set([obj,...
                    obj.LowerScaleBox,...
                    obj.LowerScaleLine...
                    ,obj.UpperScaleBox,...
                    obj.UpperScaleLine],...
                    'Visible_I','on')
                else




                    set([obj,...
                    obj.LowerScaleBox,...
                    obj.LowerScaleLine...
                    ,obj.UpperScaleBox,...
                    obj.UpperScaleLine],...
                    'Visible_I','off')
                end
            end
        end


        function hParent=getParentImpl(obj,~)
            hParent=ancestor(obj,'matlab.graphics.axis.AbstractAxes','node');
        end
    end

    methods(Access=protected)
        function groups=getPropertyGroups(~)

            props={'BackgroundAlpha','BackgroundColor','LineWidth','FontSize','Visible'};
            groups=matlab.mixin.util.PropertyGroup(props);
        end
    end

    methods(Access=?tGeographicScalebar)
        function[scalebarLength,textHeightInWorld]=updateScale(...
            obj,updateState,mapWidthInProjectedX,units,tooSmallChoice,history)



            if nargin<5
                tooSmallChoice=[];
            end




















            if nargin<6
                history="a";
            end
            recursionLimit=10;
            terminate=endsWith(history,"c")||(strlength(history)>recursionLimit);


            metersPerLengthUnit=updateState.DataSpace.LengthUnitInMeters;
            mapWidthInMeters=mapWidthInProjectedX*metersPerLengthUnit;


            [unitConversion,useMiles]=getUnitConversion(obj,mapWidthInMeters,units);

            lengthDistortion=obj.LengthDistortion;

            limitSpace=~endsWith(history,"c");
            scalebarLength=pickScalebarLength(mapWidthInProjectedX,...
            unitConversion,lengthDistortion,tooSmallChoice,limitSpace);



            if~isempty(scalebarLength)
                [textHeightInWorld,scaleTextWidth]=textHeightAndWidth(obj,...
                updateState,scalebarLength,metersPerLengthUnit,units,useMiles);



                scalebarLength=lengthDistortion*scalebarLength/unitConversion;




                if(scalebarLength<scaleTextWidth)&&~terminate
                    [scalebarLength,textHeightInWorld]=updateScale(obj,...
                    updateState,mapWidthInProjectedX,units,scalebarLength,history+"b");
                else

                    if scalebarLength>mapWidthInProjectedX/3
                        obj.SpaceForScalebar=false;
                    end
                end
            else








                [scalebarLength,textHeightInWorld]=updateScale(obj,...
                updateState,mapWidthInProjectedX,units,tooSmallChoice,history+"c");
            end
        end
    end


    methods(Access=private)
        function setupScalebar(obj)

            lscaleBox=matlab.graphics.primitive.world.Quadrilateral;
            lscaleBox.ColorType_I='truecoloralpha';
            lscaleBox.ColorBinding_I='object';
            lscaleBox.ColorData_I=uint8(255*[obj.BackgroundColor';obj.BackgroundAlpha]);
            lscaleBox.PickableParts='none';
            lscaleBox.HandleVisibility='off';
            lscaleBox.Internal=true;
            addNode(obj,lscaleBox);
            obj.LowerScaleBox=lscaleBox;


            uscaleBox=matlab.graphics.primitive.world.Quadrilateral;
            uscaleBox.ColorType_I='truecoloralpha';
            uscaleBox.ColorBinding_I='object';
            uscaleBox.ColorData_I=uint8(255*[obj.BackgroundColor';obj.BackgroundAlpha]);
            uscaleBox.PickableParts='none';
            uscaleBox.HandleVisibility='off';
            uscaleBox.Internal=true;
            addNode(obj,uscaleBox);
            obj.UpperScaleBox=uscaleBox;


            lscaleLine=matlab.graphics.primitive.world.LineStrip;
            lscaleLine.ColorType_I='truecolor';
            lscaleLine.ColorBinding_I='object';
            lscaleLine.ColorData_I=uint8(255*[obj.EdgeColor';1]);
            lscaleLine.PickableParts='none';
            lscaleLine.HandleVisibility='off';
            lscaleLine.Internal=true;
            addNode(obj,lscaleLine);
            obj.LowerScaleLine=lscaleLine;


            uscaleLine=matlab.graphics.primitive.world.LineStrip;
            uscaleLine.ColorType_I='truecolor';
            uscaleLine.ColorBinding_I='object';
            uscaleLine.ColorData_I=uint8(255*[obj.EdgeColor';1]);
            uscaleLine.PickableParts='none';
            uscaleLine.HandleVisibility='off';
            uscaleLine.Internal=true;
            addNode(obj,uscaleLine);
            obj.UpperScaleLine=uscaleLine;


            lscaleText=matlab.graphics.primitive.world.Text;
            lscaleText.HorizontalAlignment='left';
            lscaleText.VerticalAlignment='middle';
            lscaleText.Font.Name=obj.FontName;
            lscaleText.Font.Size=obj.FontSize;
            lscaleText.ColorData_I=uint8(255*[obj.FontColor';1]);
            lscaleText.PickableParts='none';
            lscaleText.HandleVisibility='off';
            lscaleText.Internal=true;
            addNode(obj,lscaleText);
            obj.LowerScaleText=lscaleText;


            uscaleText=matlab.graphics.primitive.world.Text;
            uscaleText.HorizontalAlignment='left';
            uscaleText.VerticalAlignment='middle';
            uscaleText.Font.Name=obj.FontName;
            uscaleText.Font.Size=obj.FontSize;
            uscaleText.ColorData_I=uint8(255*[obj.FontColor';1]);
            uscaleText.PickableParts='none';
            uscaleText.HandleVisibility='off';
            uscaleText.Internal=true;
            addNode(obj,uscaleText);
            obj.UpperScaleText=uscaleText;
        end


        function[unitConversion,useMiles]=...
            getUnitConversion(obj,mapWidthInMeters,units)
            if units=="meters"
                unitConversion=1;
                useMiles=false;
            else


                useMiles=(mapWidthInMeters>8000);
                if useMiles
                    unitConversion=1/obj.MileInMeters;
                else
                    unitConversion=1/obj.FootInMeters;
                end
            end
        end


        function fullString=constructScalebarText(obj,units,useMiles,...
            scalebarLengthInScaleUnits)
            if units=="meters"&&...
                scalebarLengthInScaleUnits>=obj.KilometerInMeters
                numString=num2str(scalebarLengthInScaleUnits/1000);
                unitString=getString(message(...
                'MATLAB:graphics:maps:UnitsAbbrKilometers'));
            elseif units=="meters"
                numString=num2str(scalebarLengthInScaleUnits);
                unitString=getString(message(...
                'MATLAB:graphics:maps:UnitsAbbrMeters'));
            elseif units=="feet"&&useMiles
                numString=num2str(scalebarLengthInScaleUnits);
                unitString=getString(message(...
                'MATLAB:graphics:maps:UnitsAbbrMiles'));
            else
                numString=num2str(scalebarLengthInScaleUnits);
                unitString=getString(message(...
                'MATLAB:graphics:maps:UnitsAbbrFeet'));
            end
            fullString=[' ',numString,' ',unitString,' '];
        end


        function[textHeightInWorld,scaleTextWidth]=textHeightAndWidth(...
            obj,updateState,scalebarLength,metersPerLengthUnit,units,useMiles)
            if units=="meters"
                st=obj.UpperScaleText;
            else
                st=obj.LowerScaleText;
            end



            scalebarLengthInScaleUnits=metersPerLengthUnit*scalebarLength;



            fullString=constructScalebarText(obj,units,useMiles,...
            scalebarLengthInScaleUnits);
            st.String=fullString;
            st.Layer='front';

            [scaleTextWidth,textHeightInWorld]=getScaleTextSize(st,updateState,obj);
        end
    end
end


function updatePrimitives(vertexData,boxObj,textObj,lineObj)


    boxObj.VertexData=vertexData;
    boxObj.VertexIndices=uint32([4,1,3,2]);
    boxObj.StripData=uint32([1,5]);
    boxObj.Layer='front';


    textObj.VertexData=[vertexData(1,1);mean(vertexData(2,:));0];


    lineObj.VertexData=vertexData;
    lineObj.VertexIndices=uint32(1:4);
    lineObj.StripData=uint32([1,5]);
    lineObj.Layer='front';
end


function[scalewidth,scaleheight]=getScaleTextSize(tobj,updateState,hScalebar)

    extentInPoints=getStringBounds(updateState,...
    tobj.String,tobj.Font,tobj.Interpreter,tobj.FontSmoothing,hScalebar);
    extentInPixels=updateState.convertUnits(...
    'canvas','pixels','points',[0,0,extentInPoints]);
    viewerdata=[0,extentInPixels(3);0,extentInPixels(4)];
    vertexData=matlab.graphics.internal.transformViewerToWorld(...
    updateState.Camera,...
    updateState.TransformAboveDataSpace,...
    updateState.DataSpace,...
    updateState.TransformUnderDataSpace,...
    viewerdata);
    scaleheight=diff(vertexData(2,:));
    [x,~]=worldToProjected(updateState.DataSpace,vertexData(1,:),vertexData(2,:));
    scalewidth=diff(x);
end


function scalebarLength=pickScalebarLength(mapWidthInProjectedX,...
    unitConversion,lengthDistortion,tooSmallChoice,limitSpace)





    if limitSpace


        maxSpace=mapWidthInProjectedX*unitConversion/3;



        maxSpace=maxSpace/lengthDistortion;
    else
        maxSpace=Inf;
    end


    if isempty(tooSmallChoice)
        tooSmallChoice=mapWidthInProjectedX/30;
    end



    choices=[1,2,5,10,20]*10.^(floor(log10(unitConversion*tooSmallChoice)));





    unitChoice=...
    find(choices<=maxSpace&...
    tooSmallChoice<choices/unitConversion,1,'first');
    scalebarLength=choices(unitChoice);
end
