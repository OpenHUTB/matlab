function[Mesh,Parts]=makeInfiniteGndMeshWithUnbalancedAntennaOnFreeSpace(obj,isRemesh)





    if isRemesh


        createGeometry(obj);



        meshExciter(obj);
    end


    [pexciter,texciter]=getExciterMesh(obj);


    Wfeed=getFeedWidth(obj.Exciter);
    numSections=ceil(obj.Spacing/Wfeed);
    translateVector=[obj.FeedLocation(1,1:2),-(-obj.Spacing)*0.5];



    [axispt1,axispt2,ang]=getAxisPoints(obj);
    [pFeed,tFeed,~,~]=getStripMesh(obj,obj.Spacing,Wfeed,...
    numSections,ang,axispt1,axispt2,translateVector);


    texciter(4,:)=3;
    tFeed(4,:)=2;

    [Mesh,Parts]=joinAndVerifyInfiniteGndMesh(obj,pFeed,tFeed,pexciter,texciter);


    Hmin=getMinContourEdgeLength(obj.Exciter);
    setMeshMinContourEdgeLength(obj,Hmin);
end
