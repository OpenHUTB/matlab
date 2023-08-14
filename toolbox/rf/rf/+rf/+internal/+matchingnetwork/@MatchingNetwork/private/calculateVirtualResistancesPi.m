

function virtualResistances=calculateVirtualResistancesPi(srcZ,loadZ,targetQ)




    srcY=1/srcZ;gSrc=real(srcY);rSrc=1/gSrc;
    loadY=1/loadZ;gLoad=real(loadY);rLoad=1/gLoad;

    Rlarger=max(rSrc,rLoad);
    virtualResistances=[srcZ,Rlarger/(targetQ^2+1),loadZ];

end
