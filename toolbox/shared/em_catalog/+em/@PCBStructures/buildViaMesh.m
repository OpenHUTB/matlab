function[p_temp,t_temp,viaVertex,via_pt1,via_pt2,metalMeshGenFailure,via_order]=buildViaMesh(obj,p_temp,t_temp,startLayers,vias,stopLayers,stopLayerVias,viaHeight,f,isDielectricSubstrate)




    viaVertex=cell(1,numel(obj.MetalLayersCopy));
    via_pt1=cell(1,numel(obj.MetalLayersCopy));
    via_pt2=cell(1,numel(obj.MetalLayersCopy));
    maxnumlayers=numel(obj.MetalLayersCopy);
    metalMeshGenFailure=false;

    pGP=p_temp(end);
    tGP=t_temp(end);
    pRad=p_temp(1);
    tRad=t_temp(1);
    n=1;

    for i=1:numel(startLayers)
        numViaStopLayers=size(vias{i},1);



        pviatri=[];
        for j=1:numViaStopLayers
            [viapoint1,~,~,~]=em.internal.findPortPoints(p_temp{startLayers(i)}',t_temp{startLayers(i)}',vias{i}(j,1:2));
            if isempty(viapoint1)

                viapoint1=f{i}{j}.ShapeVertices(2,:);
                viapoint2=f{i}{j}.ShapeVertices(3,:);
                via_width(j)=norm(viapoint2-viapoint1);%#ok<*AGROW>
                via_point1(j,:)=viapoint1;
                via_point2(j,:)=viapoint2;%#ok<*NASGU>

                pviatri=[pviatri;viapoint1;viapoint2;f{i}{j}.ShapeVertices(1,:);f{i}{j}.ShapeVertices(4,:)];
            end
        end




        if~isempty(pviatri)
            [p_temp,t_temp]=em.PCBStructures.imprintInMesh(pviatri,p_temp,t_temp,startLayers(i));
        end


        for j=1:numViaStopLayers
            [viapoint1,viapoint2,vt1,vt2]=em.internal.findPortPoints(p_temp{startLayers(i)}',t_temp{startLayers(i)}',vias{i}(j,1:2));
            if~isempty(viapoint1)
                via_width(j)=norm(viapoint2-viapoint1);%#ok<*AGROW>
                via_point1(j,:)=viapoint1;
                via_point2(j,:)=viapoint2;%#ok<*NASGU>
                if~isempty(vt1)&&~isempty(vt2)


                    trivertid=setdiff(union(vt1,vt2),intersect(vt1,vt2));


                    pfeedtri=[viapoint1;viapoint2;p_temp{startLayers(i)}(:,trivertid)'];
                else

                    trivertid=setdiff(union(vt1,vt2),intersect(vt1,vt2))';


                    pfeedtri=[p_temp{startLayers(i)}(:,trivertid)'];
                end
            else


                metalMeshGenFailure=true;
                return;
            end




            viaVertex{vias{i}(j,4)}=[viaVertex{vias{i}(j,4)};pfeedtri];
            via_pt1{vias{i}(j,4)}=[via_pt1{vias{i}(j,4)};viapoint1];
            via_pt2{vias{i}(j,4)}=[via_pt2{vias{i}(j,4)};viapoint2];
            meshViaPts=[via_point1(j,:);via_point2(j,:)];
            fl=vias{i}(j,3)>vias{i}(j,4);
            if fl
                meshViaPts(:,3)=meshViaPts(:,3)+viaHeight{i}(j);
            end
            via_order(n,:)=[vias{i}(j,3:4)];
            n=n+1;
            [pVia{i}{j},tVia{i}{j}]=meshProbe(obj,viaHeight{i}(j),meshViaPts,via_width(j));

            tVia{i}{j}(4,:)=maxnumlayers+1;
        end
    end
    via_order=sortrows(via_order,2);
    if~getMesherType(obj)

        [p_temp,t_temp,metalMeshGenFailure]=em.PCBStructures.imprintViaOnLayerMesh(p_temp,t_temp,viaVertex,stopLayers,stopLayerVias,isDielectricSubstrate,getFeedWidth(obj));

        if metalMeshGenFailure
            return;
        end
    end

    for i=1:numel(startLayers)
        numViaStopLayers=size(vias{i},1);
        for j=1:numViaStopLayers

            [p_temp{startLayers(i)},t_temp{startLayers(i)}]=em.internal.joinmesh(p_temp{startLayers(i)},t_temp{startLayers(i)},pVia{i}{j},tVia{i}{j});
        end
    end



    if length(pVia)>1
        Parts=em.internal.makeMeshPartsStructure('Gnd',[pGP,tGP],...
        'Feed',[{pVia{1}{1}},{tVia{1}{1}}],...
        'Rad',[pRad,tRad]);
    else
        [numFeed,~]=size(obj.FeedLocations);
        [numVia,~]=size(obj.ViaLocations);
        pViacell=pVia{1}(1:numVia);
        tViacell=tVia{1}(1:numVia);
        pFeedcell=pVia{1}(1+numVia:end);
        tFeedcell=tVia{1}(1+numVia:end);
        Parts=em.internal.makeMeshPartsStructure('Gnd',[pGP,tGP],...
        'Feed',[{pFeedcell},{tFeedcell}],...
        'Rad',[pRad,tRad],'Via',[{pViacell},{tViacell}]);
    end
    savePartMesh(obj,Parts);

end