function[Mesh,Parts]=makeAntennaDielectricMesh(obj,antobj,M)





    em.Material.checkRadiatorBounds(M.PGp',M.PRad');
    isNoGp=[];

    if isprop(antobj,'Height')
        h=antobj.Height;
    elseif isprop(antobj,'Spacing')
        h=antobj.Spacing;
        if isequal(antobj.GroundPlaneLength,0)||isequal(antobj.GroundPlaneWidth,0)
            isNoGp=true;
        end
    elseif isa(antobj,'draRectangular')||isa(antobj,'draCylindrical')
        h=max(cumsum(antobj.Substrate.Thickness));

    elseif isprop(antobj,'BoardThickness')
        h=antobj.BoardThickness-M.TopSubThickness;
        if isequal(numel(antobj.MetalLayers),1)&&isequal(M.TopSubThickness,0)
            isNoGp=true;
        end
    end

    if~isa(antobj,'pcbStack')

        em.Material.checkRadiatorConformality(M.PRad',h,1e-12);
    end






    if isprop(antobj,'GroundPlaneLength')
        propVal=isinf(antobj.GroundPlaneLength);
    else
        propVal=[];
    end
    if isempty(propVal)||(~propVal)
        indicator=false;
    else
        indicator=true;
        h=2*h;
    end
    isMetalSideWall=false;











    MultiMesh=makeMultiLayerMesh(obj,h,M,indicator,isMetalSideWall);

    pall=MultiMesh.P;
    t=MultiMesh.t;
    tetsByLayer=MultiMesh.T;
    epsilonRByLayer=MultiMesh.EPSR;
    lossTangentByLayer=MultiMesh.LOSSTANG;
    if~isempty(isNoGp)
        t(:,1:size(MultiMesh.tGP,1))=[];
    end


    pGPnew=M.P';
    tLayer=[M.t';ones(size(M.t,1),1)'];
    pP=M.PRad';
    tP=[M.tRad';3.*ones(size(M.tRad,1),1)'];

    Mesh=em.internal.makeMeshStructure(pall,t,tetsByLayer,epsilonRByLayer,lossTangentByLayer);


    Parts=em.internal.makeMeshPartsStructure('Gnd',[{pGPnew},{tLayer}],...
    'Feed',[{[]},{[]}],...
    'Rad',[{pP},{tP}]);






















































































