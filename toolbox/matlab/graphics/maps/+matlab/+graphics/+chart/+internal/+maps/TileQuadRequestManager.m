




















classdef TileQuadRequestManager<handle

    properties(GetAccess='public',SetAccess='private')
        TileRequestMap containers.Map
    end

    methods
        function manager=TileQuadRequestManager
            manager.TileRequestMap=containers.Map.empty;
        end

        function newRequestIndex=newRequest(manager,locations,qrefs)
            locations=string(locations);
            trmap=manager.TileRequestMap;
            newRequestIndex=true(length(locations),1);
            for k=1:length(locations)
                key=locations(k);
                if isKey(trmap,key)





                    qref=trmap(key);
                    if~isempty(qref)&&~isempty([qref.TileQuad])
                        trmap(key)=[qref;qrefs(k)];
                        newRequestIndex(k)=false;
                    else
                        trmap(key)=qrefs(k);
                    end
                else

                    trmap(key)=qrefs(k);
                end
            end
            manager.TileRequestMap=trmap;
        end


        function removeRequest(manager,location,filledQref)
            key=string(location);
            trmap=manager.TileRequestMap;
            if isKey(trmap,key)
                qref=trmap(key);
                if isscalar(qref)&&isscalar(qref.TileQuad)
                    remove(trmap,key);

                elseif length(qref)>1&&nargin==3


                    index=filledQref==qref;
                    qref(index)=[];
                    trmap(key)=qref;
                else

                    remove(trmap,key);
                end
            end
            manager.TileRequestMap=trmap;
        end


        function qref=findTileQuadReference(manager,location)
            key=string(location);
            trmap=manager.TileRequestMap;
            if isKey(trmap,key)
                qref=trmap(key);
                qref=qref(isvalid(qref));
            else
                qref=[];
            end
        end
    end
end
