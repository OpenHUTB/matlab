classdef NodeNetwork<handle


    methods(Static)

        function createNetwork(MapDataManager)


            if~isempty(MapDataManager.OccMap)
                agentFootprint=[MapDataManager.getBaseAgentHeight,MapDataManager.getBaseAgentWidth];
                logicalMap=occupancyMatrix(MapDataManager.OccMap);


                paddingFactor=MapDataManager.getBaseAgentPadding;


                agentRadius=ceil(sqrt(agentFootprint(1)^2+agentFootprint(2)^2)/2*paddingFactor);

                for ii=1:size(logicalMap,1)
                    for jj=1:size(logicalMap,2)
                        entity.Map(ii,jj).Name=[ii;jj]-1;
                        nodesX=ii-agentRadius:ii+agentRadius-1;
                        nodesY=size(logicalMap,1)-jj+2-agentRadius:size(logicalMap,1)-jj+1+agentRadius;
                        if any(nodesY<1)||any(nodesY>size(logicalMap,2))||any(nodesX<1)||any(nodesX>size(logicalMap,1))
                            entity.Map(ii,jj).North=false;
                            entity.Map(ii,jj).East=false;
                            entity.Map(ii,jj).South=false;
                            entity.Map(ii,jj).West=false;
                        else
                            open=true;
                            for kk=1:length(nodesX)
                                for nn=1:length(nodesY)
                                    open=open&&~logicalMap(nodesY(nn),nodesX(kk));
                                end
                            end
                            entity.Map(ii,jj).North=open;
                            entity.Map(ii,jj).East=open;
                            entity.Map(ii,jj).South=open;
                            entity.Map(ii,jj).West=open;
                            if~open
                                MapDataManager.NetworkEdits.EditedGrids(ii,jj)=0;
                            end
                        end
                    end
                end
                for ii=1:size(logicalMap,1)
                    for jj=1:size(logicalMap,2)
                        if ii==1||~entity.Map(ii-1,jj).East
                            entity.Map(ii,jj).West=false;
                        end
                        if ii==size(logicalMap,1)||~entity.Map(ii+1,jj).West
                            entity.Map(ii,jj).East=false;
                        end
                        if jj==1||~entity.Map(ii,jj-1).North
                            entity.Map(ii,jj).South=false;
                        end
                        if jj==size(logicalMap,2)||~entity.Map(ii,jj+1).South
                            entity.Map(ii,jj).North=false;
                        end
                    end
                end

                MapDataManager.Network=entity;


                if find(any(MapDataManager.NetworkEdits.EditedGrids))
                    editedGrids=logical(MapDataManager.NetworkEdits.EditedGrids);
                    MapDataManager.Network.Map(editedGrids)=MapDataManager.NetworkEdits.Map(editedGrids);
                else

                    MapDataManager.NetworkEdits=entity;
                    MapDataManager.NetworkEdits.EditedGrids=zeros(size(entity.Map));
                end
            end
        end
    end
end

