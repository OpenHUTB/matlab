function[p_temp,t_temp,metalMeshGenFailure]=imprintViaOnLayerMesh(p_temp,t_temp,viaVertex,stopLayers,vias,isDielectricSubstrate,feedWidth)


    for i=1:numel(stopLayers)
        numViaStopLayers=size(vias{i},1);



        for j=1:numViaStopLayers
            [viapoint1,viapoint2,vt1,vt2]=em.internal.findPortPoints(p_temp{stopLayers(i)}',t_temp{stopLayers(i)}(1:3,:)',vias{i}(j,1:2));
            if isempty(vt1)
                isViaMeshOnStopLayer(j)=false;
                metalMeshGenFailure=true;
                return;
            else
                isViaMeshOnStopLayer(j)=true;
                metalMeshGenFailure=false;
            end

            if abs(norm(viapoint1-viapoint2)-feedWidth)>sqrt(eps)
                metalMeshGenFailure=true;
                return;
            end
        end




        pfeedtri=viaVertex{stopLayers(i)};
        numPts=size(pfeedtri,1);
        viaMask=repmat(isViaMeshOnStopLayer,numPts,1);
        viaMask=viaMask(:);
        viaMask=repmat(viaMask,1,3);
        pfeedtri=pfeedtri(~viaMask);


        if~isempty(pfeedtri)
            [p_temp,t_temp]=em.PCBStructures.imprintInMesh(pfeedtri,p_temp,t_temp,stopLayers(i));
        end


        if isDielectricSubstrate
            t_temp{stopLayers(i)}(4,:)=0;
        end
    end

end