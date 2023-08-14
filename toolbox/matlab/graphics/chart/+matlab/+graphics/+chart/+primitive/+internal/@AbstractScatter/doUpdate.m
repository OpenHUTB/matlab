function doUpdate(hObj,updateState)



    import matlab.graphics.chart.primitive.utilities.isInvalidInLogScale


    x=hObj.XDataCache(:);
    y=hObj.YDataCache(:);
    is3D=~isempty(hObj.ZData_I);
    if is3D
        z=hObj.ZDataCache(:);
    else
        z=zeros(size(x));
    end


    if(numel(x)~=numel(y))||(numel(x)~=numel(z))
        error(message('MATLAB:scatter:DataLengthMustMatch'));
    end



    if~is3D&&strcmpi(hObj.Jitter,'on')
        x=x+(rand(size(x))-0.5)*(2*hObj.JitterAmount);
    end

    if isa(updateState.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')

        invalid_x=isInvalidInLogScale(updateState.DataSpace.XScale,...
        updateState.DataSpace.XLim,x);
        invalid_y=isInvalidInLogScale(updateState.DataSpace.YScale,...
        updateState.DataSpace.YLim,y);

        x(invalid_x)=NaN;
        y(invalid_y)=NaN;

        if is3D
            invalid_z=isInvalidInLogScale(updateState.DataSpace.ZScale,...
            updateState.DataSpace.ZLim,z);
            z(invalid_z)=NaN;
        end
    end


    if any(~strcmp({hObj.XJitter,hObj.YJitter,hObj.ZJitter},'none'))
        [x,y,z]=hObj.doJitter(x,y,z,updateState);
    end


    s=hObj.SizeDataCache(:);


    a=1;
    adataused=~isempty(x)&&...
    (strcmp(hObj.MarkerFaceAlpha,'flat')||strcmp(hObj.MarkerEdgeAlpha,'flat'));
    if adataused
        a=hObj.AlphaDataCache;
    end


    if(numel(x)~=numel(s)&&~isscalar(s))||(adataused&&numel(x)~=numel(a))
        error(message('MATLAB:scatter:DataLengthMustMatch'));
    end




    hObj.assignSeriesIndex();


    updatedColor=hObj.getColor(updateState);
    if isequal(hObj.CDataMode,'auto')&&~isempty(updatedColor)&&...
        ~hObj.isDataComingFromDataSource('Color')&&...
        ~isequal(updatedColor,hObj.CData_I)
        hObj.CData_I=updatedColor;
    end
    c=hObj.CDataCache;


    cacheLegendIconColors(hObj,updateState,c);


    cdataused=~isempty(x)&&(strcmp(hObj.MarkerFaceColor,'flat')||strcmp(hObj.MarkerEdgeColor,'flat'));
    [cdatashape,c]=matlab.graphics.chart.primitive.utilities.parseCData(c,numel(x));


    if cdataused&&(isempty(cdatashape)||~(cdatashape.isColorMapped||cdatashape.isTrueColor||cdatashape.isConstantColor))
        error(message('MATLAB:scatter:InvalidCData'));
    end



    stripnanc=cdataused&&(cdatashape.isColorMapped||cdatashape.isTrueColor);
    [order,x,y,z,s,a,c]=hObj.getCleanData(x,y,z,s,a,c,stripnanc);






    haveNaNCData=false;
    nanCData=false(numel(x),1);
    if cdataused&&~cdatashape.isConstantColor
        nanCData(:)=any(isnan(c),2);
        haveNaNCData=any(nanCData);




        if haveNaNCData&&(...
            (strcmp(hObj.MarkerFaceColor,'flat')&&strcmp(hObj.MarkerEdgeColor,'flat'))||...
            strcmp(hObj.MarkerFaceColor,'none')||strcmp(hObj.MarkerEdgeColor,'none'))
            x=x(~nanCData);
            y=y(~nanCData);
            z=z(~nanCData);
            if~isscalar(s)||isscalar(x)
                s=s(~nanCData);
            end
            c=c(~nanCData,:);
            if adataused
                a=a(~nanCData);
            end
            order=order(~nanCData);
            haveNaNCData=false;
            nanCData=false(numel(x),1);
        end
    end


    if isempty(x)||isempty(y)
        hObj.MarkerHandle.Visible='off';
        hObj.MarkerHandleNaN.Visible='off';
        return;
    end



    iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
    iter.XData_I=x;
    iter.YData_I=y;
    if is3D
        iter.ZData_I=z;
    end
    vd=TransformPoints(updateState.DataSpace,...
    updateState.TransformUnderDataSpace,iter);


    if min(s(:))==max(s(:))
        s=min(s(:));
    end
    s=hObj.mapSize(s,updateState);


    hMarker=hObj.MarkerHandle;
    hMarker.Visible='on';
    hMarker.VertexData=vd(:,~nanCData);


    if isscalar(s)
        hMarker.Size=s;
        hMarker.SizeBinding='object';
    else
        hMarker.Size=s(~nanCData);
        hMarker.SizeBinding='discrete';
    end

    mfc=hObj.MarkerFaceColor;
    mfa=hObj.MarkerFaceAlpha;
    mec=hObj.MarkerEdgeColor;
    mea=hObj.MarkerEdgeAlpha;

    hColorIter=matlab.graphics.axis.colorspace.IndexColorsIterator;
    hColorIter.CDataMapping='scaled';


    if~strcmp(mec,'none')
        if strcmp(mea,'flat')
            hColorIter.AlphaData=a;
            hColorIter.AlphaDataMapping=hObj.AlphaDataMapping;
        else
            hColorIter.AlphaData=mea;
            hColorIter.AlphaDataMapping='none';
        end

        if strcmp(mec,'flat')
            hColorIter.Colors=c;
        else
            hColorIter.Colors=mec;
        end

        if strcmp(mec,'flat')&&cdatashape.isColorMapped
            actualColor=updateState.ColorSpace.TransformColormappedToTrueColor(hColorIter);
        else


            if size(hColorIter.Colors,1)==1&&~isinteger(hColorIter.Colors)&&...
                any(hColorIter.Colors>1|hColorIter.Colors<0|isnan(hColorIter.Colors))
                error(message('MATLAB:hg:ColorBase:BadColorValue'))
            end
            actualColor=updateState.ColorSpace.TransformTrueColorToTrueColor(hColorIter);
        end

        if~isempty(actualColor)
            hMarker.EdgeColorType_I=actualColor.Type;
            if isvector(actualColor.Data)
                hMarker.EdgeColorData_I=actualColor.Data;
                hMarker.EdgeColorBinding_I='object';
            else
                hMarker.EdgeColorData_I=actualColor.Data(:,~nanCData);
                hMarker.EdgeColorBinding_I='discrete';
            end
        else
            hMarker.EdgeColorData_I=[];
            hMarker.EdgeColorBinding_I='none';
        end
    else
        hgfilter('EdgeColorToMarkerPrimitive',hMarker,mec);
    end

    if~strcmp(mfc,'none')
        if strcmp(mfa,'flat')
            hColorIter.AlphaData=a;
            hColorIter.AlphaDataMapping=hObj.AlphaDataMapping;
        else
            hColorIter.AlphaData=mfa;
            hColorIter.AlphaDataMapping='none';
        end

        if strcmp(mfc,'flat')
            hColorIter.Colors=c;
        elseif strcmp(mfc,'auto')
            hColorIter.Colors=updateState.BackgroundColor;
        else
            hColorIter.Colors=mfc;
        end

        if strcmp(mfc,'flat')&&cdatashape.isColorMapped
            actualColor=updateState.ColorSpace.TransformColormappedToTrueColor(hColorIter);
            hMarker.FaceColorType_I=actualColor.Type;
        else


            if size(hColorIter.Colors,1)==1&&~isinteger(hColorIter.Colors)&&...
                any(hColorIter.Colors>1|hColorIter.Colors<0|isnan(hColorIter.Colors))
                error(message('MATLAB:hg:ColorBase:BadColorValue'))
            end
            actualColor=updateState.ColorSpace.TransformTrueColorToTrueColor(hColorIter);
            hMarker.FaceColorType_I=actualColor.Type;
        end
        if~isempty(actualColor)
            if isvector(actualColor.Data)
                hMarker.FaceColorData_I=actualColor.Data;
                hMarker.FaceColorBinding_I='object';
            else
                hMarker.FaceColorData_I=actualColor.Data(:,~nanCData);
                hMarker.FaceColorBinding_I='discrete';
            end
            hMarker.FaceColorType_I=actualColor.Type;
        else
            hMarker.FaceColorData_I=[];
            hMarker.FaceColorBinding_I='none';
        end
    else
        hgfilter('FaceColorToMarkerPrimitive',hMarker,mfc);
    end



    hMarkerNaN=hObj.MarkerHandleNaN;
    if haveNaNCData

        hMarkerNaN.VertexData=vd(:,nanCData);



        order=[order(~nanCData),order(nanCData)];


        if isscalar(s)
            hMarkerNaN.Size=s;
            hMarkerNaN.SizeBinding='object';
        else
            hMarkerNaN.Size=s(nanCData);
            hMarkerNaN.SizeBinding='discrete';
        end


        if(strcmp(mec,'flat')&&~cdatashape.isConstantColor)||strcmp(mec,'none')
            hMarkerNaN.EdgeColorData_I=[];
            hMarkerNaN.EdgeColorBinding_I='none';
            hMarkerNaN.EdgeColorType_I='truecolor';
        elseif strcmp(mea,'flat')
            hColorIter.AlphaData=a;
            hColorIter.AlphaDataMapping=hObj.AlphaDataMapping;
            hColorIter.Colors=mec;
            actualColor=updateState.ColorSpace.TransformTrueColorToTrueColor(hColorIter);
            if~isempty(actualColor)
                hMarkerNaN.EdgeColorData_I=actualColor.Data(:,nanCData);
                hMarkerNaN.EdgeColorBinding_I='discrete';
                hMarkerNaN.EdgeColorType_I=actualColor.Type;
            end
        else
            hgfilter('EdgeColorToMarkerPrimitive',hMarkerNaN,mec);
            if mea<1
                hMarkerNaN.EdgeColorData(4)=uint8(mea*255);
                hMarkerNaN.EdgeColorType='truecoloralpha';
            end
        end


        if(strcmp(mfc,'flat')&&~cdatashape.isConstantColor)||strcmp(mfc,'none')
            hMarkerNaN.FaceColorData_I=[];
            hMarkerNaN.FaceColorBinding_I='none';
            hMarkerNaN.FaceColorType_I='truecolor';
        elseif strcmp(mfa,'flat')
            hColorIter.AlphaData=a;
            hColorIter.AlphaDataMapping=hObj.AlphaDataMapping;
            if strcmp(mfc,'auto')
                hColorIter.Colors=updateState.BackgroundColor;
            else
                hColorIter.Colors=mfc;
            end
            actualColor=updateState.ColorSpace.TransformTrueColorToTrueColor(hColorIter);
            if~isempty(actualColor)
                hMarkerNaN.FaceColorData_I=actualColor.Data(:,nanCData);
                hMarkerNaN.FaceColorBinding_I='discrete';
                hMarkerNaN.FaceColorType_I=actualColor.Type;
            end
        elseif strcmp(mfc,'auto')
            hgfilter('FaceColorToMarkerPrimitive',hMarkerNaN,updateState.BackgroundColor);
        else
            hgfilter('FaceColorToMarkerPrimitive',hMarkerNaN,mfc);
            if mfa<1
                hMarkerNaN.FaceColorData(4)=uint8(mfa*255);
                hMarkerNaN.FaceColorType='truecoloralpha';
            end
        end
        hMarkerNaN.Visible='on';
    else
        hMarkerNaN.Visible='off';
    end





    if isa(hObj,'matlab.graphics.chart.primitive.BubbleChart')&&~is3D&&...
        ~isa(updateState.DataSpace,'matlab.graphics.axis.dataspace.PolarDataSpace')

        hObj.MarkerHandle.AnchorPointClipping='off';
        hObj.MarkerHandleNaN.AnchorPointClipping='off';
    else
        hObj.MarkerHandle.AnchorPointClipping='on';
        hObj.MarkerHandleNaN.AnchorPointClipping='on';
    end













    hObj.MarkerOrder=order;


    if~isempty(hObj.BrushHandles)
        hObj.BrushHandles.MarkDirty('all');
    end

    hSel=hObj.SelectionHandle;
    matlab.graphics.chart.primitive.internal.abstractscatter.updateSelectionHandle(hObj,hSel,vd);


    updateDisplayNameBasedOnLabelHints(hObj,updateState.HintConsumer.getChannelDisplayNamesStruct);

end

