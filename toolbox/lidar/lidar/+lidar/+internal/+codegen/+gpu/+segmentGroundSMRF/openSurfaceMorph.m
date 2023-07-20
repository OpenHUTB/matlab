function objectGrids=openSurfaceMorph(surface,maxRadius,gridRes,slopeThresh,...
    padValueErode,padValueDilate,rows,cols)




































%#codegen


    coder.inline('never');
    coder.allowpcode('plain');




    minDim=min(size(surface));
    numIterations=min(maxRadius,minDim+1);



    coder.internal.prefer_const(numIterations);


    strels=lidar.internal.codegen.gpu.segmentGroundSMRF.computeStrels(numIterations);


    objectGrids=zeros(size(surface),'logical');


    curSurface=surface;



    for iter=1:numIterations


        threshold=slopeThresh*(iter*gridRes);


        nHood=strels{iter};


        sizePadArray=[(size(nHood,1)-1)/2,(size(nHood,2)-1)/2];


        imPadErode=lidar.internal.codegen.gpu.segmentGroundSMRF.padArray(curSurface,sizePadArray,padValueErode);


        opSurErode=gpucoder.stencilKernel(@doMaskErode,imPadErode,size(nHood(:,:,1)),'valid',...
        nHood(:,:,1),padValueErode);



        imPadDilate=lidar.internal.codegen.gpu.segmentGroundSMRF.padArray(opSurErode,sizePadArray,padValueDilate);


        opSurDilate=gpucoder.stencilKernel(@doMaskDilate,imPadDilate,size(nHood(:,:,1)),...
        'valid',nHood(:,:,1),padValueDilate);



        coder.gpu.kernel;
        for rIter=1:rows
            coder.gpu.kernel;
            for cIter=1:cols
                objectGrids(rIter,cIter)=objectGrids(rIter,cIter)|(...
                curSurface(rIter,cIter)-opSurDilate(rIter,cIter)>threshold);
            end
        end


        curSurface=opSurDilate;
    end

end



function out=doMaskDilate(a,b,padval)
    coder.inline('always');
    coder.gpu.constantMemory(b);
    [h,w]=size(b);
    maxVal=padval;
    for n=1:w
        for m=1:h
            if(b(m,n)>0)
                out=a(m,n)*b(m,n);

                out=cast(out,class(a));
                if(out>maxVal)
                    maxVal=out;
                end
            end
        end
    end
    out=maxVal;
end



function out=doMaskErode(a,b,padval)
    coder.inline('always');
    coder.gpu.constantMemory(b);
    [h,w]=size(b);
    minVal=padval;
    for n=1:w
        for m=1:h
            if(b(m,n)>0)
                out=a(m,n)*b(m,n);

                out=cast(out,class(a));
                if(out<minVal)
                    minVal=out;
                end
            end
        end
    end
    out=minVal;
end
