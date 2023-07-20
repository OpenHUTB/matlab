function[p_temp,t_temp,layer_heights]=runMeshGeneratorForEachLayer(obj,tempMetalLayers,gndLayers,localConnModel)


    maxEdgeLength=getMeshEdgeLength(obj);
    growthRate=getMeshGrowthRate(obj);
    if growthRate<1
        growthRate=growthRate+1;
    end
    minEdgeLength=getMinContourEdgeLength(obj);



    subDomainEdgeLength=min(getFeedWidth(obj));

    if~isempty(obj.ViaLocations)
        vialoc=[obj.ViaLocations(:,1:2)];
        vialoc(:,3)=0;
    else
        vialoc=[];
    end
    feedloc=obj.FeedLocations(:,1:2);
    feedloc(:,3)=0;
    for i=1:numel(obj.MetalLayers)
        setSubDomainEdgeLength(tempMetalLayers{i},subDomainEdgeLength);
        setTargetInteriorEdgeLength(tempMetalLayers{i},0);
        [indxFeedLoc,indxViaLoc]=findLayerIdInStack(obj,i);
        if~isempty(indxFeedLoc)
            f=feedloc(indxFeedLoc,:);
            msg='Feed';
        else
            f=[];
        end
        if~isempty(indxViaLoc)
            v=vialoc(indxViaLoc,:);
            msg='Via';
        else
            v=[];
        end
        if~isempty(indxFeedLoc)&&~isempty(indxViaLoc)
            msg='Feed or Via';
        end
        tempMetalLayers{i}.MesherStruct.Mesh.PartMesh.Others.p=[v;f];
        if~strcmpi(localConnModel,'strip')
            feedtype='multiedge';
        else
            feedtype='strip';
        end
        tempMetalLayers{i}.MesherStruct.Mesh.PartMesh.Others.t=feedtype;
        try
            [~]=mesh(tempMetalLayers{i},'MaxEdgeLength',maxEdgeLength,...
            'MinEdgeLength',minEdgeLength,...
            'GrowthRate',growthRate);
        catch ME
            if strcmpi(ME.identifier,'antenna:antennaerrors:IncorrectFeedOrViaDiameter')
                error(message('antenna:antennaerrors:IncorrectFeedOrViaDiameter',msg));
            else
                rethrow(ME);
            end
        end
    end

    [p_temp,t_temp]=cellfun(@getMesh,tempMetalLayers,'UniformOutput',false);
    layerdomain=[1:numel(p_temp)]';
    layer_heights=calculateLayerZCoords(obj);
    for i=1:numel(p_temp)
        p_temp{i}(3,:)=layer_heights(i);
        t_temp{i}(4,:)=layerdomain(i);
    end



    obj.MetalLayersCopy=tempMetalLayers;





    if~isempty(gndLayers)
        gndL=unique(gndLayers);
        if isscalar(gndL)
            layerdomain=circshift(layerdomain,gndL-1);
        end
        for i=1:numel(t_temp)

            t_temp{i}(4,:)=layerdomain(i);
        end
    end

    obj.LayerPoints=p_temp;
    obj.LayerTriangles=t_temp;