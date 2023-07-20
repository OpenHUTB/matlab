function[dx,dy,dz,leftPix,rightPix,upPix,downPix,frontPix,backPix]=...
    calculateGradient(phi,pixIdx)






    import images.activecontour.internal.*;

    imgSize=size(phi);
    is3D=(numel(imgSize)==3);
    if~is3D
        imgSize=[imgSize,1];
    end
    [r,c,z]=ind2sub(imgSize,pixIdx);

    leftPix=phi(getNeighIdx([0,-1,0],imgSize,r,c,z));
    rightPix=phi(getNeighIdx([0,1,0],imgSize,r,c,z));
    upPix=phi(getNeighIdx([-1,0,0],imgSize,r,c,z));
    downPix=phi(getNeighIdx([1,0,0],imgSize,r,c,z));
    frontPix=phi(getNeighIdx([0,0,-1],imgSize,r,c,z));
    backPix=phi(getNeighIdx([0,0,-1],imgSize,r,c,z));

    dx=(leftPix-rightPix)/2;
    dy=(upPix-downPix)/2;
    dz=(frontPix-backPix)/2;