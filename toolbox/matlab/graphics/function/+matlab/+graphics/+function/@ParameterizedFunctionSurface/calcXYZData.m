function data=calcXYZData(hObj,us,transformation)




    gran=hObj.MeshDensity;
    data=struct('xdata_coarse',[],...
    'ydata_coarse',[],...
    'zdata_coarse',[],...
    'udata_coarse',[],...
    'vdata_coarse',[],...
    'vbox',[],...
    'LineVertices',zeros(3,0,'single'),'LineStripData',[],...
    'FaceVertices',zeros(3,0,'single'),'FaceVertexIndices',[],...
    'NormalData',zeros(3,0,'single'));
    if gran<2
        return
    end
    granU=gran;
    granV=gran;


    ulims=hObj.URange;
    vlims=hObj.VRange;

    [U,V]=meshgrid(linspace(ulims(1),ulims(2),granU),linspace(vlims(1),vlims(2),granV));
    if isempty(hObj.XFunction_fh_I)||isempty(hObj.YFunction_fh_I)||isempty(hObj.ZFunction_fh_I)
        hObj.updateFunctionHandles;
    end
    fnX=hObj.XFunction_fh_I;
    fnY=hObj.YFunction_fh_I;
    fnZ=hObj.ZFunction_fh_I;

    if isa(us,'matlab.graphics.eventdata.UpdateState')
        ds=us.DataSpace;
    elseif isa(us,'matlab.graphics.axis.dataspace.DataSpace')
        ds=us;
    else
        ds=hObj.getDataSpace;
    end




    function[u,v,x,y,z]=evaluateAt(u,v)
        try
            x=single(fnX(u,v));

            if isscalar(x)&&~isscalar(u)
                x=repmat(x,size(u));
            end
            y=single(fnY(u,v));

            if isscalar(y)&&~isscalar(u)
                y=repmat(y,size(u));
            end
            z=single(fnZ(u,v));

            if isscalar(z)&&~isscalar(u)
                z=repmat(z,size(u));
            end
        catch me
            error(message('MATLAB:FunctionLine:doUpdate',me.message));
        end
        nanPos=reject(hObj,us,x,y,z);

        x(nanPos)=nan;
        y(nanPos)=nan;
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



    [U,V,X,Y,Z]=evaluateAt(U,V);

    data.udata_coarse=U(:);
    data.vdata_coarse=V(:);
    data.xdata_coarse=X(:);
    data.ydata_coarse=Y(:);
    data.zdata_coarse=Z(:);



    function val=wrapEval(u,v)
        [u,v,x,y,z]=evaluateAt(u,v);
        val=[reshape(x,1,[]);reshape(y,1,[]);reshape(z,1,[]);reshape(u,1,[]);reshape(v,1,[])];
    end
    [faceVertices,faceVertexIndices,innerBorders]=matlab.graphics.function.internal.triangulateOnRegularMesh(...
    @wrapEval,ulims,vlims,granU,granV);



    function p3=subdivide(p1,p2,oppCorner,uvlimits)
        uv=(p1(4:5,:)+p2(4:5,:))/2;
        [u,v,x,y,z]=evaluateAt(uv(1,:),uv(2,:));
        if~isempty(oppCorner)




            for iter=1:10
                badPoints=isnan(x)|isnan(y)|isnan(z);
                toCorner=2^(-iter)*(oppCorner(4:5,:)-uv);
                tryuv=uv;
                tryuv(:,badPoints)=uv(:,badPoints)+toCorner(:,badPoints);
                tryuv(:,~badPoints)=uv(:,~badPoints)-toCorner(:,~badPoints);
                [newu,newv,newx,newy,newz]=evaluateAt(tryuv(1,:).',tryuv(2,:).');
                useThese=~isnan(newx)&~isnan(newy)&~isnan(newz);
                useThese=useThese&(newu>=uvlimits(:,1))&(newu<=uvlimits(:,2))&...
                (newv>=uvlimits(:,3))&(newv<=uvlimits(:,4));
                u(useThese)=newu(useThese);
                v(useThese)=newv(useThese);
                x(useThese)=newx(useThese);
                y(useThese)=newy(useThese);
                z(useThese)=newz(useThese);
                uv(:,useThese)=tryuv(:,useThese);
            end
        end
        p3=[x;y;z;u;v];
    end
    [faceVertices,faceVertexIndices]=matlab.graphics.function.internal.subdivideMesh(...
    faceVertices(1:5,:),faceVertexIndices.',innerBorders,@subdivide,hObj.AdaptiveMeshDensity,[]);

    [faceVertices,faceVertexIndices]=matlab.graphics.function.internal.removeSteepTriangles(...
    faceVertices,faceVertexIndices,@subdivide,1,ds);
    [faceVertices,faceVertexIndices]=matlab.graphics.function.internal.removeSteepTriangles(...
    faceVertices,faceVertexIndices,@subdivide,2,ds);
    [faceVertices,faceVertexIndices]=matlab.graphics.function.internal.removeSteepTriangles(...
    faceVertices,faceVertexIndices,@subdivide,3,ds);

    data.NormalData=matlab.graphics.function.internal.normalData(faceVertices,faceVertexIndices);

    data.FaceVertexIndices=uint32(reshape(faceVertexIndices.',1,[]));

    xyzdata=single(faceVertices(1:3,:));
    data.FaceVertices=xyzdata;

    data.xdata=xyzdata(1,:);
    data.ydata=xyzdata(2,:);
    data.zdata=xyzdata(3,:);
    data.udata=faceVertices(4,:);
    data.vdata=faceVertices(5,:);







    uLinesAt=unique(data.udata_coarse);
    vLinesAt=unique(data.vdata_coarse);
    uFuzz=max([0;diff(uLinesAt)])/10;
    vFuzz=max([0;diff(vLinesAt)])/10;
    uLines=arrayfun(@(u)find(abs(data.udata-u)<=uFuzz),uLinesAt,'UniformOutput',false);
    vLines=arrayfun(@(v)find(abs(data.vdata-v)<=vFuzz),vLinesAt,'UniformOutput',false);
    for k=1:numel(uLines)
        line=uLines{k};
        [~,idx]=sort(faceVertices(5,line));
        uLines{k}=line(idx);
    end
    for k=1:numel(vLines)
        line=vLines{k};
        [~,idx]=sort(faceVertices(4,line));
        vLines{k}=line(idx);
    end
    lines=[uLines{:},vLines{:}];
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

function nanPos=reject(~,us,x,y,z)
    nanPos=~isfinite(x(:))|(imag(x(:))~=0)|...
    ~isfinite(y(:))|(imag(y(:))~=0)|...
    ~isfinite(z(:))|(imag(z(:))~=0);
    if isa(us,'matlab.graphics.eventdata.UpdateState')

        clipRange=us.DataSpace.XLimWithInfs;
        clipRange=mean(clipRange)+100*(clipRange-mean(clipRange));
        nanPos=nanPos|(x(:)<clipRange(1))|(x(:)>clipRange(2));

        clipRange=us.DataSpace.YLimWithInfs;
        clipRange=mean(clipRange)+100*(clipRange-mean(clipRange));
        nanPos=nanPos|(y(:)<clipRange(1))|(y(:)>clipRange(2));

        clipRange=us.DataSpace.ZLimWithInfs;
        clipRange=mean(clipRange)+100*(clipRange-mean(clipRange));
        nanPos=nanPos|(z(:)<clipRange(1))|(z(:)>clipRange(2));
    end
end
