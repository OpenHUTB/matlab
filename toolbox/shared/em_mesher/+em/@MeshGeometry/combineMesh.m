function Meshfinal=combineMesh(obj,m,pexciter,texciter)




    mE=obj.Exciter.MesherStruct.Mesh;

    Meshfinal.Points=[m.Points,pexciter];
    x=max(m.Triangles(1:3,:),[],"all");
    texciter2=texciter(1:3,:)+x;
    texciter2(4,:)=texciter(4,:);
    Meshfinal.Triangles=[m.Triangles,texciter2];
    Meshfinal.Tetrahedra=[m.Tetrahedra,mE.T];
    Meshfinal.EpsilonR=[m.EpsilonR,mE.Eps_r];
    Meshfinal.LossTangent=[m.LossTangent,mE.tan_delta];

    if~isDielectricSubstrate(obj)&&isDielectricSubstrate(obj.Exciter)
        Meshfinal.Tetrahedra=Meshfinal.Tetrahedra+x;
    end
end
