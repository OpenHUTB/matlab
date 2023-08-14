function val=checkTriangle(trobj,t)




    faceNorm=faceNormal(trobj,t(:));
    costheta=faceNorm(:,3)./sqrt(sum(faceNorm.^2,2));
    val=abs(costheta)>0.1;




end