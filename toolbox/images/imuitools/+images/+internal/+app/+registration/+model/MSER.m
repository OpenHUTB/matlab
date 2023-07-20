classdef MSER<images.internal.app.registration.model.FeatureProperty



    properties




    end

    properties(Dependent)
thresholdDelta
regionAreaRange
maxAreaVariation
    end

    methods
        function self=MSER()
            if~images.internal.app.registration.model.validateMethod
                error('cannot create MSER object');
            end
        end

        function[fixedPoints,movingPoints]=detectFeatures(self,fixed,moving)


            params.delta=int32(self.thresholdDelta*255/100);
            params.minArea=int32(self.regionAreaRange(1));
            params.maxArea=int32(self.regionAreaRange(2));
            params.maxVariation=single(self.maxAreaVariation);

            params.minDiversity=single(0.2);
            params.maxEvolution=int32(200);
            params.areaThreshold=1;
            params.minMargin=0.003;
            params.edgeBlurSize=int32(5);


            params.usingROI=false;
            params.ROI=int32([0,0,1,1]);


            fixedu8=im2uint8(fixed);
            assert(size(fixedu8,3)==1);
            movingu8=im2uint8(moving);
            assert(size(movingu8,3)==1);


            fixedRegionsCell=imagesocvExtractMSER(fixedu8,params);
            fixedPoints=createMSERStruct(fixedRegionsCell);
            movingRegionsCell=imagesocvExtractMSER(movingu8,params);
            movingPoints=createMSERStruct(movingRegionsCell);
        end


        function[features,validPoints]=extractFeatures(self,image,regions)




            surfSize=64;


            params.extended=(surfSize==128);
            params.upright=self.upright;



            points.Location=regions.Location;
            points.Scale=computeMSERScale(regions,1.6);
            points.Metric=zeros(size(points.Scale),'single');
            points.SignOfLaplacian=zeros(size(points.Scale),'int8');

            Iu8=im2uint8(image);
            [validPoints,features]=imagesocvExtractSURF(Iu8,points,params);


            validPoints.Orientation(:)=single(2*pi)-validPoints.Orientation;
        end
    end

    methods

        function val=get.thresholdDelta(self)
            val=4-(1-self.featureNumber)*3.2;
        end

        function val=get.regionAreaRange(self)
            val=round([30-(1-self.featureNumber)*20,14000*(2-self.featureNumber)]);
        end

        function val=get.maxAreaVariation(self)
            val=1-0.9*self.featureNumber;
        end

    end

end



function points=createMSERStruct(regionsCell)
    points.PixelList=regionsCell;
    pixelListLen=size(points.PixelList,1);

    points.Location=single(zeros(pixelListLen,2));
    points.Axes=single(zeros(pixelListLen,2));
    points.Orientation=single(zeros(pixelListLen,1));

    for idx=1:pixelListLen
        ellipseStruct=computeEllipseProps(points.PixelList{idx});
        points.Location(idx,:)=single(ellipseStruct.Centroid);
        points.Axes(idx,:)=single(ellipseStruct.Axes);
        points.Orientation(idx,1)=single(ellipseStruct.Orientation);
    end
end





function scale=computeMSERScale(points,minScale)
    if isempty(points.Axes)
        scale=zeros(0,1,'single');
    else
        majorAxes=points.Axes(:,1);
        minorAxes=points.Axes(:,2);

        scale=1/8*sqrt(majorAxes.*minorAxes);
        scale((scale<minScale))=single(minScale);
    end
end





function EllipseStruct=computeEllipseProps(region)









    EllipseStruct.Centroid=mean(region,1);
    EllipseStruct.Axes=[0,0];
    EllipseStruct.Orientation=0;




    xbar=EllipseStruct.Centroid(1);
    ybar=EllipseStruct.Centroid(2);

    x=region(:,1)-xbar;
    y=-(region(:,2)-ybar);



    N=length(x);



    uxx=sum(x.^2)/N+1/12;
    uyy=sum(y.^2)/N+1/12;
    uxy=sum(x.*y)/N;


    common=sqrt((uxx-uyy)^2+4*uxy^2);
    EllipseStruct.Axes(1)=2*sqrt(2)*sqrt(uxx+uyy+common);
    EllipseStruct.Axes(2)=2*sqrt(2)*sqrt(uxx+uyy-common);


    if(uyy>uxx)
        num=uyy-uxx+sqrt((uyy-uxx)^2+4*uxy^2);
        den=2*uxy;
    else
        num=2*uxy;
        den=uxx-uyy+sqrt((uxx-uyy)^2+4*uxy^2);
    end

    if(num==0)&&(den==0)
        EllipseStruct.Orientation=0;
    else
        EllipseStruct.Orientation=atan(num/den);
    end

end