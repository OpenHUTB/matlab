
function aNode=menuNode(varargin)




    persistent menuNodeMap;
    try
        aNode=[];
        uuid=varargin{1};
        if nargin==1
            if~isempty(menuNodeMap)
                fn=menuNodeMap({menuNodeMap.uuid}==string(uuid));
                aNode=fn.node;
            end
        else
            newNode=varargin{2};
            if isempty(menuNodeMap)
                menuNodeMap=struct('uuid',uuid,'node',newNode);
            else
                fidx=find({menuNodeMap.uuid}==string(uuid));
                if~isempty(fidx)
                    menuNodeMap(fidx).node=newNode;
                else
                    menuNodeMap(end+1)=struct('uuid',uuid,'node',newNode);
                end
            end
        end
    catch MEx
        rethrow(MEx);
    end
end

