function Mi=makeHomogeneousArrayMeshWithDielectric(obj)




    if isa(obj,'linearArray')||isa(obj,'circularArray')
        numelements=obj.NumElements;
    else
        numelements=prod(obj.Size);
    end

    edgeLength=getMeshEdgeLength(obj);
    if isempty(edgeLength)
        edgeLength=getMeshingLambda(obj)/10;
    end
    growthRate=getMeshGrowthRate(obj);

    if~isscalar(edgeLength)
        if any(edgeLength(2:end)-edgeLength(1)~=0)
            error(message('antenna:antennaerrors:MultipleMaxEdgeLengthSpecified'));
        elseif numel(edgeLength)>=numelements


            edgeLength=edgeLength(1);
            warning(message('antenna:antennaerrors:MaxEdgeLengthSpecifiedExceedsSizeOfElement'));
        end
    else
        edgeLength=edgeLength(1);
    end

    if~isscalar(growthRate)
        if any(growthRate(2:end)-growthRate(1)~=0)
            error(message('antenna:antennaerrors:MultipleGrowthRateSpecified'));
        else
            growthRate=growthRate(1);
        end
    end

    [~]=mesh(obj.Element,'MaxEdgeLength',edgeLength);

    [pPart,tPart]=collapsePartMesh(obj);



    obj.MesherStruct.Mesh.ArrayParts.p={[]};
    obj.MesherStruct.Mesh.ArrayParts.t={[]};
    ZeroGPState=(isequal(obj.GroundPlaneLength,0))||...
    (isequal(obj.GroundPlaneWidth,0));
    if~((isa(obj.Element,'draRectangular')||isa(obj.Element,'draCylindrical'))&&...
        (isinf(obj.Element.GroundPlaneLength)||(isinf(obj.Element.GroundPlaneWidth))))...
        ||(isa(obj.Element,'helix'))
        if~ZeroGPState

            [pGP,tGP]=makeGroundPlaneMesh(obj,edgeLength,growthRate);
        else

            [pGP,tGP]=meshSubstrateBase(obj);
        end
    else
        [pGP,tGP]=meshSubstrateBase(obj);
    end




    numParts=obj.Element.MesherStruct.Mesh.PartMesh.NumParts;
    if~isequal(obj.Element.MesherStruct.Mesh.PartMesh.NumFeeds,0)&&isequal(numParts,3)
        [p_rad,t_rad]=assembleArrayMesh(obj,pPart{3},tPart{3},numelements);
    else
        [p_rad,t_rad]=assembleArrayMesh(obj,pPart{2},tPart{2},numelements);
    end


    p_rad=cell2mat(p_rad');
    t_rad=cell2mat(t_rad');


    Mi=em.internal.meshprinting.imprintMesh(p_rad',t_rad(1:3,:)',pGP',tGP(1:3,:)');
    numLayers=checkSubstrateThicknessVsLambda(obj.Substrate,obj.Element);
    Mi.NumLayers=numLayers;


    obj.MesherStruct.Mesh.ArrayParts.p={p_rad};
    obj.MesherStruct.Mesh.ArrayParts.t={t_rad};

    if isfield(obj.Element.MesherStruct.Mesh.PartMesh,'GndConnectionDomain')&&...
        ~isempty(obj.Element.MesherStruct.Mesh.PartMesh.GndConnectionDomain)


        [feed_pt1,feed_pt2]=em.internal.findPortPoints(Mi.P,Mi.t,obj.DefaultFeedLocation);
        Mi.FeedVertex1=[feed_pt1];
        Mi.FeedVertex2=[feed_pt2];
    else


        Mi.FeedVertex1=[];
        Mi.FeedVertex2=[];
    end


    meshconfig(obj.Element,'auto');

end

function[p,t]=assembleArrayMesh(obj,p_temp,t_temp,numelements)
    p=cell(numelements,1);
    t=cell(numelements,1);
    p{1}=em.internal.translateshape(p_temp,obj.TranslationVector(1,:));
    t{1}=t_temp;
    obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;p(1)];
    obj.MesherStruct.Mesh.ArrayParts.t=[obj.MesherStruct.Mesh.ArrayParts.t;{t_temp}];
    offset_index=max(size(p_temp));
    for i=2:numelements
        p{i}=em.internal.translateshape(p_temp,obj.TranslationVector(i,:));


        obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;p(i)];
        obj.MesherStruct.Mesh.ArrayParts.t=[obj.MesherStruct.Mesh.ArrayParts.t;{t_temp}];
        t{i}(1:3,:)=t{i-1}(1:3,:)+offset_index;
        t{i}(4,:)=t{i-1}(4,:);
    end
end
