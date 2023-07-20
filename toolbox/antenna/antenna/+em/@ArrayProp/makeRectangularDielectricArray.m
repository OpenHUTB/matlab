function[SubstrateVertices,SubstratePolygons]=makeRectangularDielectricArray(obj)





    if isa(obj,'linearArray')||isa(obj,'circularArray')
        numiter=obj.NumElements;
    elseif isa(obj,'rectangularArray')
        numiter=obj.Size(1)*obj.Size(2);
    end
    numsub=numel(obj.Element.Substrate.EpsilonR);
    SubstrateVertices=[];SubstratePolygons=cell(1,numiter);


    for i=1:numiter
        [SubVertices,SubPolygons]=makeSubstrateGeometry(obj);
        si=size(SubVertices,1);
        translatevect=orientGeom(obj,obj.TranslationVector(i,:)');
        SubstrateVertices(end+1:end+si,:)=SubVertices+...
        translatevect';
        if~(i==1)
            if~(i==2)
                size1=size1+size(SubVertices,1);
            end
        else
            size1=size(SubVertices,1);
        end
        if numsub>1

            if i==1
                SubstratePolygons=SubPolygons;
            else
                SubPolygonsnew=cell(1,numel(SubPolygons));
                for b=1:numel(SubPolygons)
                    SubPolygonsnew{b}=(SubPolygons{b})+size1;
                end

                SubstratePolygons(end+1:end+numel(SubPolygons),1)=SubPolygonsnew';
            end
        else
            if i==1
                SubstratePolygons={[SubPolygons{i}]};
            else
                SubstratePolygons{i}=cell2mat(SubPolygons)+size1;
            end
        end
    end
end
