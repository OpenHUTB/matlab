function[pGP,tGP]=makeGroundPlaneMesh(obj,edgeLength,growthRate)




    propGroups=getPropertyGroups(obj.Element);
    propertyNames=propGroups.PropertyList;
    if any(strcmpi('GroundPlaneLength',fields(propertyNames)))||...
        isa(obj.Element,'helix')||isa(obj.Element,'monocone')
        groundPlaneShape='Rectangle';
    else
        groundPlaneShape='Circle';
    end





    if isa(obj.Element,'monopoleCylindrical')
        gp1=antenna.Rectangle('Length',obj.GroundPlaneLength,'Width',obj.GroundPlaneWidth);
        if isscalar(obj.Element)
            npoints=size(obj.Element.MesherStruct.Mesh.HardEdges,1);

            for i=1:size(obj.FeedLocation,1)

                hole=antenna.Circle('Radius',obj.Element.Radius,'NumPoints',npoints,...
                'Center',obj.TranslationVector(i,1:2));
                gp1=gp1-hole;
            end
        else
            for i=1:size(obj.FeedLocation,1)
                npoints=size(obj.Element(i).MesherStruct.Mesh.HardEdges,1);
                hole=antenna.Circle('Radius',obj.Element(i).Radius,'NumPoints',npoints,...
                'Center',obj.TranslationVector(i,1:2));
                gp1=gp1-hole;
            end
        end
        if isHminUserSpecified(obj)
            minel=getMinContourEdgeLength(obj);
        else
            minel=0.3*edgeLength;
        end
        [~]=mesh(gp1,'MaxEdgeLength',edgeLength,'MinEdgeLength',minel);
        [pGP,tGP]=exportMesh(gp1);
        pGP=pGP';
        tGP=tGP';
    else
        if isempty(obj.Element(1).MesherStruct.Mesh.PartMesh.GndConnectionDomain)

            switch groundPlaneShape
            case 'Rectangle'
                gp_L=obj.GroundPlaneLength;
                gp_W=obj.GroundPlaneWidth;
                N=10;
                base=em.internal.makeplate(gp_L,gp_W,N,'chebyshev-II');
                domains={base};
                [pGP,tGP]=meshGroundPlane(obj,domains,0,[],gp_L,gp_W,0);
            case 'Circle'
                gp_R=obj.GroundPlaneRadius;
                circGP=antenna.Circle('Radius',gp_R);
                [~]=mesh(circGP,'MaxEdgeLength',edgeLength,'GrowthRate',growthRate,...
                'MinEdgeLength',0.01*edgeLength);
                [pGP,tGP]=exportMesh(circGP);
                pGP=pGP';tGP=tGP';

                pGP(3,:)=0;
                tGP(4,:)=0;
            end
        else
            W=arrayfun(@getFeedWidth,obj.Element);
            domainsConn=arrayfun(@getGndConnectionDomain,obj.Element,'UniformOutput',false);



            numconnections=size(obj.FeedLocation,1);
            if isscalar(W)
                W=repmat(W,numconnections,1);
                domainsConn=repmat(domainsConn{:},numconnections,1);
            else
                tempdomainsConn=[];
                for i=1:numconnections
                    tempdomainsConn=[tempdomainsConn;domainsConn{i}];
                end
                domainsConn=tempdomainsConn;
            end
            for i=1:numconnections
                for j=1:size(domainsConn,2)
                    domainsConn{i,j}=em.internal.translateshape(domainsConn{i,j},obj.TranslationVector(i,:));
                end
            end
            domainsConn=domainsConn';
            domains=domainsConn(:)';




            listEdgeX={'helix','fractalSnowflake'};

            if any(strcmpi(class(obj.Element(1)),listEdgeX))||...
                (isa(obj.Element(1),'em.BackingStructure')&&...
                any(strcmpi(class(obj.Element(1).Exciter(1)),listEdgeX)))

                tri=[1,2,3;1,3,4];
            elseif isa(obj.Element,'em.PrintedAntenna')

                tri=[1,2,4;2,4,3];
            else

                tri=[1,2,3;2,3,4];
            end


            switch groundPlaneShape
            case 'Rectangle'
                gp_L=obj.GroundPlaneLength;
                gp_W=obj.GroundPlaneWidth;
                ground=antenna.Rectangle('Length',gp_L,'Width',gp_W);
                [~]=mesh(ground,'MaxEdgeLength',edgeLength,...
                'GrowthRate',growthRate);
                [ppatch,tpatch]=exportMesh(ground);
                feed=obj.FeedLocation;

                if isa(obj.Element,'invertedF')
                    sz=2*size(feed,1);
                else
                    sz=size(feed,1);
                end
                [pGP,tGP,feedPatchVer,feedtri]=makefeedConnectionOnGround(obj,domains,tri,sz,ppatch,tpatch);

            case 'Circle'
                gp_R=obj.GroundPlaneRadius;
                ground=antenna.Circle('Radius',gp_R);
                [~]=mesh(ground,'MaxEdgeLength',edgeLength,'GrowthRate',...
                growthRate);
                [ppatch,tpatch]=exportMesh(ground);
                feed=obj.FeedLocation;
                sz=size(feed,1);
                [pGP,tGP,feedPatchVer,feedtri]=makefeedConnectionOnGround(obj,domains,tri,sz,ppatch,tpatch);
            end





            feedInGnd=1;
            for i=1:size(feedPatchVer,1)
                [in,on]=contains(ground,feedPatchVer(i,1),feedPatchVer(i,2));
                if~in&&~on
                    feedInGnd=0;
                    break;
                end
            end


            if feedInGnd
                T=[];
                EpsilonR=[];
                LossTangent=[];
                Hmin=getMinContourEdgeLength(obj);
                if isempty(Hmin)
                    Hmin=0.05*edgeLength;
                else
                    Hmin=getMinContourEdgeLength(obj);
                end
                Mesh=em.internal.makeMeshStructure(pGP,tGP,T,EpsilonR,LossTangent);



                [~,fixedEdges]=em.internal.meshprinting.meshedges(feedPatchVer,feedtri);
                defaultfeed=(feedPatchVer(fixedEdges(:,1),:)+feedPatchVer(fixedEdges(:,2),:))/2;

                if strcmpi(class(obj.Element),'invertedF')
                    ls=obj.Element.LengthToShortEnd;
                    f2=[defaultfeed(1,1)-ls,0,0;defaultfeed(2,1)-ls,0,0];
                    mh=remesh(obj,Mesh,Hmin,edgeLength,[defaultfeed;f2]);
                else
                    mh=remesh(obj,Mesh,Hmin,edgeLength,defaultfeed);
                end
                pGP=mh.Points;tGP=mh.Triangles;
            end

            if~isDielectricSubstrate(obj)&&feedInGnd


                z=isprop(obj.Element,'Exciter');
                if all(z)
                    for i=1:size(obj.Element,2)
                        y=isa(obj.Element(i).Exciter,'spiralArchimedean');
                        if y
                            break;
                        end
                    end
                end
                if~(all(z,'all')&&y)


                    tr1=triangulation(tGP(1:3,:)',pGP(1,:)',pGP(2,:)');
                    for m=1:numconnections
                        feed_x=obj.DefaultFeedLocation(m,1);
                        feed_y=obj.DefaultFeedLocation(m,2);
                        [feed_pt1y,~,feed_pt2y,~]=em.internal.findcommonedge(tr1,...
                        feed_x,feed_y,W(m),'Edge-Y');%#ok<ASGLU>
                        [feed_pt1x,~,feed_pt2x,~]=em.internal.findcommonedge(tr1,...
                        feed_x,feed_y,W(m),'Edge-X');%#ok<ASGLU>





                        if isempty(feed_pt1x)&&isempty(feed_pt2y)
                            error(message('antenna:antennaerrors:FailureMeshGen'));
                        end
                    end
                end
            end


            tGP=sortrows(tGP(1:3,:)');
            tGP(:,4)=1;
            tGP=tGP';
        end
    end
end



function[pGP,tGP,feedPatchVer,feedtri]=makefeedConnectionOnGround(obj,domains,tri,sz,ppatch,tpatch)
    offset=0;
    feedtri=[];


    k=1:2:numel(domains);
    for m=1:sz
        if isa(obj.Element,'em.PrintedAntenna')




            tempVertices=transpose(domains{m});
            tempEdges=zeros(size(tempVertices,1),2);
            tempEdges(:,1)=1:size(tempVertices,1);
            tempEdges(:,2)=tempEdges(:,1)+1;
            tempEdges(end,2)=1;




            warnState1=warning('Off','MATLAB:delaunayTriangulation:DupConsWarnId');
            warnState2=warning('Off','MATLAB:delaunayTriangulation:DupPtsConsUpdatedWarnId');
            warnState3=warning('Off','MATLAB:delaunayTriangulation:ConsSplitPtWarnId');
            dt=delaunayTriangulation(tempVertices(:,1:2));
            warning(warnState1);
            warning(warnState2);
            warning(warnState3);

            tempTriangulation=dt.ConnectivityList;
            tempVertices=dt.Points;
            tempVertices(:,3)=0;


            feedPatchVer((offset+1):(offset+size(tempVertices,1)),:)=tempVertices;
            feedtri=[feedtri;tempTriangulation+offset];%#ok<AGROW>

        else
            feedPatchVer(offset+1:offset+4,:)=unique([domains{k(m)}...
            ,domains{k(m)+1}]','rows','stable');
            feedtri=[feedtri;tri+offset];%#ok<AGROW>
        end

        offset=max(max(feedtri));
    end


    Mi=em.internal.meshprinting.imprintMesh(feedPatchVer,...
    feedtri,ppatch,tpatch(:,1:3));


    pGP=Mi.P';
    tGP=Mi.t';
    pGP(3,:)=0;
    tGP(4,:)=0;
end

