function[curvature,varargout]=calculateCurvature(phi,pixIdx)






    import images.activecontour.internal.*;

    nout=max(nargout,1)-1;
    if nout>1
        error(message('images:validate:tooManyInputs',mfilename))
    end

    imgSize=size(phi);
    is3D=(numel(imgSize)==3);
    if~is3D
        imgSize=[imgSize,1];
    end
    [r,c,z]=ind2sub(imgSize,pixIdx);


    pix=phi(pixIdx);


    [dx,dy,dz,leftPix,rightPix,upPix,downPix,frontPix,backPix]=...
    calculateGradient(phi,pixIdx);


    ulPix=phi(getNeighIdx([-1,-1,0],imgSize,r,c,z));
    urPix=phi(getNeighIdx([-1,1,0],imgSize,r,c,z));
    dlPix=phi(getNeighIdx([1,-1,0],imgSize,r,c,z));
    drPix=phi(getNeighIdx([1,1,0],imgSize,r,c,z));
    lfPix=phi(getNeighIdx([0,-1,-1],imgSize,r,c,z));
    lbPix=phi(getNeighIdx([0,-1,1],imgSize,r,c,z));
    rfPix=phi(getNeighIdx([0,1,-1],imgSize,r,c,z));
    rbPix=phi(getNeighIdx([0,1,1],imgSize,r,c,z));
    ufPix=phi(getNeighIdx([-1,0,-1],imgSize,r,c,z));
    ubPix=phi(getNeighIdx([-1,0,1],imgSize,r,c,z));
    dfPix=phi(getNeighIdx([1,0,-1],imgSize,r,c,z));
    dbPix=phi(getNeighIdx([1,0,1],imgSize,r,c,z));


    dxx=leftPix-2*pix+rightPix;
    dyy=upPix-2*pix+downPix;
    dzz=frontPix-2*pix+backPix;
    dxy=(ulPix+drPix-urPix-dlPix)/4;
    dxz=(lfPix+rbPix-rfPix-lbPix)/4;
    dyz=(ufPix+dbPix-dfPix-ubPix)/4;


    curvature=(dxx.*(dy.^2+dz.^2)+dyy.*(dx.^2+dz.^2)+...
    dzz.*(dx.^2+dy.^2)-2*dx.*dy.*dxy-2*dx.*dz.*dxz-2*dy.*dz.*dyz)./...
    (dx.^2+dy.^2+dz.^2+eps);

    if nout==1
        if is3D
            varargout{1}=[dx,dy,dz];
        else
            varargout{1}=[dx,dy];
        end
    end
end