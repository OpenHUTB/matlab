function data=calcXYZData(hObj,us)




    gran=hObj.MeshDensity;
    data=struct('vbox',[],...
    'LineVertices',zeros(3,0,'single'),'LineStripData',[],...
    'FaceVertices',zeros(3,0,'single'),'FaceVertexIndices',[],...
    'MarkerPoints',zeros(3,0,'single'),...
    'NormalData',zeros(3,0,'single'));
    if gran<2
        return
    end
    granX=gran;
    granY=gran;
    granZ=gran;


    lims=[-inf,inf;-inf,inf;-inf,inf];

    transformation=eye(4);

    if isa(us,'matlab.graphics.eventdata.UpdateState')
        ds=us.DataSpace;
        lims=[ds.XLim;ds.YLim;ds.ZLim];
        transformation=us.Transform;
    else
        if isa(us,'matlab.graphics.axis.dataspace.DataSpacee')
            ds=us;
        else
            ds=hObj.getDataSpace;
        end


        try
            if~strcmp(ds.XLimMode,'auto')
                lims(1,:)=ds.XLim;
            end
            if~strcmp(ds.YLimMode,'auto')
                lims(2,:)=ds.YLim;
            end
            if~strcmp(ds.ZLimMode,'auto')
                lims(3,:)=ds.ZLim;
            end
        catch
        end
    end

    if~isequal(transformation,eye(4))
        corners=[repelem(lims(1,:),1,2);repmat(lims(2,:),1,2)];
        corners=[repelem(corners,1,2);repmat(lims(3,:),1,4);ones(1,8)];
        backtransformed=transformation\corners;
        vbox=[min(backtransformed,[],2),max(backtransformed,[],2)];
        if~any(isnan(vbox),'all')
            lims=vbox(1:3,:)./vbox(4,:);
        end
    end

    if strcmp(hObj.XRangeMode,'manual')||isequal(lims(1,:),[-inf,inf])
        lims(1,:)=intersect(hObj.XRange,lims(1,:));
    end
    if strcmp(hObj.YRangeMode,'manual')||isequal(lims(2,:),[-inf,inf])
        lims(2,:)=intersect(hObj.YRange,lims(2,:));
    end
    if strcmp(hObj.ZRangeMode,'manual')||isequal(lims(3,:),[-inf,inf])
        lims(3,:)=intersect(hObj.ZRange,lims(3,:));
    end

    if strcmp(hObj.XRangeMode,'auto')
        hObj.XRange_I=lims(1,:);
    end
    if strcmp(hObj.YRangeMode,'auto')
        hObj.YRange_I=lims(2,:);
    end
    if strcmp(hObj.ZRangeMode,'auto')
        hObj.ZRange_I=lims(3,:);
    end

    if any(lims(:,2)<lims(:,1))
        return
    end


    scaleX='';
    scaleY='';
    scaleZ='';

    linesAt{1}=matlab.graphics.function.internal.initialMesh(hObj,lims(1,:),granX,scaleX);
    linesAt{2}=matlab.graphics.function.internal.initialMesh(hObj,lims(2,:),granY,scaleY);
    linesAt{3}=matlab.graphics.function.internal.initialMesh(hObj,lims(3,:),granZ,scaleZ);
    [X,Y,Z]=meshgrid(linesAt{1},linesAt{2},linesAt{3});

    if isempty(hObj.Function_fh_I)
        hObj.updateFunction;
    end
    fn=hObj.Function_fh_I;

    function[x,y,z,v]=evaluateAt(x,y,z)
        try
            v=reshape(single(fn(x(:).',y(:).',z(:).')),size(x));

            if isscalar(v)&&~isscalar(x)
                v=repmat(v,size(x));
            end
        catch me
            error(message('MATLAB:FunctionLine:doUpdate',me.message));
        end
        nanPos=reject(hObj,us,v);
        v(nanPos)=nan;
    end




    [X,Y,Z,V]=evaluateAt(X,Y,Z);

    [f,v]=isosurface(X,Y,Z,V,0);

    data.FaceVertices=v.';
    data.FaceVertexIndices=uint32(reshape(f.',1,[]));
    V(isnan(V))=42;
    normals=single(isonormals(X,Y,Z,V,v)).';
    data.NormalData=normals./arrayfun(@(n)norm(normals(:,n),2)+eps,1:size(normals,2));




    if~isempty(f)
        edges=[f(:,[1,2]);f(:,[2,3]);f(:,[1,3])];
        for x=linesAt{1}
            atHeight=find(v(:,1)==x);
            properLines=ismember(edges(:,1),atHeight)&ismember(edges(:,2),atHeight);

            vertexData=data.FaceVertices([3,2,1],reshape(edges(properLines,:).',1,[]));
            n=size(vertexData,2);
            if n>0
                stripData=uint32(1:2:n+1);
                [vertexData,stripData]=matlab.graphics.chart.internal.contour.linkLineStrips(...
                vertexData,stripData);
                data.LineStripData=[data.LineStripData,stripData+size(data.LineVertices,2)];
                data.LineVertices=[data.LineVertices,vertexData([3,2,1],:)];
            end
        end
        for y=linesAt{2}
            atHeight=find(v(:,2)==y);
            properLines=ismember(edges(:,1),atHeight)&ismember(edges(:,2),atHeight);

            vertexData=data.FaceVertices([1,3,2],reshape(edges(properLines,:).',1,[]));
            n=size(vertexData,2);
            if n>0
                stripData=uint32(1:2:n+1);
                [vertexData,stripData]=matlab.graphics.chart.internal.contour.linkLineStrips(...
                vertexData,stripData);
                data.LineStripData=[data.LineStripData,stripData+size(data.LineVertices,2)];
                data.LineVertices=[data.LineVertices,vertexData([1,3,2],:)];
            end
        end
        for z=linesAt{3}
            atHeight=find(v(:,3)==z);
            properLines=ismember(edges(:,1),atHeight)&ismember(edges(:,2),atHeight);
            vertexData=data.FaceVertices(1:3,reshape(edges(properLines,:).',1,[]));
            n=size(vertexData,2);
            if n>0
                stripData=uint32(1:2:n+1);
                [vertexData,stripData]=matlab.graphics.chart.internal.contour.linkLineStrips(...
                vertexData,stripData);
                data.LineStripData=[data.LineStripData,stripData+size(data.LineVertices,2)];
                data.LineVertices=[data.LineVertices,vertexData];
            end
        end
    end



    if~isempty(f)

        [~,ind]=unique(data.LineVertices.','rows');

        seen_twice=setdiff(1:size(data.LineVertices,2),ind);
        data.MarkerPoints=unique(data.LineVertices(:,seen_twice).','rows').';
    end








    if~isempty(data.FaceVertices)
        dataFound=feather_out(min(data.FaceVertices,[],2),max(data.FaceVertices,[],2));

        vbox=dataFound;

        for dim=1:3
            if dataFound(dim,2)-dataFound(dim,1)<0.3*(lims(dim,2)-lims(dim,1))
                xyzLess=linesAt{dim}(linesAt{dim}<dataFound(dim,1));
                if~isempty(xyzLess)
                    vbox(dim,1)=max(xyzLess);
                end
                xyzGreater=linesAt{dim}(linesAt{dim}>dataFound(dim,2));
                if~isempty(xyzGreater)
                    vbox(dim,2)=min(xyzGreater);
                end
            end
        end

        data.vbox=[...
        intersect(vbox(1,:),lims(1,:));...
        intersect(vbox(2,:),lims(2,:));...
        intersect(vbox(3,:),lims(3,:))];
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

function lim=feather_out(lim1,lim2)
    center=(lim1+lim2)/2;
    width=lim2-lim1;
    lim=[center-0.55*width,center+0.55*width];
end
