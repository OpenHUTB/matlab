function Z=correctZData(Z)























































    Z(Z<0)=-((Z(Z<0)+32767)+1);


















    negatives=(-32767<Z(:)&Z(:)<0);
    if any(negatives)&&all(Z(negatives)<-12000)


        warning(message('shared_terrain:dted:TwosComplementDetected'))

        Z(Z<0)=(-Z(Z<0)-1)-32767;
    end


    Z(Z==-32767)=NaN;
