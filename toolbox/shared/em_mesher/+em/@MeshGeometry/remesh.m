function OutMesh=remesh(obj,Mesh,Hmin,Hmax,feed)%#ok<INUSL>




    r=getRemeshParams(obj,Hmin,Hmax,Mesh);
    Hmax=r.Hmax;
    Hgrad=r.Hgrad;
    Hmin=r.Hmin;
    Htarget=r.Htarget;
    Hsubdomain=r.Hsubdomain;
    setMeshMinContourEdgeLength(obj,Hmin);
    if nargin>4
        r.feedpoint=feed;
    end
    if isfield(obj.MesherStruct.Mesh,'HardEdges')
        feedsAndVias=[r.feedpoint;obj.MesherStruct.Mesh.HardEdges];
    else
        feedsAndVias=[r.feedpoint];
    end
    if isa(obj,'reflectorCylindrical')&&obj.EnableProbeFeed==0
        feedsAndVias=[];
    end

    OutMesh=Mesh;
    pIn=Mesh.Points';
    tIn=Mesh.Triangles';

    [pOut,~,tOut]=em.MeshGeometry.remesher(pIn,tIn,Hmax,Hgrad,Hmin,Htarget,Hsubdomain,feedsAndVias);
    pOut=pOut';
    tOut=tOut';






    domainNumIn=unique(tIn(:,4));
    domainNumOut=unique(tOut(:,4));
    if isequal(numel(domainNumIn),1)
        tOut(:,4)=domainNumIn;
    elseif~isequal(domainNumIn,domainNumOut)
        warnflag=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
        TRin=triangulation(tIn(:,1:3),pIn);
        TRout=triangulation(tOut(:,1:3),pOut);
        eIn=edges(TRin);
        eOut=edges(TRout);
        warning(warnflag);
        inCenters=incenter(TRin);
        inNormals=faceNormal(TRin);
        outCenters=incenter(TRout);
        outNormals=faceNormal(TRout);
        newDomain=tOut(:,4);
        for i=1:numel(domainNumOut)
            testDomain=domainNumOut(i);
            testTri=find(tOut(:,4)==testDomain);
            tempNormals=outNormals(testTri,:);
            tempCenters=outCenters(testTri,:);


            [k,dist]=dsearchn(inCenters,tempCenters);
            [dist,ind]=sort(dist);
            k=k(ind);

            isDomainSet=false;
            ctr=0;



            while~isDomainSet&&ctr<numel(k)
                ctr=ctr+1;

                for q=1:size(tempNormals,1)
                    if~isempty(k)&&abs(abs(dot(tempNormals(q,:),inNormals(k(ctr),:))))>0.5
                        newDomain(testTri)=tIn(k(ctr),4);
                        isDomainSet=true;
                        break;
                    end
                end
            end

        end
        tOut(:,4)=newDomain;

        if~isequal(domainNumIn,unique(newDomain))

            if~isempty(feedsAndVias)
                for i=1:size(feedsAndVias,1)
                    [Dout,INDout]=em.internal.meshprinting.inter2_point_seg(pOut,eOut,feedsAndVias(i,:));
                    [Din,INDin]=em.internal.meshprinting.inter2_point_seg(pIn,eIn,feedsAndVias(i,:));
                    tempIndex=find(Dout<sqrt(eps)&INDout==-1);%#ok<AGROW>
                    if~isempty(tempIndex)&&isscalar(tempIndex)
                        indexOut(i)=tempIndex;%#ok<AGROW>
                    else
                        closestEdgeId=find(Dout==min(Dout));
                        indexOut(i)=closestEdgeId(1);%#ok<AGROW>
                    end
                    tempIndex=find(Din<sqrt(eps)&INDin==-1);%#ok<AGROW>
                    if~isempty(tempIndex)&&isscalar(tempIndex)
                        indexIn(i)=tempIndex;%#ok<AGROW>
                    else
                        closestEdgeId=find(Din==min(Din));
                        indexIn(i)=closestEdgeId(1);%#ok<AGROW>
                    end


                    feed_edges=eOut(indexOut,:);
                    ID_outTri=edgeAttachments(TRout,feed_edges);
                    ID_outTri=cell2mat(ID_outTri);
                    feed_edges=eIn(indexIn,:);
                    ID_inTri=edgeAttachments(TRin,feed_edges);
                    ID_inTri=cell2mat(ID_inTri);
                    tOut(ID_outTri,4)=tIn(ID_inTri,4);
                end
            end
        end
    end


    if numel(domainNumIn)>1
        if any(domainNumIn==0)
            tOut(:,4)=tOut(:,4)+1;
        end
    end


    OutMesh.Points=pOut';
    OutMesh.Triangles=tOut';

end






















