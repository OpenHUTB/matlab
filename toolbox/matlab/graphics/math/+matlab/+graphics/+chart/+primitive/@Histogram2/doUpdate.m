function doUpdate(hObj,us)




    xbinedges=hObj.XBinEdges;
    ybinedges=hObj.YBinEdges;
    facez=hObj.Values;

    if~isequal(size(facez),[length(xbinedges),length(ybinedges)]-1)

        hObj.Face.Visible='off';
        hObj.Edge.Visible='off';
        hObj.BrushFace.Visible='off';
        hObj.BrushEdge.Visible='off';

        if size(facez,1)~=length(xbinedges)-1
            error(message('MATLAB:histogram2:BinCountsXEdgesMismatch'));
        else
            error(message('MATLAB:histogram2:BinCountsYEdgesMismatch'));
        end
    end

    X_scale=us.DataSpace.XScale;
    X_lim=us.DataSpace.XLim;
    Y_scale=us.DataSpace.YScale;
    Y_lim=us.DataSpace.YLim;
    Z_scale=us.DataSpace.ZScale;
    Z_lim=us.DataSpace.ZLim;



    hObj.XLimCache=X_lim;
    hObj.YLimCache=Y_lim;


    if isa(us.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
        xIsInvalid=...
        matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
        X_scale,X_lim,xbinedges);
        yIsInvalid=...
        matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
        Y_scale,Y_lim,ybinedges);
    else
        xIsInvalid=false(size(xbinedges));
        yIsInvalid=false(size(ybinedges));
    end


    [excludeX,xbinedges,isInfEdgeX]=clipBinEdges(xbinedges,X_lim);
    xIsInvalid=xIsInvalid|excludeX;

    [excludeY,ybinedges,isInfEdgeY]=clipBinEdges(ybinedges,Y_lim);
    yIsInvalid=yIsInvalid|excludeY;

    xbinedges=xbinedges(~xIsInvalid);
    isInfEdgeX=isInfEdgeX(~xIsInvalid);
    ybinedges=ybinedges(~yIsInvalid);
    isInfEdgeY=isInfEdgeY(~yIsInvalid);


    if all(xIsInvalid)
        rowRemove=false(1,length(xIsInvalid)-1);
    else
        index=find(~xIsInvalid,1,'last');
        rowRemove=(~xIsInvalid).';
        rowRemove(index)=[];
    end
    if all(yIsInvalid)
        colRemove=false(1,length(yIsInvalid)-1);
    else
        index=find(~yIsInvalid,1,'last');
        colRemove=~yIsInvalid;
        colRemove(index)=[];
    end

    facez=facez(rowRemove,:);
    facez=facez(:,colRemove);

    dropzeros=strcmp(hObj.ShowEmptyBins,'off');

    brushvalues=hObj.BrushValues;

    if~isequal(size(brushvalues),size(hObj.Values))...
        ||any(brushvalues(:)>hObj.Values(:))
        brushvalues=[];
    end

    if~isempty(facez)
        isbar3=strcmp(hObj.DisplayStyle,'bar3');
        if isbar3
            [x,y,z,isxz,isyz]=hObj.create_bar_coordinates(xbinedges,...
            ybinedges,facez,dropzeros,isInfEdgeX,isInfEdgeY,brushvalues);
            if any(isInfEdgeX)||any(isInfEdgeY)
                hObj.Face.BackFaceCulling='none';
            else
                hObj.Face.BackFaceCulling='back';
            end
        else
            [x,y,z]=matlab.graphics.chart.primitive.histogram2.internal.create_tile_coordinates(xbinedges,...
            ybinedges,facez,dropzeros,brushvalues);
            hObj.Face.BackFaceCulling='none';
        end
    else

        x=[];
        y=[];
        z=[];
        isxz=[];
        isyz=[];
    end


    s=uint32(1):4:uint32(length(x)+1);



    zIsNonFinite=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
    Z_scale,Z_lim,z(:));
    z(zIsNonFinite)=eps;

    piter=matlab.graphics.axis.dataspace.XYZPointsIterator;


    piter.XData=x;
    piter.YData=y;
    piter.ZData=z;

    vd=TransformPoints(us.DataSpace,...
    us.TransformUnderDataSpace,...
    piter);

    q=hObj.Face;
    q.VertexData=vd;

    if strcmp(hObj.FaceLighting,'flat')
        normd=hObj.compute_normals(facez,dropzeros);
        set(q,'NormalData',normd,'NormalBinding','discrete');
    else
        set(q,'NormalData',[]);
    end

    r=hObj.Edge;
    set(r,'VertexData',vd,'VertexIndices',[],'StripData',s);

    facecolor=hObj.FaceColor;
    facealpha=hObj.FaceAlpha;
    edgecolor=hObj.EdgeColor;
    edgealpha=hObj.EdgeAlpha;


    if facealpha==1&&edgealpha==1
        colortype='truecolor';
    else

        if hObj.SupportTransparency||strcmp(us.OpenGL,'off')
            colortype='truecoloralpha';
        else
            colortype='truecolor';
            if~hObj.TransparencyWarningIssued
                warning(message('MATLAB:histogram2:TransparencyNotSupported'));
                hObj.TransparencyWarningIssued=true;
            end
            facealpha=1;
            edgealpha=1;
        end
    end

    if hObj.SeriesIndex~=0
        updatedColor=hObj.getColor(us);
        if~isempty(updatedColor)
            hObj.AutoColor=updatedColor;
        end
    end

    if strcmp(facecolor,'auto')

        facecolor=uint8(([hObj.AutoColor,facealpha]*255).');
        facecolor=repmat(facecolor,1,length(z)/4);
        if strcmp(hObj.FaceLighting,'lit')
            facecolor(1:3,isxz)=facecolor(1:3,isxz)*hObj.XZColorMultiplier;
            facecolor(1:3,isyz)=facecolor(1:3,isyz)*hObj.YZColorMultiplier;
        end
        set(q,'ColorData',facecolor,'ColorBinding','discrete',...
        'ColorType',colortype,'Visible','on');
    elseif strcmp(facecolor,'flat')
        ci=matlab.graphics.axis.colorspace.IndexColorsIterator;
        if strcmp(hObj.DisplayStyle,'bar3')
            ci.Colors=(max(reshape(z,4,[]))).';


            isxy=~(isxz|isyz);
            colorxy=reshape(ci.Colors(isxy),[],2);
            colorxy(:,2)=colorxy(:,1);
            ci.Colors(isxy)=colorxy;
        else
            if isempty(brushvalues)
                if dropzeros
                    ci.Colors=facez(facez>0);
                else
                    ci.Colors=facez;
                end
            else
                if dropzeros
                    ci.Colors=facez(facez>0&~brushvalues);
                else
                    ci.Colors=facez(~brushvalues);
                end
            end
            ci.Colors=ci.Colors(:);
        end
        ci.CDataMapping='scaled';
        cd=TransformColormappedToTrueColor(us.ColorSpace,ci);
        if~isempty(cd)
            if strcmp(hObj.FaceLighting,'lit')
                cd.Data(1:3,isxz)=cd.Data(1:3,isxz)*hObj.XZColorMultiplier;
                cd.Data(1:3,isyz)=cd.Data(1:3,isyz)*hObj.YZColorMultiplier;
            end
            cd.Data(4,:)=facealpha*255;
            cddata=cd.Data;
            set(q,'ColorData',cddata,'ColorBinding','discrete',...
            'ColorType',colortype,'Visible','on');
        else
            set(q,'ColorBinding','none','Visible','off');
        end

    elseif strcmp(facecolor,'none')
        set(q,'Visible','off');
    else
        facecolor=uint8(([facecolor,facealpha]*255).');
        facecolor=repmat(facecolor,1,length(z)/4);
        if strcmp(hObj.FaceLighting,'lit')
            facecolor(1:3,isxz)=facecolor(1:3,isxz)*hObj.XZColorMultiplier;
            facecolor(1:3,isyz)=facecolor(1:3,isyz)*hObj.YZColorMultiplier;
        end
        set(q,'ColorData',facecolor,'ColorBinding','discrete',...
        'ColorType',colortype,'Visible','on');
    end

    if strcmp(edgecolor,'auto')
        edgecolor=uint8(([hObj.AutoColor,edgealpha]*255).');
        set(r,'ColorData',edgecolor,'ColorBinding','object',...
        'ColorType',colortype,'Visible','on');
    elseif strcmp(edgecolor,'none')
        set(r,'Visible','off');
    else
        edgecolor=uint8(([edgecolor,edgealpha]*255).');
        set(r,'ColorData',edgecolor,'ColorBinding','object',...
        'ColorType',colortype,'Visible','on');
    end


    if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
        if isempty(hObj.SelectionHandle)
            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
        end

        if isbar3

            vd_sel=vd(3,:)>vd(3,1);
            if any(vd_sel)
                hObj.SelectionHandle.VertexData=vd(:,vd_sel);
            else
                hObj.SelectionHandle.VertexData=vd;
            end
        else
            hObj.SelectionHandle.VertexData=vd;
        end
        hObj.SelectionHandle.Visible='on';
    else
        if~isempty(hObj.SelectionHandle)
            hObj.SelectionHandle.VertexData=[];
            hObj.SelectionHandle.Visible='off';
        end
    end



    if~isempty(brushvalues)
        if isbar3
            [bx,by,bz,bisxz,bisyz]=hObj.create_bar_coordinates(xbinedges,...
            ybinedges,brushvalues,true,isInfEdgeX,isInfEdgeY);
        else
            [bx,by,bz]=matlab.graphics.chart.primitive.histogram2.internal.create_tile_coordinates(xbinedges,...
            ybinedges,brushvalues,true);
        end


        bs=uint32(1):4:uint32(length(bx)+1);



        bzIsNonFinite=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
        Z_scale,Z_lim,bz(:));
        bz(bzIsNonFinite)=eps;

        piter.XData=bx;
        piter.YData=by;
        piter.ZData=bz;



        piter.XData=max(min(piter.XData,us.DataSpace.XLim(2)),...
        us.DataSpace.XLim(1));
        piter.YData=max(min(piter.YData,us.DataSpace.YLim(2)),...
        us.DataSpace.YLim(1));
        bvd=TransformPoints(us.DataSpace,...
        us.TransformUnderDataSpace,...
        piter);

        bq=hObj.BrushFace;
        br=hObj.BrushEdge;
        brushcolor=uint8(([hObj.BrushColor,hObj.BrushAlpha]*255).');
        set(bq,'Visible','on','VertexData',bvd);

        if strcmp(hObj.FaceLighting,'flat')
            bnormd=hObj.compute_normals(brushvalues,true);
            set(bq,'NormalData',bnormd,'NormalBinding','discrete');
        else
            set(bq,'NormalData',[]);
        end

        if isbar3
            brushcolor=repmat(brushcolor,1,length(bz)/4);
            if strcmp(hObj.FaceLighting,'lit')
                brushcolor(1:3,bisxz)=brushcolor(1:3,bisxz)*hObj.XZColorMultiplier;
                brushcolor(1:3,bisyz)=brushcolor(1:3,bisyz)*hObj.YZColorMultiplier;
            end

            set(bq,'ColorData',brushcolor,'ColorBinding','discrete',...
            'ColorType',colortype);
            set(br,'VertexData',bvd,'VertexIndices',[],'StripData',bs,...
            'ColorData',r.ColorData,'ColorBinding',r.ColorBinding,...
            'ColorType',r.ColorType,'Visible',r.Visible,'LineWidth',r.LineWidth);
        else
            ci=matlab.graphics.axis.colorspace.IndexColorsIterator;
            ci.Colors=reshape(facez(logical(brushvalues)),[],1);
            ci.CDataMapping='scaled';
            cd=TransformColormappedToTrueColor(us.ColorSpace,ci);
            if~isempty(cd)
                cd.Data(4,:)=facealpha*255;
                cddata=cd.Data;
                set(bq,'ColorData',cddata,'ColorBinding','discrete',...
                'ColorType',colortype);
            else
                set(bq,'ColorBinding','none','Visible','off');
            end
            set(br,'VertexData',bvd,'VertexIndices',[],'StripData',bs,...
            'ColorData',brushcolor,'ColorBinding','object',...
            'ColorType',colortype,'LineWidth',r.LineWidth+3,...
            'Visible','on');
        end
    else
        set(hObj.BrushFace,'Visible','off');
        set(hObj.BrushEdge,'Visible','off');
    end

    hObj.Brushed=false;

end

function[isExcluded,binEdges,isInfEdge]=clipBinEdges(binEdges,Lims)















    isInfEdge=false(size(binEdges));
    isInfEdge([1,end])=isinf(binEdges([1,end]));

    isInBound=Lims(1)<=binEdges&binEdges<=Lims(2);
    minEdgeInBound=find(isInBound,1,'first');
    maxEdgeInBound=find(isInBound,1,'last');

    isExcluded=false(size(binEdges));
    if~any(isInBound)
        if all(binEdges<Lims(1))||all(binEdges>Lims(2))

            isExcluded(:)=true;
        else

            ind=find(binEdges<Lims(1),1,'last');
            isExcluded(:)=true;
            isExcluded([ind,ind+1])=false;
            binEdges([ind,ind+1])=Lims;
        end
    else
        if minEdgeInBound~=1



            isExcluded(1:minEdgeInBound-2)=true;
            binEdges(minEdgeInBound-1)=Lims(1);
        end
        if maxEdgeInBound~=length(binEdges)



            isExcluded(maxEdgeInBound+2:end)=true;
            binEdges(maxEdgeInBound+1)=Lims(2);
        end
    end

end
