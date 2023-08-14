function[BorderVertices,Polygons,DoNotPlot,BoundaryEdges]=...
    makeArrayGeometryForConformalArray(geom,translateVector,offset,InfGP,flag)%#ok<INUSD>

    if nargin>4

        BorderVertices=em.internal.translateshape(geom{1}.BorderVertices',...
        translateVector(1*2,:));
        BorderVertices=BorderVertices';
        DoNotPlot=geom{1}.doNotPlot;
        Polygons=geom{1}.polygons;
        BoundaryEdges=[];
        isBoundaryEdges=false;
        if isfield(geom{1},'BoundaryEdges')
            BoundaryEdges=geom{1}.BoundaryEdges;

            if~isempty(DoNotPlot)&&~isscalar(DoNotPlot)
                if~InfGP
                    DoNotPlot=DoNotPlot(2:end);
                end
                numDNP=numel(DoNotPlot);
            else
                DoNotPlot=0;
                numDNP=1;
            end
            isBoundaryEdges=true;%#ok<*NASGU>
        end
        for i=2:numel(geom)
            translatedBorderVertices=em.internal.translateshape(geom{i}.BorderVertices',...
            translateVector(i*2,:));
            BorderVertices=[BorderVertices;translatedBorderVertices'];%#ok<AGROW>
            offsetIndex=cellfun(@max,geom{i-1}.polygons,'UniformOutput',false);
            offsetIndex=max(max(cell2mat(offsetIndex)))-offset;
            geom{i}.polygons=cellfun(@(x)offsetIndex+x,geom{i}.polygons,...
            'UniformOutput',false);
            if isfield(geom{i},'BoundaryEdges')
                geom{i}.BoundaryEdges=cellfun(@(x)offsetIndex+x,geom{i}.BoundaryEdges,...
                'UniformOutput',false);
                BoundaryEdges=[BoundaryEdges,geom{i}.BoundaryEdges];%#ok<AGROW>
                if InfGP
                    DoNotPlot=[DoNotPlot,geom{i}.doNotPlot];%#ok<AGROW>
                else
                    DoNotPlot=[DoNotPlot,zeros(1,numDNP)];%#ok<AGROW>
                end
            else
                BoundaryEdges=[BoundaryEdges,nan];%#ok<AGROW>          -> Need to fix this,
                DoNotPlot=[DoNotPlot,geom{i}.doNotPlot];%#ok<AGROW>
            end
            Polygons=[Polygons,geom{i}.polygons];%#ok<AGROW>
        end

    else
        Max=0;
        for i=1:numel(geom)
            j=i*2;
            geom{i,1}{1,1}.polygons=cellfun(@(x)Max+x,geom{i,1}{1,1}.polygons,'UniformOutput',false);
            geom{i,1}{1,1}.BoundaryEdges=cellfun(@(x)Max+x,geom{i,1}{1,1}.BoundaryEdges,'UniformOutput',false);
            [bordervertices{i},polygons,DoNotPlot{i},boundaryedges]=em.ArrayProp.makeArrayGeometry(geom{i,1}',...
            translateVector(j-1:j,:),offset,InfGP);%#ok<AGROW>
            borderVertices=cell2mat(bordervertices');
            [Max,~]=size(borderVertices);
            if i==1
                Polygons=polygons;
                BoundaryEdges=boundaryedges;
            else
                Polygons=[Polygons,polygons];%#ok<AGROW>
                BoundaryEdges=[BoundaryEdges,boundaryedges];%#ok<AGROW>
            end
        end
        BorderVertices=cell2mat(bordervertices');
        DoNotPlot=cell2mat(DoNotPlot);

    end
end