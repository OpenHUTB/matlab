function pos=find_verify_position(dialog,axesExtent,figBuffer,verifyWidth,isVerificationVisible)




    if isVerificationVisible
        mult=[1,0,1,0;0,1,0,0;0,0,0,0;0,0,0,1];
        pos=(mult*axesExtent(:))'+[1,1,0,1]*figBuffer+...
        [0,0,1,0]*verifyWidth;
        points2pixels=1./pixels2points(dialog,[1,1]);
        pos=pos.*[points2pixels,points2pixels];
    else
        pos=[];
    end