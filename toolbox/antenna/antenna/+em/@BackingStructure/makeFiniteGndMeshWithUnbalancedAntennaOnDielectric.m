function[Mesh,Parts]=makeFiniteGndMeshWithUnbalancedAntennaOnDielectric(obj,isRemesh,numLayers)




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




    if~all(abs(pexciter(3,:)-obj.Spacing)<=1e-12)
        error(message('antenna:antennaerrors:RadiatorNotConformalOnSubstrate'));
    end

    Mi=em.internal.meshprinting.imprintMesh(pexciter',texciter(1:3,:)',...
    preflector',treflector(1:3,:)');


    translateVector=[obj.FeedLocation(1,1:2),-(-obj.Spacing)*0.5];
    Wfeed=getFeedWidth(obj.Exciter);
    numSections=ceil(obj.Spacing/getMeshEdgeLength(obj));


    [axispt1,axispt2,ang]=getAxisPoints(obj);
    [pFeed,tFeed,feed_pt1,feed_pt2]=getStripMesh(obj,obj.Spacing,Wfeed,...
    numSections,ang,axispt1,axispt2,translateVector);

    searchfeedloc=em.internal.translateshape(obj.Exciter.FeedLocation',...
    [0,0,-(-obj.Spacing)])';
    [portpoint1,portpoint2,~,~]=em.internal.findPortPoints(pexciter',texciter',...
    searchfeedloc);
    if isempty(portpoint1)
        error(message('antenna:antennaerrors:FeedVerticesNotFoundInMesh'));
    end
    if~isequal(portpoint1,feed_pt1)
        feed_pt1=portpoint1;
    end
    if~isequal(portpoint2,feed_pt2)
        feed_pt2=portpoint2;
    end

    if iscolumn(feed_pt1)
        feed_pt1=feed_pt1';
    end
    if iscolumn(feed_pt2)
        feed_pt2=feed_pt2';
    end



    Mi.FeedVertex1=feed_pt1;
    Mi.FeedVertex2=feed_pt2;
    Mi.NumLayers=numLayers;



    [Mesh,~]=makeDielectricMesh(obj.Substrate,obj,Mi);



    Parts=em.internal.makeMeshPartsStructure('Gnd',[{Mi.P'},{Mi.t'}],...
    'Feed',[{pFeed},{tFeed}],...
    'Rad',[{pexciter},{texciter}]);


    p=orientGeom(obj,Mesh.Points);


    Mesh.Points=p;

end
