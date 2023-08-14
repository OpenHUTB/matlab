function data=calcXYZData(hObj,us,transformation)




    gran=hObj.MeshDensity;
    data=struct(...
    'xdata',[],...
    'ydata',[],...
    'zdata',[],...
    'vbox',[],...
    'marker_pos',zeros(3,0,'single'),...
    'LineVertices',[],'LineStripData',[]);
    if gran<2
        return
    end

    xlims=[-inf,inf];
    ylims=[-inf,inf];

    if isa(us,'matlab.graphics.eventdata.UpdateState')
        ds=us.DataSpace;

        vbox=[ds.XLim;ds.YLim;ds.ZLim;1,1];
        vbox=sort(transformation\vbox,2);
        xlims=vbox(1,:);
        ylims=vbox(2,:);
    else
        if isa(us,'matlab.graphics.axis.dataspace.DataSpace')
            ds=us;
        else
            ds=hObj.getDataSpace;
        end


        try
            if~strcmp(ds.XLimMode,'auto')
                xlims=ds.XLim;
            end
            if~strcmp(ds.YLimMode,'auto')
                ylims=ds.YLim;
            end
        catch
        end
    end

    if strcmp(hObj.XRangeMode,'manual')||isequal(xlims,[-inf,inf])
        xlims=intersect(hObj.XRange,xlims);
    end
    if strcmp(hObj.YRangeMode,'manual')||isequal(ylims,[-inf,inf])
        ylims=intersect(hObj.YRange,ylims);
    end

    if strcmp(hObj.XRangeMode,'auto')
        hObj.XRange_I=xlims;
    end
    if strcmp(hObj.YRangeMode,'auto')
        hObj.YRange_I=ylims;
    end


    scaleX='';
    scaleY='';
    if~isempty(ds)&&isa(ds,'matlab.graphics.axis.dataspace.CartesianDataSpace')
        scaleX=ds.XScale;
        scaleY=ds.YScale;
    end
    x=matlab.graphics.function.internal.initialMesh(hObj,xlims,gran,scaleX);
    y=matlab.graphics.function.internal.initialMesh(hObj,ylims,gran,scaleY);

    if isempty(hObj.Function_fh_I)
        hObj.updateFunction;
    end
    fn=hObj.Function_fh_I;

    [x,y]=meshgrid(x,y);
    z=reshape(double(fn(x(:).',y(:).')),size(x));

    z(imag(z)~=0)=nan;

    if size(z)~=size(x)
        z=reshape(z,size(x));
        warning(message('MATLAB:fcontour:BadResultShape'));
        if size(z)~=size(x)
            error(message('MATLAB:fcontour:BadResultShape'));
        end
    end

    contourLine=matlab.graphics.chart.internal.contour.contourGriddedData(...
    x,y,z,0,true);

    if~isempty(contourLine)
        data.LineVertices=contourLine.VertexData;
        data.LineStripData=contourLine.StripData;



        data.xdata=data.LineVertices(1,:);
        data.ydata=data.LineVertices(2,:);
        data.zdata=data.LineVertices(3,:);

        if~strcmp(hObj.Marker,'none')&&numel(x)>1

            markers=[data.xdata;data.ydata;data.zdata];
            markers=[markers;matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj,markers)];
            mindist=hObj.MarkerSize*1.6;
            if isa(us,'matlab.graphics.eventdata.UpdateState')
                mindist=mindist*us.PixelsPerPoint;
            end

            i=2;
            while i<size(markers,2)
                dists=bsxfun(@minus,markers(4:5,1:(i-1)),markers(4:5,i));
                dists=dists(1,:).^2+dists(2,:).^2;
                if any(dists<mindist^2)
                    markers(:,i)=[];
                else
                    i=i+1;
                end
            end

            data.marker_pos=markers(1:3,:);
        end
    end
end

function lim=intersect(lim1,lim2)
    lim=[max(lim1(1),lim2(1)),min(lim1(2),lim2(2))];
end
