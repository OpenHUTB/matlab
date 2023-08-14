function meshstruct=meshinfo(obj)
    if~isfield(obj.MesherStruct.Mesh,'p')
        numTriangles=[];
        maxLenTriangles=[];
        numEdges=[];
    elseif obj.MesherStruct.infGP
        if size(obj.MesherStruct.Mesh.T,2)==0
            numTriangles=size(obj.MesherStruct.Mesh.t,2)/2;
            numTets=size(obj.MesherStruct.Mesh.T,2);
        else
            numTriangles=size(obj.MesherStruct.Mesh.t,2);
            numTets=size(obj.MesherStruct.Mesh.T,2);
        end

        maxLenTriangles=obj.MesherStruct.Mesh.MaxEdgeLength;
        if isfield(obj.MesherStruct.Mesh,'numEdges')
            if obj.MesherStruct.infGPconnected
                NumJoints=size(obj.FeedLocation,1);
                MySize=(obj.MesherStruct.Mesh.numEdges-NumJoints)/2;
                numEdges=MySize+NumJoints;
            else
                numEdges=obj.MesherStruct.Mesh.numEdges/2;
            end
        else
            numEdges=[];
        end
    else
        numTriangles=size(obj.MesherStruct.Mesh.t,2);
        numTets=size(obj.MesherStruct.Mesh.T,2);
        maxLenTriangles=obj.MesherStruct.Mesh.MaxEdgeLength;
        if isfield(obj.MesherStruct.Mesh,'numEdges')
            numEdges=obj.MesherStruct.Mesh.numEdges;
        else
            numEdges=[];
        end
    end
    if isfield(obj.MesherStruct.Mesh,'dielEdges')
        dielEdges=obj.MesherStruct.Mesh.dielEdges;
    else
        dielEdges=0;
    end
    if isempty(numEdges)
        dielEdges=[];
    end
    if numTets==0
        dielEdges=0;
    end
    meshingChoice=obj.MesherStruct.MeshingChoice;
    minLenTriangles=getMinContourEdgeLength(obj);
    growthRate=getMeshGrowthRate(obj)-1;
    meshstruct=struct('NumTriangles',numTriangles,...
    'NumTetrahedra',numTets,...
    'NumBasis',numEdges+dielEdges,...
    'MaxEdgeLength',max(maxLenTriangles),...
    'MinEdgeLength',min(minLenTriangles),...
    'GrowthRate',growthRate,...
    'MeshMode',meshingChoice);
end