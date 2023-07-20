

function virtualResistances=calculateVirtualResistancesT(srcZ,loadZ,targetQ)




    Rsmaller=min(real(srcZ),real(loadZ));
    virtualResistances=[srcZ,Rsmaller*(targetQ^2+1),loadZ];
end