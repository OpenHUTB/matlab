function shVertexData=calculatePolygonSelectionHandles(EdgeSD,EdgeVD,NumSHPerEdge)




    edgeSelectionIndices=matlab.graphics.primitive.polygon.internal.calculateSelectionHandleIndices(EdgeSD,NumSHPerEdge);
    shVertexData=EdgeVD(:,edgeSelectionIndices);
