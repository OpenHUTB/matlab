function[BorderVertices,Polygons,DoNotPlot,BoundaryEdges]=...
    makeArrayGeometry(geom,translateVector,offset,~)



    BorderVertices=em.internal.translateshape(geom{1}.BorderVertices',...
    translateVector(1,:));
    BorderVertices=BorderVertices';

    Polygons=geom{1}.polygons;
    BoundaryEdges=geom{1}.BoundaryEdges;

    for i=2:numel(geom)
        translatedBorderVertices=em.internal.translateshape(geom{i}.BorderVertices',...
        translateVector(i,:));
        BorderVertices=[BorderVertices;translatedBorderVertices'];%#ok<AGROW>
        offsetIndex=cellfun(@max,geom{i-1}.polygons,'UniformOutput',false);
        offsetIndex=max(max(cell2mat(offsetIndex)))-offset;
        geom{i}.polygons=cellfun(@(x)offsetIndex+x,geom{i}.polygons,...
        'UniformOutput',false);
        geom{i}.BoundaryEdges=cellfun(@(x)offsetIndex+x,geom{i}.BoundaryEdges,...
        'UniformOutput',false);
        BoundaryEdges=[BoundaryEdges,geom{i}.BoundaryEdges];%#ok<AGROW>
        Polygons=[Polygons,geom{i}.polygons];%#ok<AGROW>   
    end
    DoNotPlot=zeros(1,numel(Polygons));
