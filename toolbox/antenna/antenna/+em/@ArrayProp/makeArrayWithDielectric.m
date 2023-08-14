function makeArrayWithDielectric(obj,tempEpsilonR,sizeEpsilonR)





    tr=obj.TranslationVector;


    if isa(obj.Element(1),'em.BackingStructure')&&...
        isDielectricSubstrate(obj.Element(1).Exciter)&&...
        ~isequal(obj.Element(1).Exciter.Substrate.EpsilonR,1)
        obj.Substrate=copy(obj.Element(1).Exciter.Substrate);


        SubstrateVertices=[];
        SubstratePolygons=[];
        if numel(obj.Element)>1
            offsetIndex=0;
            for i=1:prod(obj.ArraySize)
                [tempSubstrateVertices,tempSubstratePolygons]=...
                makeSubstrateGeometry(obj.Element(i).Exciter);

                trSubstrateVertices=em.internal.translateshape...
                (tempSubstrateVertices',tr(i,:));

                trSubstrateVertices=em.internal.translateshape...
                (trSubstrateVertices,[0,0,obj.Element(i).Spacing]);
                SubstrateVertices=[SubstrateVertices,trSubstrateVertices];%#ok<AGROW>
                SubstratePolygons=[SubstratePolygons...
                ,cellfun(@(x)offsetIndex+x,tempSubstratePolygons,...
                'UniformOutput',false)];%#ok<AGROW>
                offsetIndex=cellfun(@max,SubstratePolygons,'UniformOutput',false);
                offsetIndex=max(max(cell2mat(offsetIndex)));
            end
            SubstrateVertices=SubstrateVertices';
        else
            [tempSubstrateVertices,tempSubstratePolygons]=...
            makeSubstrateGeometry(obj.Element.Exciter);


            trSubstrateVertices=em.internal.translateshape...
            (tempSubstrateVertices',tr(1,:));
            SubstratePolygons=tempSubstratePolygons;
            SubstrateVertices=trSubstrateVertices';
            for i=2:prod(obj.ArraySize)
                translatedSubVertices=em.internal.translateshape...
                (tempSubstrateVertices',tr(i,:));
                SubstrateVertices=[SubstrateVertices;translatedSubVertices'];%#ok<AGROW>
                offsetIndex=cellfun(@max,SubstratePolygons,'UniformOutput',false);
                offsetIndex=max(max(cell2mat(offsetIndex)));
                SubstratePolygons=[SubstratePolygons...
                ,cellfun(@(x)offsetIndex+x,tempSubstratePolygons,...
                'UniformOutput',false)];%#ok<AGROW>
            end


            SubstrateVertices=em.internal.translateshape(SubstrateVertices',...
            [0,0,obj.Element.Spacing]);
            SubstrateVertices=SubstrateVertices';
        end
        SubstrateVertices=orientGeom(obj,SubstrateVertices')';
        saveSubstrateGeometry(obj,SubstrateVertices,SubstratePolygons);
    else

        if~isequal(tempEpsilonR,ones(sizeEpsilonR))
            subDim=calculateSubstrateDimensions(obj);
            if isa(obj.Element,'reflectorCircular')
                obj.Substrate.Radius=subDim(1);
                [SubstrateVertices,SubstratePolygons,...
                SubstrateBoundary,SubstrateBoundaryVertices]=...
                makeSubstrateGeometry(obj);
                saveSubstrateGeometry(obj,SubstrateVertices,...
                SubstratePolygons,SubstrateBoundary,...
                SubstrateBoundaryVertices);
            elseif isa(obj.Element,'draRectangular')||isa(obj.Element,'monopoleTopHat')
                [SubstrateVertices,SubstratePolygons]=makeRectangularDielectricArray(obj);
                saveSubstrateGeometry(obj,SubstrateVertices,...
                SubstratePolygons);
            elseif isa(obj.Element,'draCylindrical')||isa(obj.Element,'helix')...
                ||isa(obj.Element,'dipoleHelix')
                [SubstrateVertices,SubstratePolygons,...
                SubstrateBoundary,SubstrateBoundaryVertices]...
                =makeCylindricalDielectricArray(obj);
                saveSubstrateGeometry(obj,SubstrateVertices,...
                SubstratePolygons,SubstrateBoundary,...
                SubstrateBoundaryVertices);
            else
                obj.Substrate.Length=subDim(1);
                obj.Substrate.Width=subDim(2);
                [SubstrateVertices,SubstratePolygons]=makeSubstrateGeometry(obj);
                saveSubstrateGeometry(obj,SubstrateVertices,SubstratePolygons);
            end
        end
    end

end
