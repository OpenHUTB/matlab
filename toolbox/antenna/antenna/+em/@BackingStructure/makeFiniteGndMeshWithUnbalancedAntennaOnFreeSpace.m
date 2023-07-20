function[Mesh,Parts]=makeFiniteGndMeshWithUnbalancedAntennaOnFreeSpace(obj,isRemesh)




    if isRemesh


        createGeometry(obj);
        meshExciter(obj);
        [pexciter,texciter]=getExciterMesh(obj);
        [preflector,treflector]=getReflectorMesh(obj,true);

    else

        [pexciter,texciter]=getExciterMesh(obj);
        [preflector,treflector]=getPartMesh(obj,'Gnd');
        preflector=cell2mat(preflector);
        treflector=cell2mat(treflector);

    end


    Wfeed=getFeedWidth(obj.Exciter);
    numSections=ceil(obj.Spacing/Wfeed);
    translateVector=[obj.FeedLocation(1,1:2),-(-obj.Spacing)*0.5];



    [axispt1,axispt2,ang]=getAxisPoints(obj);
    [pFeed,tFeed,~,~]=getStripMesh(obj,obj.Spacing,Wfeed,...
    numSections,ang,axispt1,axispt2,translateVector);

    searchfeedloc=em.internal.translateshape(obj.Exciter.FeedLocation',[0,0,-(-obj.Spacing)])';
    [portpoint1,portpoint2,t1,t2]=em.internal.findPortPoints(pexciter',texciter',searchfeedloc);
    if isempty(portpoint1)
        error(message('antenna:antennaerrors:FeedVerticesNotFoundInMesh'));
    end
    trivertid=setdiff(union(t1,t2),intersect(t1,t2));
    pfeedtri=[portpoint1;portpoint2;pexciter(:,trivertid)'];
    tfeedtri=[1,2,3;1,2,4];

    if isRemesh

        Mi=em.internal.meshprinting.imprintMesh(pfeedtri,tfeedtri,preflector',treflector(1:3,:)');
        Mi.FeedVertex1=[];
        Mi.FeedVertex2=[];
        pGP=Mi.P';
        tGP=Mi.t';
    else
        pGP=preflector;tGP=treflector(1:3,:);
    end

    tGP(4,:)=1;
    tFeed(4,:)=2;
    texciter(4,:)=3;
    if isa(obj,'reflectorCylindrical')
        L=obj.GroundPlaneLength;
        d=obj.Depth;
        R=((L/2)^2+d^2)/(2*d);
        pGP(3,:)=-1*sqrt(R^2-(pGP(1,:).^2));
        minz=min(min(pGP(3,:)));
        pGP=em.internal.translateshape(pGP,[0,0,-1*minz]);







        pGP(3,1)=min(pFeed(3,:));
        pGP(3,2)=min(pFeed(3,:));

        if obj.FeedLocation(3)~=0



            zp=obj.PortPoints(3,1);
            translateVector=[obj.FeedLocation(1,1:2),(obj.Spacing+zp)*0.5];
            [pFeed,tFeed,~,~]=getStripMesh(obj,(obj.Spacing-zp),...
            Wfeed,numSections,ang,axispt1,axispt2,translateVector);



...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
            pGP(3,1)=min(pFeed(3,:));
            pGP(3,2)=min(pFeed(3,:));
            tFeed(4,:)=2;
        end
    end

    if(isa(obj.Exciter,'spiralArchimedean')&&obj.Exciter.NumArms==2)||...
        isa(obj.Exciter,'spiralRectangular')
        if isa(obj.Exciter,'spiralArchimedean')

            tangle=sum(obj.Exciter.Tilt(1:end))-45;
        else

            tangle=sum(obj.Exciter.Tilt(1:end))-90;
        end







        obj.MesherStruct.Mesh.PartMesh.GndConnectionDomain{1}=em.internal.rotateshape(...
        obj.MesherStruct.Mesh.PartMesh.GndConnectionDomain{1},...
        [obj.Exciter.FeedLocation(1,1),obj.Exciter.FeedLocation(1,2),0],...
        [obj.Exciter.FeedLocation(1,1),obj.Exciter.FeedLocation(1,2),1],tangle);
        obj.MesherStruct.Mesh.PartMesh.GndConnectionDomain{2}=em.internal.rotateshape(...
        obj.MesherStruct.Mesh.PartMesh.GndConnectionDomain{2},...
        [obj.Exciter.FeedLocation(1,1),obj.Exciter.FeedLocation(1,2),0],...
        [obj.Exciter.FeedLocation(1,1),obj.Exciter.FeedLocation(1,2),1],tangle);

    end


    [Mesh,Parts]=joinAndVerifyFiniteGndMesh(obj,pGP,tGP,pFeed,tFeed,pexciter,texciter);


    mesherType=getMesherType(obj);
    if mesherType
        Hmax=getMeshEdgeLength(obj);
        Hmin=getMinContourEdgeLength(obj);
        if isempty(Hmin)&&~isa(obj.Exciter,'em.ConeAntenna')
            Hmin=0.75*Hmax;
        end


        mR=remesh(obj,Mesh,Hmin,Hmax);
        Mesh.Points=mR.Points;
        Mesh.Triangles=mR.Triangles;
    end
