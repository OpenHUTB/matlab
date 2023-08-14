function hfill=view_antenna_mesh(p,t,antennaColor)

    patchinfo.Vertices=p.';
    patchinfo.Faces=t(1:3,:).';
    hfill=patch(patchinfo,'FaceColor',antennaColor,'tag','metal');







end