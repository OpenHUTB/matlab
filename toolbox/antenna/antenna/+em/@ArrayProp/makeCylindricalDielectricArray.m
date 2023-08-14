function[SubstrateVertices,SubstratePolygons,SubstrateBoundary,SubstrateBoundaryVertices]=makeCylindricalDielectricArray(obj)




    if isa(obj,'linearArray')||isa(obj,'circularArray')
        numiter=obj.NumElements;
    elseif isa(obj,'rectangularArray')
        numiter=obj.Size(1)*obj.Size(2);
    end
    numsub=numel(obj.Element.Substrate.EpsilonR);
    SubstrateVertices=[];SubstratePolygons=cell(1,numiter);
    SubstrateBoundary=cell(1,numiter);SubstrateBoundaryVertices=[];
    for i=1:numiter
        [SubVertices,SubPolygons,...
        SubBoundary,SubBoundaryVertices]=...
        makeSubstrateGeometry(obj);
        si=size(SubVertices,1);
        si1=size(SubBoundaryVertices,1);
        translatevect=orientGeom(obj,obj.TranslationVector(i,:)');

        SubstrateVertices(end+1:end+si,:)=SubVertices+...
        translatevect';
        SubstrateBoundaryVertices(end+1:end+si1,:)=SubBoundaryVertices+...
        translatevect';
        if~(i==1)
            if~(i==2)
                size1=size1+size(SubVertices,1);
                size2=size2+size(SubBoundaryVertices,1);
            end
        else
            size1=size(SubVertices,1);
            size2=size(SubBoundaryVertices,1);
        end
        if numsub>1

            if i==1
                SubstratePolygons=SubPolygons';
                SubstrateBoundary=SubBoundary';
            else
                SubPolygonsnew=cell(1,numel(SubPolygons));
                SubBoundarynew=cell(1,numel(SubBoundary));
                for b=1:numel(SubPolygons)
                    SubPolygonsnew{b}=(SubPolygons{b})+size1;
                    SubBoundarynew{b}=(SubBoundary{b})+size2;
                end
                SubstratePolygons(end+1:end+numel(SubPolygons),1)=SubPolygonsnew';
                SubstrateBoundary(end+1:end+numel(SubBoundary),1)=SubBoundarynew';
            end
        else
            if i==1
                SubstratePolygons={[SubPolygons{i}]};
                SubstrateBoundary={[SubBoundary{i}]};
            else
                SubstratePolygons{i}=cell2mat(SubPolygons)+size1;
                SubstrateBoundary{i}=cell2mat(SubBoundary)+size2;
            end
        end
    end
end
