
function[tr,FeedPoints,fh]=createFeed(trobj,triindx,feedpoint,fh,fw,snapToMetal)






    [rotatedpoints,rotatevect,theta]=em.internal.stl.rotateObject(trobj,triindx,feedpoint);
    val=size(rotatedpoints,1);


    [tr1,idxfeedint]=em.internal.stl.createHole(triangulation(trobj.ConnectivityList,rotatedpoints)...
    ,triindx,fw,rotatedpoints,[0,0,0]);




    if(idxfeedint==-1)


        trerror=triangulation(trobj.ConnectivityList(tr1,:),rotatedpoints);
        fe=freeBoundary(trerror);
        ptszeroz=[rotatedpoints(:,1),rotatedpoints(:,2),zeros(size(rotatedpoints,1),1)];
        [D,Idx]=em.internal.meshprinting.inter2_point_seg(ptszeroz,fe,[0,0,0]);
        dist=sqrt(min(sum(ptszeroz(unique(fe),:).^2,2)));
        valFeed=min(D);
        error(['Cannot extrude at [',num2str(feedpoint),'] with height ',num2str(fh),' and width ',num2str(fw)]);
    end

    rotatedpoints=tr1.Points;cl=tr1.ConnectivityList;
    idxfeedint=[];



    if snapToMetal

        [~,d]=dsearchn(max(rotatedpoints),min(rotatedpoints));
        cpt=[0,0,-1.2*d;0,0,1.2*d];

        tr1=triangulation(tr1.ConnectivityList,tr1.Points);
        rtobj=matlabshared.internal.StaticSceneRayTracer(tr1);
        [directionf,distancef]=matlabshared.internal.segmentToRay(cpt(1,:),cpt(2,:));
        [pt,triangleN,~]=allIntersections(rtobj,cpt(1,:),directionf,distancef);
        pt=pt{1};
        triangleN=triangleN{1};
        if~isempty(pt)



            hvect=pt(:,3);
            if fh<0
                hvect=hvect.*(hvect<0);
            end
            [~,idx]=min(abs(hvect-fh));

            if~isempty(idx)






                pt=pt(idx,:);
                triangleN=triangleN(idx);


                [tr2,idxfeedint]=em.internal.stl.createHole(tr1,triangleN,fw,rotatedpoints,pt);

                if idxfeedint==-1

                    idxfeedint=[];
                    error(['Couldnot detect any layer at the point ',num2str(feedpoint),' for intersection.']);

                    rotatedpoints=tr1.Points;cl=tr1.ConnectivityList;
                else
                    rotatedpoints=tr2.Points;cl=tr2.ConnectivityList;
                end
            else
                error(['Couldnot detect any layer at the point ',num2str(feedpoint),' for intersection.']);

            end
        else
            error(['Couldnot detect any layer at the point ',num2str(feedpoint),' for intersection.']);
        end
    end
    feedpoints=[fw/2,0,0;0,-fw/2,0;-fw/2,0,0;0,fw/2,0];
    if fh==0

        trifeedcol=[1,2,3;3,4,1]+val;
        cl=[cl;trifeedcol];
    elseif isempty(idxfeedint)

        for i=1:10
            tmpht=fh*i/10;
            feedpointht=[feedpoints(:,1),feedpoints(:,2)];
            feedpointht(:,3)=tmpht;
            val2=size(rotatedpoints,1);
            trifeedcol=[val2+1,val+1,val+2;val2+1,val2+2,val+2;...
            val2+2,val+2,val+3;val2+2,val2+3,val+3;...
            val2+3,val+3,val+4;val2+3,val2+4,val+4;...
            val2+4,val+4,val+1;val2+4,val2+1,val+1;];
            rotatedpoints=[rotatedpoints;feedpointht];
            cl=[cl;trifeedcol];
            val=val2;
            if i==10
                cl=[cl;[1,2,3;3,4,1]+val2];
            end
        end
    else

        ptsmat=zeros(24,3);
        finalval=idxfeedint;



        fact=2:9;
        pts1=(1-fact'/10)*rotatedpoints(val+1,:)+(fact'/10)*rotatedpoints(finalval+1,:);
        pts2=(1-fact'/10)*rotatedpoints(val+2,:)+(fact'/10)*rotatedpoints(finalval+2,:);
        pts3=(1-fact'/10)*rotatedpoints(val+3,:)+(fact'/10)*rotatedpoints(finalval+3,:);
        pts4=(1-fact'/10)*rotatedpoints(val+4,:)+(fact'/10)*rotatedpoints(finalval+4,:);

        for i=1:9
            if i==9
                val2=finalval;
            else
                val2=size(rotatedpoints,1);
                feedpointht=[pts1(i,:);pts2(i,:);pts3(i,:);pts4(i,:);];
                rotatedpoints=[rotatedpoints;feedpointht];
            end


            trifeedcol=[val2+1,val+1,val+2;val2+1,val2+2,val+2;...
            val2+2,val+2,val+3;val2+2,val2+3,val+3;...
            val2+3,val+3,val+4;val2+3,val2+4,val+4;...
            val2+4,val+4,val+1;val2+4,val2+1,val+1;];

            cl=[cl;trifeedcol];
            val=val2;
        end





    end


    pts=em.internal.rotateshape(rotatedpoints',[0,0,0],rotatevect,-theta);
    pts=pts'+feedpoint;


    FeedPoints=(feedpoints+circshift(feedpoints,1))/2;
    FeedPoints(:,3)=0;
    FeedPoints=em.internal.rotateshape(FeedPoints',[0,0,0],rotatevect,-theta);
    FeedPoints=FeedPoints'+feedpoint;
    tr=triangulation(cl,pts);
end

