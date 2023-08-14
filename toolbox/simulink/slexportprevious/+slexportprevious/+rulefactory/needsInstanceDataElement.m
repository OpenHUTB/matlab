function b=needsInstanceDataElement(exportVer)








    if~exportVer.isR2021aOrEarlier

        b=true;
    elseif exportVer.isSLX

        b=~exportVer.isR2015aOrEarlier;
    else


        b=false;
    end
