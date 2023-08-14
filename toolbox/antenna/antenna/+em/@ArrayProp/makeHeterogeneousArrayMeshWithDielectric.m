function Mi=makeHeterogeneousArrayMeshWithDielectric(obj)

    edgeLength=getMeshEdgeLength(obj);
    growthRate=getMeshGrowthRate(obj);

    if isa(obj,'linearArray')||isa(obj,'circularArray')
        numelements=obj.NumElements;
    else
        numelements=prod(obj.Size);
    end



    obj.MesherStruct.Mesh.ArrayParts.p={[]};
    obj.MesherStruct.Mesh.ArrayParts.t={[]};


    if isa(obj,'linearArray')||isa(obj,'circularArray')


        if isscalar(edgeLength)
            edgeLength=edgeLength.*ones(obj.NumElements,1);
        else

            if numel(edgeLength)<obj.NumElements
                error(message('antenna:antennaerrors:InsufficientMaxEdgeLengthSpecified'));
            end


            if numel(edgeLength)>obj.NumElements
                edgeLength=edgeLength(1:obj.NumElements);
                warning(message('antenna:antennaerrors:MaxEdgeLengthSpecifiedExceedsSizeOfElement'));
            end
        end
    else


        if isscalar(edgeLength)
            edgeLength=edgeLength.*ones(obj.Size);
        else

            if numel(edgeLength)<prod(obj.Size)
                error(message('antenna:antennaerrors:InsufficientMaxEdgeLengthSpecified'));
            end


            if size(edgeLength,1)>obj.Size(1)&&size(edgeLength,2)>obj.Size(2)
                edgeLength=edgeLength(obj.Size(1),obj.Size(2));
                warning(message('antenna:antennaerrors:MaxEdgeLengthSpecifiedExceedsSizeOfElement'));
            end
        end
    end

    for i=1:numelements
        [~]=mesh(obj.Element(i),'MaxEdgeLength',edgeLength(i));

        meshconfig(obj.Element(i),'auto');
    end

    [pPart,tPart]=collapsePartMesh(obj);


    obj.MesherStruct.Mesh.ArrayParts.p={[]};
    obj.MesherStruct.Mesh.ArrayParts.t={[]};
    ZeroGPState=(isequal(obj.GroundPlaneLength,0))||...
    (isequal(obj.GroundPlaneWidth,0));

    if~ZeroGPState

        [pGP,tGP]=makeGroundPlaneMesh(obj,max(max(edgeLength)),max(max(growthRate)));
    else

        [pGP,tGP]=meshSubstrateBase(obj);
    end

    obj.MesherStruct.Mesh.ArrayParts.p={pGP};
    obj.MesherStruct.Mesh.ArrayParts.t={tGP};

    numParts=obj.Element(1).MesherStruct.Mesh.PartMesh.NumParts;



    if~isequal(obj.Element(1).MesherStruct.Mesh.PartMesh.NumFeeds,0)&&isequal(numParts,3)
        [p_rad,t_rad]=assembleArrayMesh(obj,pPart(:,3)',tPart(:,3)',numelements);
    else
        [p_rad,t_rad]=assembleArrayMesh(obj,pPart(:,2)',tPart(:,2)',numelements);
    end

    [p_element,t_element]=getArrayPartMesh(obj);
    geom=obj.MesherStruct.Geometry;

    if~isempty(p_element{1})
        geom.polygons=obj.MesherStruct.Geometry.polygons(2:end);
    end

    flag=em.internal.isIntersecting(p_element(2:end),t_element(2:end),geom);
    if any(flag)
        error(message('antenna:antennaerrors:IntersectingGeometry'));
    end

    p_rad=cell2mat(p_rad');
    t_rad=cell2mat(t_rad');


    Mi=em.internal.meshprinting.imprintMesh(p_rad',t_rad(1:3,:)',pGP',tGP(1:3,:)');
    numLayers=checkSubstrateThicknessVsLambda(obj.Substrate,obj.Element);
    Mi.NumLayers=numLayers;


    obj.MesherStruct.Mesh.ArrayParts.p={p_rad};
    obj.MesherStruct.Mesh.ArrayParts.t={t_rad};

    if isfield(obj.Element(1).MesherStruct.Mesh.PartMesh,'GndConnectionDomain')&&...
        ~isempty(obj.Element(1).MesherStruct.Mesh.PartMesh.GndConnectionDomain)


        [feed_pt1,feed_pt2]=em.internal.findPortPoints(Mi.P,Mi.t,obj.DefaultFeedLocation);
        Mi.FeedVertex1=[feed_pt1];
        Mi.FeedVertex2=[feed_pt2];
    else


        Mi.FeedVertex1=[];
        Mi.FeedVertex2=[];
    end

end

function[p,t]=assembleArrayMesh(obj,p_temp,t_temp,numelements)
    p=cell(numelements,1);
    t=cell(numelements,1);
    p{1}=em.internal.translateshape(p_temp{1},obj.TranslationVector(1,:));
    t{1}=t_temp{1};
    obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;p(1)];
    obj.MesherStruct.Mesh.ArrayParts.t=[obj.MesherStruct.Mesh.ArrayParts.t;t_temp(:)];
    for i=2:numelements
        p{i}=em.internal.translateshape(p_temp{i},obj.TranslationVector(i,:));
        offset_index=max(max(t{i-1}));


        obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;p(i)];
        t{i}(1:3,:)=t_temp{i}(1:3,:)+offset_index;
        t{i}(4,:)=t_temp{i}(4,:);
    end
end
