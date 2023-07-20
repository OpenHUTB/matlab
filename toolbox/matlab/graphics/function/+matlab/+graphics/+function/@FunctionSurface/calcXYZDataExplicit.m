function data=calcXYZDataExplicit(hObj,us,transformation,constraints)




    gran=hObj.MeshDensity;
    data=struct('xdata_coarse',[],...
    'ydata_coarse',[],...
    'zdata_coarse',[],...
    'xdata',[],...
    'ydata',[],...
    'zdata',[],...
    'vbox',[],...
    'LineVertices',zeros(3,0,'single'),'LineStripData',[],...
    'FaceVertices',zeros(3,0,'single'),'FaceVertexIndices',[],...
    'NormalData',zeros(3,0,'single'));
    if gran<2
        return
    end
    granX=gran;
    granY=gran;


    xlims=[-inf,inf];
    ylims=[-inf,inf];

    if isa(us,'matlab.graphics.eventdata.UpdateState')
        ds=us.DataSpace;
    else
        if isa(us,'matlab.graphics.axis.dataspace.DataSpace')
            ds=us;
        else
            ds=hObj.getDataSpace;
        end
    end

    zlims=[-inf,inf];
    try
        zlims=ds.ZLim;
    catch
    end
    if isstruct(constraints)
        if isfield(constraints,'XConstraints')
            xlims=constraints.XConstraints;
        end
        if isfield(constraints,'YConstraints')
            ylims=constraints.YConstraints;
        end
        if isfield(constraints,'ZConstraints')
            zlims=constraints.ZConstraints;
        end
    else

        try
            if~(strcmp(ds.XLimMode,'auto')&&isequal(ds.XLim,[0,1]))
                xlims=ds.XLim;
            end
            if~(strcmp(ds.YLimMode,'auto')&&isequal(ds.XLim,[0,1]))
                ylims=ds.YLim;
            end
        catch
        end
    end

    vbox=[xlims;ylims;zlims;1,1];
    vbox=sort(transformation\vbox,2);
    if~anynan(vbox)
        xlims=vbox(1,:);
        ylims=vbox(2,:);
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

    if xlims(2)<xlims(1)||ylims(2)<ylims(1)
        return
    end



    scaleX='';
    scaleY='';




    X=matlab.graphics.function.internal.initialMesh(hObj,xlims,granX,scaleX);
    Y=matlab.graphics.function.internal.initialMesh(hObj,ylims,granY,scaleY);
    [X,Y]=meshgrid(X,Y);

    if isempty(hObj.Function_fh_I)
        hObj.updateFunction;
    end
    fn=hObj.Function_fh_I;

    function[x,y,z]=evaluateAt(x,y)
        try
            z=single(fn(x(:).',y(:).'));
            z=reshape(z,size(x));

            if isscalar(z)&&~isscalar(x)
                z=repmat(z,size(x));
            end
        catch me
            error(message('MATLAB:FunctionLine:doUpdate',me.message));
        end
        nanPos=reject(hObj,us,z);
        z(nanPos)=nan;

        if isa(ds,'matlab.graphics.axis.dataspace.CartesianDataSpace')
            xIsInvalid=...
            matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            ds.XScale,ds.XLim,x);
            yIsInvalid=...
            matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            ds.YScale,ds.YLim,y);
            zIsInvalid=...
            matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            ds.ZScale,ds.ZLim,z);
        else
            xIsInvalid=false(size(x));
            yIsInvalid=false(size(y));
            zIsInvalid=false(size(y));
        end
        x(xIsInvalid|yIsInvalid|zIsInvalid)=nan;
        y(xIsInvalid|yIsInvalid|zIsInvalid)=nan;
        z(xIsInvalid|yIsInvalid|zIsInvalid)=nan;
    end



    [X,Y,Z]=evaluateAt(X,Y);

    data.xdata_coarse=X(:);
    data.ydata_coarse=Y(:);
    data.zdata_coarse=Z(:);



    function v=wrapEval(x,y)
        [x,y,z]=evaluateAt(x,y);
        x=reshape(x,1,[]);
        y=reshape(y,1,[]);
        z=reshape(z,1,[]);
        v=[x;y;z;x;y];
    end
    [faceVertices,faceVertexIndices,innerBorders]=matlab.graphics.function.internal.triangulateOnRegularMesh(...
    @wrapEval,xlims,ylims,granX,granY);



    function p3=subdivide(p1,p2,oppCorner,xylimits)
        xy=(p1(1:2,:)+p2(1:2,:))/2;
        [x,y,z]=evaluateAt(xy(1,:).',xy(2,:).');
        if~isempty(oppCorner)




            for iter=1:10
                badPoints=isnan(z);
                toCorner=2^(-iter-1)*(oppCorner(1:2,:)-xy);
                tryxy=xy;
                tryxy(:,badPoints)=xy(:,badPoints)+toCorner(:,badPoints);
                tryxy(:,~badPoints)=xy(:,~badPoints)-toCorner(:,~badPoints);
                [newx,newy,newz]=evaluateAt(tryxy(1,:).',tryxy(2,:).');
                useThese=~isnan(newz);
                useThese=useThese&(newx>=xylimits(:,1))&(newx<=xylimits(:,2))&...
                (newy>=xylimits(:,3))&(newy<=xylimits(:,4));
                x(useThese)=newx(useThese);
                y(useThese)=newy(useThese);
                z(useThese)=newz(useThese);
                xy(:,useThese)=tryxy(:,useThese);
            end
        end
        p3=single([reshape(x,1,[]);reshape(y,1,[]);reshape(z,1,[])]);
    end
    [faceVertices,faceVertexIndices]=matlab.graphics.function.internal.subdivideMesh(...
    faceVertices(1:3,:),faceVertexIndices.',innerBorders,@subdivide,hObj.AdaptiveMeshDensity,ds);

    [faceVertices,faceVertexIndices]=matlab.graphics.function.internal.removeSteepTriangles(...
    faceVertices,faceVertexIndices,@subdivide,3,ds);

    done=false;
    if isa(hObj.Function,'sym')
        try
            f=hObj.Function;
            vars=symvar(f,2);
            while numel(vars)<2
                vars=[vars,feval_internal(symengine,'genident')];%#ok<AGROW>
            end
            dfdx=matlab.graphics.function.internal.sym2fn(diff(f,vars(1)),vars);
            dfdy=matlab.graphics.function.internal.sym2fn(diff(f,vars(2)),vars);
            x=reshape(faceVertices(1,:),1,[]);
            y=reshape(faceVertices(2,:),1,[]);
            normals=single([dfdx(x,y);dfdy(x,y);ones(size(x))]);
            normals(isnan(normals))=0;
            normals(normals>1e30)=1e30;
            normals(normals<-1e30)=-1e30;
            norms=sqrt(sum(normals.^2,1));
            norms(isnan(norms)|norms<eps)=eps;
            data.NormalData=bsxfun(@rdivide,normals,norms);
            done=isreal(data.NormalData);
        catch
        end
    end
    if~done
        data.NormalData=matlab.graphics.function.internal.normalData(faceVertices,faceVertexIndices);
    end

    data.FaceVertexIndices=uint32(reshape(faceVertexIndices.',1,[]));
    xyzdata=single(faceVertices(1:3,:));
    data.FaceVertices=xyzdata;

    data.xdata=xyzdata(1,:);
    data.ydata=xyzdata(2,:);
    data.zdata=xyzdata(3,:);







    xLinesAt=unique(data.xdata_coarse);
    yLinesAt=unique(data.ydata_coarse);
    xFuzz=max([0;diff(xLinesAt)])/10;
    yFuzz=max([0;diff(yLinesAt)])/10;
    xLines=arrayfun(@(x)find(abs(faceVertices(1,:)-x)<=xFuzz),xLinesAt,'UniformOutput',false);
    yLines=arrayfun(@(y)find(abs(faceVertices(2,:)-y)<=yFuzz),yLinesAt,'UniformOutput',false);
    for k=1:numel(xLines)
        line=xLines{k};
        [~,idx]=sort(faceVertices(2,line));
        xLines{k}=line(idx);
    end
    for k=1:numel(yLines)
        line=yLines{k};
        [~,idx]=sort(faceVertices(1,line));
        yLines{k}=line(idx);
    end
    lines=[xLines{:},yLines{:}];
    data.LineVertices=single(faceVertices(1:3,lines));
    edges=[faceVertexIndices(:,[1,2]);faceVertexIndices(:,[2,3]);faceVertexIndices(:,[1,3])];
    edges=unique(edges,'rows');
    properLines=ismember([lines(1:end-1).',lines(2:end).'],edges,'rows')|...
    ismember([lines(2:end).',lines(1:end-1).'],edges,'rows');
    data.LineStripData=uint32([1,1+find(~properLines).',...
    numel(lines)+1]);




    if~isempty(faceVertices)
        transdata=[faceVertices(1:3,:);ones(1,size(faceVertices,2))];
        transdata=transformation*transdata;
        transdata=bsxfun(@rdivide,transdata(1:3,:),transdata(4,:));

        xrange=matlab.graphics.function.internal.estimateViewingBox(transdata(1,:),-inf,inf);
        yrange=matlab.graphics.function.internal.estimateViewingBox(transdata(2,:),-inf,inf);
        zrange=matlab.graphics.function.internal.estimateViewingBox(transdata(3,:),-inf,inf);
        data.vbox=[xrange;yrange;zrange];
    end
end

function nanPos=reject(~,us,z)
    nanPos=~isfinite(z(:))|(imag(z(:))~=0);
    if isa(us,'matlab.graphics.eventdata.UpdateState')

        clipRange=us.DataSpace.ZLimWithInfs;
        clipRange=mean(clipRange)+100*(clipRange-mean(clipRange));
        nanPos=nanPos|(z(:)<clipRange(1))|(z(:)>clipRange(2));
    end
end

function lim=intersect(lim1,lim2)
    lim=[max(lim1(1),lim2(1)),min(lim1(2),lim2(2))];
end
