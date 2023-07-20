function pos=filterPositionData(pos,sigma,filterSize)







    if sigma~=0
        h=images.internal.createGaussianKernel(sigma,filterSize);
        pos=padarray(pos,[floor(filterSize/2),0],'replicate','both');
        pos=[conv(pos(:,1),h,'valid'),conv(pos(:,2),h,'valid')];
    end
end