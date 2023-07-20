function[Mesh,Parts]=makeArrayDielectricMesh(obj,arrobj,M)


    em.Material.checkRadiatorBounds(M.PGp',M.PRad');
    isNoGp=false;

    if isprop(arrobj.Element(1),'Height')
        h=arrobj.Element.Height;
    elseif isprop(arrobj.Element(1),'Spacing')
        h=arrobj.Element.Spacing;
        if isequal(arrobj.GroundPlaneLength,0)||isequal(arrobj.GroundPlaneWidth,0)
            isNoGp=true;
        end
    end


    em.Material.checkRadiatorConformality(M.PRad',h,1e-12);





    propVal=getInfGPState(arrobj.Element(1));
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








    pGPnew=M.P';
    tLayer=[M.t';ones(size(M.t,1),1)'];
    pP=M.PRad';
    tP=[M.tRad';3.*ones(size(M.tRad,1),1)'];

    Mesh=em.internal.makeMeshStructure(pall,t,tetsByLayer,epsilonRByLayer,lossTangentByLayer);


    Parts=em.internal.makeMeshPartsStructure('Gnd',[{pGPnew},{tLayer}],...
    'Feed',[{[]},{[]}],...
    'Rad',[{pP},{tP}]);
