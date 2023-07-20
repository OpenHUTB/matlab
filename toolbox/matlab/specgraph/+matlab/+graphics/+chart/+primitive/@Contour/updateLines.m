function labelPlacement=updateLines(hObj,updateState)





    labelPlacement=[];
    [lineStrips,numLineStripsUsed]=initializeLineStrips(hObj.EdgePrims);
    [lineLoops,numLineLoopsUsed]=initializeLineLoops(hObj.EdgeLoopPrims);

constructLinePrimitives...
    =~strcmp(hObj.LineStyle,'none')&&~strcmp(hObj.EdgeColor,'none');

    showText=strcmp(hObj.Visible,'on')&&strcmp(hObj.ShowText,'on')&&constructLinePrimitives;

    if constructLinePrimitives
        linkLineStrips=showText||~strcmp(hObj.LineStyle,'-')||hObj.LineWidth>0.5;
        contourLines=computeContourLines(hObj,updateState,linkLineStrips);

        if showText
            cutContoursAtLabels=true;

            levels=[contourLines.Level];
            try
                labels=hObj.createLabelStrings(levels);
            catch caughtError


                w=warning('off','backtrace');
                c=onCleanup(@()warning(w));



                if isscalar(caughtError.cause)
                    format=hObj.LabelFormat;
                    if caughtError.cause{1}.identifier=="MATLAB:hg:UpdateRecursion"...
                        &&isa(format,'function_handle')

                        warning(message('MATLAB:contour:LabelFormatFunctionUpdateRecursion',func2str(format)));
                    else



                        warning(caughtError.identifier,'%s\n',caughtError.message());
                        warning(caughtError.cause{1}.identifier,'%s',caughtError.cause{1}.getReport());
                    end
                else
                    warning(caughtError.identifier,'%s',caughtError.message());
                end


                clear c


                labels=string(levels);



                hObj.LabelCache=struct('Levels',levels,...
                'Format',hObj.LabelFormat,'Labels',labels);
            end

            [labelPlacement,contourLines]...
            =matlab.graphics.chart.internal.contour.placeContourLabels(...
            updateState,contourLines,levels,labels,...
            cutContoursAtLabels,hObj.LabelSpacing,...
            hObj.TextList,hObj.LabelTextProperties.Font);
        end

        hXYZPointsIter=matlab.graphics.axis.dataspace.XYZPointsIterator;
        hIndexColorsIter=matlab.graphics.axis.colorspace.IndexColorsIterator;
        [contourLines,isLoop]=separateStripsAndLoops(contourLines);
        if isempty(contourLines)&&isscalar(hObj.LevelList)


            [hLine,lineStrips,numLineStripsUsed]=nextLineStrip(lineStrips,numLineStripsUsed,false);
            cdata=hObj.LevelList;
            setLineProperties(hLine,hObj,cdata,hIndexColorsIter,updateState.ColorSpace)
            hObj.addNode(hLine);
        else
            for k=1:numel(contourLines)
                contourLine=contourLines(k);
                hXYZPointsIter.XData=contourLine.VertexData(1,:);
                hXYZPointsIter.YData=contourLine.VertexData(2,:);
                hXYZPointsIter.ZData=contourLine.VertexData(3,:);

                lineVertexData=TransformPoints(updateState.DataSpace,...
                updateState.TransformUnderDataSpace,hXYZPointsIter);

                if isLoop(k)
                    [hLine,lineLoops,numLineLoopsUsed]...
                    =nextLineStrip(lineLoops,numLineLoopsUsed,true);
                else
                    [hLine,lineStrips,numLineStripsUsed]...
                    =nextLineStrip(lineStrips,numLineStripsUsed,false);
                end

                hLine.VertexData=lineVertexData;
                hLine.StripData=uint32(contourLine.StripData);

                cdata=contourLine.Level;
                setLineProperties(hLine,hObj,cdata,hIndexColorsIter,updateState.ColorSpace)
                hObj.addNode(hLine);
            end
        end
    end

    hObj.EdgePrims_I=cleanUpUnusedPrimitives(lineStrips,numLineStripsUsed);
    hObj.EdgeLoopPrims_I=cleanUpUnusedPrimitives(lineLoops,numLineLoopsUsed);
end

function setLineProperties(hLineStrip,hObj,cdata,hIndexColorsIter,colorSpace)


    setLineColor(hLineStrip,hObj.EdgeColor,cdata,hIndexColorsIter,colorSpace,hObj.EdgeAlpha)

    hgfilter('LineStyleToPrimLineStyle',hLineStrip,hObj.LineStyle);

    hLineStrip.HitTest='off';
    hLineStrip.LineWidth=hObj.LineWidth;
    hLineStrip.Visible=hObj.Visible;
    hLineStrip.Parent=[];
end

function setLineColor(hLinePrimitive,lineColor,cdata,colorIter,colorSpace,alphadata)

    if isequal(lineColor,'flat')||isequal(lineColor,'auto')
        colorIter.Colors=cdata;
        colorIter.CDataMapping='scaled';
        colorIter.AlphaData=alphadata;
        colorIter.AlphaDataMapping='none';
        actualColor=colorSpace.TransformColormappedToTrueColor(colorIter);
        if~isempty(actualColor)
            hLinePrimitive.ColorData_I=actualColor.Data;
            hLinePrimitive.ColorType_I=actualColor.Type;
            hLinePrimitive.ColorBinding_I='object';
        else
            hLinePrimitive.ColorBinding_I='none';
        end
    elseif isequal(lineColor,'none')
        hgfilter('RGBAColorToGeometryPrimitive',hLinePrimitive,lineColor);
    else
        hgfilter('RGBAColorToGeometryPrimitive',hLinePrimitive,[lineColor,alphadata]);
    end
end

function[lineStrips,numLineStripsUsed]=initializeLineStrips(lineStrips)
    numLineStripsUsed=0;
    if isempty(lineStrips)
        lineStrips=matlab.graphics.primitive.world.LineStrip.empty;
    end
end

function[lineLoops,numLineLoopsUsed]=initializeLineLoops(lineLoops)
    numLineLoopsUsed=0;
    if isempty(lineLoops)
        lineLoops=matlab.graphics.primitive.world.LineLoop.empty;
    end
end

function[nextStrip,lineStrips,numLineStripsUsed]=nextLineStrip(lineStrips,numLineStripsUsed,loop)
    if numLineStripsUsed<length(lineStrips)
        nextStrip=lineStrips(numLineStripsUsed+1);
    else
        if loop
            nextStrip=matlab.graphics.primitive.world.LineLoop;
        else
            nextStrip=matlab.graphics.primitive.world.LineStrip;
        end
        nextStrip.Internal=true;
        lineStrips=[lineStrips;nextStrip];
    end
    numLineStripsUsed=numLineStripsUsed+1;
end

function strips=cleanUpUnusedPrimitives(strips,numStripsUsed)
    numPrims=numel(strips);
    if numStripsUsed<numPrims
        unused=(numStripsUsed+1):numPrims;
        delete(strips(unused))
        strips(unused)=[];
    end
end
