function corners=harrismineigen(method,I,varargin)










































    stack=dbstack;

    if~(startsWith(stack(2).file,'Harris.')||...
        startsWith(stack(2).file,'MinEigen.')||...
        startsWith(stack(2).file,'register_esfrChart.')||...
        startsWith(stack(2).file,'detectSlantedEdgeROIs.')||...
        startsWith(stack(2).file,'tesfrChart.'))
        error('cannot run harris or mineigen feature detection.');
    end


    [params,filterSize]=parseInputs(I,varargin{:});


    I=im2single(I);


    filter2D=createFilter(filterSize);

    metricMatrix=cornerMetric(method,I,filter2D);

    locations=findPeaks(metricMatrix,params.MinQuality);
    locations=subPixelLocation(metricMatrix,locations);


    metricValues=computeMetric(metricMatrix,locations);


    corners.Location=locations;
    corners.Metric=metricValues;




    function values=computeMetric(metric,loc)
        x=loc(:,1);
        y=loc(:,2);
        x1=floor(x);
        y1=floor(y);
        x2=x1+1;
        y2=y1+1;

        sz=size(metric);
        values=metric(sub2ind(sz,y1,x1)).*(x2-x).*(y2-y)...
        +metric(sub2ind(sz,y1,x2)).*(x-x1).*(y2-y)...
        +metric(sub2ind(sz,y2,x1)).*(x2-x).*(y-y1)...
        +metric(sub2ind(sz,y2,x2)).*(x-x1).*(y-y1);



        function metric=cornerMetric(method,I,filter2D)

            A=imfilter(I,[-1,0,1],'replicate','same','conv');
            B=imfilter(I,[-1,0,1]','replicate','same','conv');


            A=A(2:end-1,2:end-1);
            B=B(2:end-1,2:end-1);


            C=A.*B;
            A=A.*A;
            B=B.*B;


            A=imfilter(A,filter2D,'replicate','full','conv');
            B=imfilter(B,filter2D,'replicate','full','conv');
            C=imfilter(C,filter2D,'replicate','full','conv');


            removed=max(0,(size(filter2D,1)-1)/2-1);
            A=A(removed+1:end-removed,removed+1:end-removed);
            B=B(removed+1:end-removed,removed+1:end-removed);
            C=C(removed+1:end-removed,removed+1:end-removed);

            if strcmpi(method,'Harris')

                k=0.04;
                metric=(A.*B)-(C.^2)-k*(A+B).^2;
            else
                metric=((A+B)-sqrt((A-B).^2+4*C.^2))/2;
            end



            function loc=subPixelLocation(metric,loc)
                loc=subPixelLocationImpl(metric,reshape(loc',2,1,[]));
                loc=squeeze(loc)';




                function subPixelLoc=subPixelLocationImpl(metric,loc)

                    nLocs=size(loc,3);
                    patch=zeros([3,3,nLocs],'like',metric);
                    x=loc(1,1,:);
                    y=loc(2,1,:);
                    xm1=x-1;
                    xp1=x+1;
                    ym1=y-1;
                    yp1=y+1;
                    xsubs=[xm1,x,xp1;
                    xm1,x,xp1;
                    xm1,x,xp1];
                    ysubs=[ym1,ym1,ym1;
                    y,y,y;
                    yp1,yp1,yp1];
                    linind=sub2ind(size(metric),ysubs(:),xsubs(:));
                    patch(:)=metric(linind);

                    dx2=(patch(1,1,:)-2*patch(1,2,:)+patch(1,3,:)...
                    +2*patch(2,1,:)-4*patch(2,2,:)+2*patch(2,3,:)...
                    +patch(3,1,:)-2*patch(3,2,:)+patch(3,3,:))/8;

                    dy2=((patch(1,1,:)+2*patch(1,2,:)+patch(1,3,:))...
                    -2*(patch(2,1,:)+2*patch(2,2,:)+patch(2,3,:))...
                    +(patch(3,1,:)+2*patch(3,2,:)+patch(3,3,:)))/8;

                    dxy=(+patch(1,1,:)-patch(1,3,:)...
                    -patch(3,1,:)+patch(3,3,:))/4;

                    dx=(-patch(1,1,:)-2*patch(2,1,:)-patch(3,1,:)...
                    +patch(1,3,:)+2*patch(2,3,:)+patch(3,3,:))/8;

                    dy=(-patch(1,1,:)-2*patch(1,2,:)-patch(1,3,:)...
                    +patch(3,1,:)+2*patch(3,2,:)+patch(3,3,:))/8;

                    detinv=1./(dx2.*dy2-0.25.*dxy.*dxy);


                    x=-0.5*(dy2.*dx-0.5*dxy.*dy).*detinv;
                    y=-0.5*(dx2.*dy-0.5*dxy.*dx).*detinv;



                    isValid=(abs(x)<1)&(abs(y)<1);
                    x(~isValid)=0;
                    y(~isValid)=0;
                    subPixelLoc=[x;y]+loc;



                    function f=createFilter(filterSize)
                        sigma=filterSize/3;
                        f=fspecial('gaussian',filterSize,sigma);


                        function[params,filterSize]=parseInputs(I,varargin)


                            imageSize=size(I);


                            parser=inputParser;
                            defaults=getParameterDefaults(imageSize);


                            parser.addParameter('MinQuality',defaults.MinQuality);
                            parser.addParameter('FilterSize',defaults.FilterSize);
                            parser.addParameter('ROI',defaults.ROI);
                            parser.parse(varargin{:});

                            params=parser.Results;
                            filterSize=params.FilterSize;


                            validateattributes(params.MinQuality,{'double','single'},...
                            {'nonempty','nonnan','nonsparse','real','scalar','>=',0,'<=',1},...
                            'harrismineigen','MinQuality');

                            checkFilterSize(params.FilterSize,imageSize);


                            function[defaults,filterSize]=getParameterDefaults(imgSize)
                                filterSize=5;
                                defaults=struct('MinQuality',single(0.01),...
                                'FilterSize',filterSize,...
                                'ROI',int32([1,1,imgSize([2,1])]));


                                function tf=checkFilterSize(x,imageSize)

                                    validateattributes(x,{'numeric'},...
                                    {'nonempty','nonnan','nonsparse','real','scalar','odd',...
                                    '>=',3},mfilename,'FilterSize');


                                    maxSize=min(imageSize);
                                    assert(x<maxSize);
                                    tf=true;


                                    function loc=findPeaks(metric,quality)



                                        maxMetric=max(metric(:));
                                        if maxMetric<=eps(0)
                                            loc=zeros(0,2,'single');
                                        else

                                            bw=imregionalmax(metric,8);

                                            threshold=quality*maxMetric;
                                            bw(metric<threshold)=0;
                                            bw=bwmorph(bw,'shrink',Inf);


                                            bw(1,:)=0;
                                            bw(end,:)=0;
                                            bw(:,1)=0;
                                            bw(:,end)=0;


                                            idx=find(bw);
                                            loc=zeros([length(idx),2],'like',metric);
                                            [loc(:,2),loc(:,1)]=ind2sub(size(metric),idx);
                                        end
