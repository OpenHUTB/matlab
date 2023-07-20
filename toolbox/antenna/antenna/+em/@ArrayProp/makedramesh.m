function[Mesh,Parts]=makedramesh(obj,Mi)





    if isa(obj,'linearArray')||isa(obj,'circularArray')
        numiter=obj.NumElements;
    elseif isa(obj,'rectangularArray')
        numiter=obj.Size(1)*obj.Size(2);
    end

    if(isinf(obj.Element.GroundPlaneLength)||(isinf(obj.Element.GroundPlaneWidth)))
        pSub=Mi.PRad;tSub=Mi.tRad;
        tr1=triangulation(tSub(:,1:3),pSub(:,1),pSub(:,2));
        feed_pt1_1=[];feed_pt1_2=[];
        for i=1:numiter
            [feed_pt1,~,feed_pt2,~]=em.internal.findcommonedge(...
            tr1,obj.TranslationVector(i,1),obj.TranslationVector(i,2),obj.Element.FeedWidth,'Edge-Y');


            feed_pt1_1(:,end+1:end+1)=feed_pt1;
            feed_pt1_2(:,end+1:end+1)=feed_pt2;
        end
        feed_pt1_1(3,:)=0;feed_pt1_2(3,:)=0;
        Mi.PGp=Mi.PRad;
        Mi.tGP=Mi.tRad;
        Mi.FeedVertex1=feed_pt1_1';
        Mi.FeedVertex2=feed_pt1_2';
        Mi2=em.internal.meshprinting.imprintMesh(Mi.PRad,Mi.tRad(:,1:3),...
        pSub,tSub(:,1:3));
        Mi2.FeedVertex1=feed_pt1_1';
        Mi2.FeedVertex2=feed_pt1_2';
        numLayers=checkSubstrateThicknessVsLambda(obj.Element.Substrate,obj);
        Mi2.NumLayers=numLayers;
        [Mesh,Parts]=makeDielectricMesh(obj.Substrate,obj.Element,Mi2);
        p=Mesh.Points;
        Mesh.Points=em.internal.translateshape(p,[0,0,-obj.Substrate.Thickness]);
        tri=Mesh.Triangles;
        removeTri=[];

        if obj.Element.FeedHeight==max(cumsum(obj.Element.Substrate.Thickness))
            index6=find(Mesh.Points(3,:)==obj.Element.FeedHeight);
            index7=find(Mesh.Points(3,:)==-obj.Element.FeedHeight);
            for i=1:size(tri,2)
                if((any(tri(1,i)==index6)||any(tri(2,i)==index6)||...
                    any(tri(3,i)==index6))&&~(tri(4,i)==2))||...
                    (any(tri(1,i)==index7)||any(tri(2,i)==index7)||...
                    any(tri(3,i)==index7))&&~(tri(4,i)==2)

                    removeTri(end+1:end+1)=i;
                end
            end
        else
            index6=find(Mesh.Points(3,:)>obj.Element.FeedHeight);
            index7=find(Mesh.Points(3,:)<-obj.Element.FeedHeight);
            for i=1:size(tri,2)
                if(any(tri(1,i)==index6)||any(tri(2,i)==index6)||...
                    any(tri(3,i)==index6))||...
                    (any(tri(1,i)==index7)||any(tri(2,i)==index7)||...
                    any(tri(3,i)==index7))

                    removeTri(end+1:end+1)=i;
                end
            end
        end
        Mesh.Triangles(:,removeTri)=[];
    else
        edgeLength=getMeshEdgeLength(obj);
        growthRate=getMeshGrowthRate(obj);
        [pGP,tGP]=makeGroundPlaneMesh(obj,edgeLength,growthRate);

        Mi1=em.internal.meshprinting.imprintMesh(Mi.PRad,Mi.tRad,pGP',tGP(1:3,:)');
        Mi1.FeedVertex1=Mi.FeedVertex1;
        Mi1.FeedVertex2=Mi.FeedVertex2;
        numLayers=checkSubstrateThicknessVsLambda(obj.Element.Substrate,obj);
        Mi1.NumLayers=numLayers;
        HLayer=obj.Element.Substrate.Thickness;
        if numel(HLayer)>1&&numel(numLayers)>1
            ctr=1;
            H=[];NumSubLayers=numel(numLayers);
            while ctr<=NumSubLayers
                if numLayers(ctr)>1
                    Htemp=fliplr(em.internal.chebspace(HLayer(ctr)/2,numLayers(ctr)+1,'II'))+HLayer(ctr)/2;

                    Htemp=diff(Htemp);

                    H(end+1:end+numel(Htemp))=Htemp;
                else

                    H(end+1:end+numel(HLayer(ctr)))=HLayer(ctr);
                end
                ctr=ctr+1;
            end
            H=[0,cumsum(H)];
        else

            H=fliplr(em.internal.chebspace(HLayer/2,numLayers+1,'II'))+HLayer/2;
            if isa(obj.Element,'monopoleTopHat')
                hh=obj.Element.Height;
            else
                hh=obj.Element.FeedHeight;
            end
            Hb=H(H(1,:)<hh);
            Ha=H(H(1,:)>hh);
            H=[Hb,hh,Ha];
        end

        [Mesh,Parts]=makeDielectricMesh(obj.Substrate,obj.Element,Mi1);

        mat=Mi1.PRad;
        for m=1:numel(H)-1
            si=mat;
            si(:,3)=H(m);
            Mi1.PRad(end+1:end+size(si,1),1:3)=si;
        end

        Mesh.Points=round(Mesh.Points,12);Mi1.PRad=round(Mi1.PRad,12);
        [~,in]=setdiff(Mesh.Points',Mi1.PRad,'rows');
        in=in';
        te=Mesh.Tetrahedra;


        removeTet=[];
        for i=1:size(te,2)
            if any(te(1,i)==in)||any(te(2,i)==in)||any(te(3,i)==in)||any(te(4,i)==in)
                removeTet(end+1:end+1)=i;
            end
        end
        Mesh.Tetrahedra(:,removeTet)=[];
        Mesh.EpsilonR(removeTet)=[];
        Mesh.LossTangent(removeTet)=[];

        tri=Mesh.Triangles;
        removeTri=[];
        if isa(obj.Element,'monopoleTopHat')
            return;
        end

        if obj.Element.FeedHeight==max(cumsum(obj.Element.Substrate.Thickness))
            index5=find(Mesh.Points(3,:)==obj.Element.FeedHeight);
            for i=1:size(tri,2)
                if(any(tri(1,i)==index5)||any(tri(2,i)==index5)||...
                    any(tri(3,i)==index5))&&~(tri(4,i)==2)
                    removeTri(end+1:end+1)=i;
                end
            end
        else
            index5=find(Mesh.Points(3,:)>obj.Element.FeedHeight);
            for i=1:size(tri,2)
                if(any(tri(1,i)==index5)||any(tri(2,i)==index5)||...
                    any(tri(3,i)==index5))
                    removeTri(end+1:end+1)=i;
                end
            end
        end
        Mesh.Triangles(:,removeTri)=[];
    end
end
