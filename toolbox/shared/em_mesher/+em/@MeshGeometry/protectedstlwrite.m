function protectedstlwrite(obj,fileName)



















    narginchk(2,2);
    if any(cellfun(@(x)isa(obj,x),{'customAntennaMesh','customArrayMesh'}))
        p=obj.Points';
        t=obj.Triangles';
        if isempty(p)||isempty(t)
            error(message('antenna:antennaerrors:FailureMeshGen'));
        end
    else
        [p,t]=exportMesh(obj);
    end

    if(isempty(t)||obj.MesherStruct.HasStructureChanged)&&...
        ~isa(obj,'customAntennaStl')&&~isa(obj,'customAntennaMesh')&&...
        ~isa(obj,'customArrayMesh')
        objCopy=copy(obj);

        createGeometry(objCopy);

        geom=getGeometry(objCopy);
        if iscell(geom)
            v=cellfun(@(x)x.BorderVertices',geom,'UniformOutput',false);
            pv=cellfun(@(x)[min(x,[],2),max(x,[],2)],v,'UniformOutput',false);
            dist=cellfun(@(x)norm(x(:,2)-x(:,1)),pv);
            edgeLength=max(dist);
            maxel=edgeLength/5;
        else
            v=geom.BorderVertices';

            pv=[min(v,[],2),max(v,[],2)];
            dist=norm(pv(:,2)-pv(:,1));
            edgeLength=max(dist);
            maxel=edgeLength/5;
        end
        outstr=sprintf('<a href="matlab:help %s">%s</a>','antenna',...
        'help antenna');
        warning('off','backtrace');
        warning(message('antenna:antennaerrors:NoMeshForSTLWrite',[num2str(maxel),'m'],outstr));

        [~]=mesh(objCopy,'MaxEdgeLength',maxel);
        [p,t]=exportMesh(objCopy);
    end

    warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');

    if~isempty(p)
        TR=triangulation(t(:,1:3),p);
        warning(warnState);

        stlwrite(TR,fileName,'text','SolidIndex',t(:,4)+1)
    elseif isa(obj,'customAntennaStl')
        TR=obj.getTriangulation();
        solidID=obj.getDomains();
        warning(warnState);

        stlwrite(TR,fileName,'text','SolidIndex',solidID)
    end

    warning('on','backtrace');
end

