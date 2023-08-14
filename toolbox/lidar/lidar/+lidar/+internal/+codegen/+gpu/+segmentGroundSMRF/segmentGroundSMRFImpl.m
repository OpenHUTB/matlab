function[groundPts]=segmentGroundSMRFImpl(locations,maxRadius,gridRes,...
    slopeThresh,eleThres,eleScale)





























%#codegen


    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');



    isOrganized=~ismatrix(locations);



    if~isOrganized
        groundPts=false(size(locations,1),1);
    else
        groundPts=false(size(locations,1:2));
    end





    validIndicesTemp=vision.internal.codegen.gpu.PointCloudImpl.extractValidPoints(locations);
    [validLocations,~,~,~,~]=...
    vision.internal.codegen.gpu.PointCloudImpl.subsetImpl(locations,[],...
    [],[],[],validIndicesTemp,isOrganized,'selected');


    linearIndices=1:numel(validIndicesTemp);
    validIndices=vision.internal.codegen.gpu.pcfitplane.findGpuImpl(linearIndices',...
    validIndicesTemp);


    if~isempty(validLocations)



        tmpMat=validLocations(:,1);
        xLims=double(gpucoder.reduce(tmpMat,{@computeMin,@computeMax}));
        tmpMat=validLocations(:,2);
        yLims=double(gpucoder.reduce(tmpMat,{@computeMin,@computeMax}));


        xGridLims=[ceil(xLims(1)/gridRes)*gridRes,floor(xLims(2)/gridRes)*gridRes];
        yGridLims=[ceil(yLims(1)/gridRes)*gridRes,floor(yLims(2)/gridRes)*gridRes];

        xGridLims=cast(xGridLims,'like',locations);
        yGridLims=cast(yGridLims,'like',locations);



        if(yGridLims(2)>=yGridLims(1))
            rows=floor((yGridLims(2)-yGridLims(1))/gridRes)+1;
        else
            rows=cast(1,'like',yGridLims);
        end
        if(xGridLims(2)>=xGridLims(1))
            cols=floor((xGridLims(2)-xGridLims(1))/gridRes)+1;
        else
            cols=cast(1,'like',xGridLims);
        end


        [surface,emptyGrids,numEmptyGrids]=lidar.internal.codegen.gpu.segmentGroundSMRF.createDEMImpl(...
        int32(rows),int32(cols),validLocations,xGridLims(1),yGridLims(1),gridRes);


        if numEmptyGrids>0


            if rows>=3&&cols>=3
                surface=regionfill(surface,emptyGrids);
            else




                surface=lidar.internal.codegen.gpu.segmentGroundSMRF.fillmissing(surface,2);
                surface=lidar.internal.codegen.gpu.segmentGroundSMRF.fillmissing(surface,1);
            end
        end


        threshold=5*gridRes;



        nHood=logical([0,1,0;1,1,1;0,1,0]);




        padValueDilate=-coder.internal.inf(1,class(surface));
        padValueErode=coder.internal.inf(1,class(surface));


        imPadErode=lidar.internal.codegen.gpu.segmentGroundSMRF.padArray(-surface,[1,1],padValueErode);


        opSurErode=gpucoder.stencilKernel(@doMaskErode,imPadErode,size(nHood),'valid',...
        nHood,padValueErode);


        imPadDilate=lidar.internal.codegen.gpu.segmentGroundSMRF.padArray(opSurErode,[1,1],padValueDilate);


        opSurDilate=gpucoder.stencilKernel(@doMaskDilate,imPadDilate,size(nHood),...
        'valid',nHood,padValueDilate);


        outlierGrids=coder.nullcopy(zeros(size(surface),'logical'));
        coder.gpu.kernel;
        for rIter=1:rows
            coder.gpu.kernel;
            for cIter=1:cols
                outlierGrids(rIter,cIter)=(surface(rIter,cIter)+opSurDilate(rIter,cIter))...
                <-threshold;
            end
        end


        objectGrids=lidar.internal.codegen.gpu.segmentGroundSMRF.openSurfaceMorph(surface,maxRadius,gridRes,slopeThresh,...
        padValueErode,padValueDilate,rows,cols);



        nonGroundGrids=coder.nullcopy(zeros(size(surface),'logical'));
        estGroundSurf=coder.nullcopy(zeros(rows,cols,'like',locations));
        nonGroundCount=uint32(0);
        coder.gpu.kernel;
        for rIter=1:rows
            coder.gpu.kernel;
            for cIter=1:cols
                nonGroundGrids(rIter,cIter)=emptyGrids(rIter,cIter)|...
                outlierGrids(rIter,cIter)|objectGrids(rIter,cIter);
                nonGroundCount=gpucoder.atomicAdd(nonGroundCount,uint32(nonGroundGrids(rIter,cIter)));
                estGroundSurf(rIter,cIter)=surface(rIter,cIter);
            end
        end


        coder.gpu.kernel;
        for rIter=1:rows
            coder.gpu.kernel;
            for cIter=1:cols
                if nonGroundGrids(rIter,cIter)
                    estGroundSurf(rIter,cIter)=coder.internal.nan;
                end
            end
        end



        if nonGroundCount>0
            if rows>=3&&cols>=3
                estGroundSurf=regionfill(estGroundSurf,nonGroundGrids);
            else




                estGroundSurf=lidar.internal.codegen.gpu.segmentGroundSMRF.fillmissing(estGroundSurf,2);
                estGroundSurf=lidar.internal.codegen.gpu.segmentGroundSMRF.fillmissing(estGroundSurf,1);
            end
        end




        if isvector(estGroundSurf)

            surfaceSlope=lidar.internal.codegen.gpu.segmentGroundSMRF.gradient(estGroundSurf/gridRes);



            if numel(estGroundSurf)==1
                estElevation=coder.nullcopy(zeros(size(validLocations,1),1,'like',locations));
                estSlope=coder.nullcopy(zeros(size(validLocations,1),1,'like',locations));



                for iter=1:numel(validIndices)
                    estElevation(iter)=estGroundSurf;
                    estSlope(iter)=surfaceSlope;
                end


            elseif size(estGroundSurf,1)==1
                c=(validLocations(:,1)-xGridLims(1)+gridRes)/gridRes;



                estElevation=cast(interp1(estGroundSurf',c,'spline'),class(estGroundSurf));
                estSlope=cast(interp1(surfaceSlope',c,'spline'),class(estGroundSurf));


            else
                r=(validLocations(:,2)-yGridLims(1)+gridRes)/gridRes;



                estElevation=cast(interp1(estGroundSurf,r,'spline'),class(estGroundSurf));
                estSlope=cast(interp1(surfaceSlope,r,'spline'),class(estGroundSurf));
            end

        else

            [gradX,gradY]=lidar.internal.codegen.gpu.segmentGroundSMRF.gradient(estGroundSurf/gridRes);


            surfaceSlope=sqrt(gradX.^2+gradY.^2);



            r=coder.nullcopy(zeros(size(validIndices)));
            c=coder.nullcopy(zeros(size(validIndices)));

            coder.gpu.kernel;
            for iter=1:numel(validIndices)
                r(iter)=(validLocations(iter,2)-yGridLims(1)+gridRes)/gridRes;
                c(iter)=(validLocations(iter,1)-xGridLims(1)+gridRes)/gridRes;
            end






            estElevation=interp2(estGroundSurf,c,r,'cubic');
            estSlope=interp2(surfaceSlope,c,r,'cubic');
        end




        coder.gpu.kernel;
        for iter=1:numel(validIndices)
            allowableThresh=eleThres+(eleScale*estSlope(iter));
            grndIdx=abs(estElevation(iter)-validLocations(iter,3))<=allowableThresh;
            groundPts(validIndices(iter))=grndIdx;
        end

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


function out=computeMin(a,b)
    out=min(a,b);
end


function out=computeMax(a,b)
    out=max(a,b);
end
