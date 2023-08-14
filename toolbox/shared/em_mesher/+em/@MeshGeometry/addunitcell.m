function addunitcell(obj)



    if isfield(obj.MesherStruct.Geometry,'multiplier')
        mul=obj.MesherStruct.Geometry.multiplier;
    else
        mul=1;
    end

    if strcmpi(class(obj.Element),'helix')||...
        strcmpi(class(obj.Element),'monocone')
        L=2*obj.Element.GroundPlaneRadius*mul;
        W=L;
    elseif strcmpi(class(obj.Element),'pcbStack')
        L=obj.Element.BoardShape.Length*mul;
        W=obj.Element.BoardShape.Width*mul;
    else
        L=obj.Element.GroundPlaneLength*mul;
        W=obj.Element.GroundPlaneWidth*mul;
    end



    H=1.1*max(obj.MesherStruct.Geometry.BorderVertices(:,3))*mul;
    cornersLeftFace=[-L/2,-L/2,-L/2,-L/2;W/2,-W/2,-W/2,W/2;...
    0,0,H,H];
    cornersRightFace=[L/2,L/2,L/2,L/2;-W/2,W/2,W/2,-W/2;...
    0,0,H,H];

    CavityVertices=[cornersLeftFace,cornersRightFace]';
    Polygons_Cavity=[[1,2,3,4];[1,6,7,4];[5,6,7,8];[5,8,3,2]];

    patchinfo.Vertices=CavityVertices;
    patchinfo.Faces=Polygons_Cavity;
    hpatch=patch(patchinfo,'FaceColor',[0.8,0.9,1.0],'FaceAlpha',0.5,...
    'EdgeColor','b','LineStyle','--','LineWidth',1.5);
    set(hpatch,'DisplayName','unit cell');
end