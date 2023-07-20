
function aNode=activeNode(varargin)




    persistent activeNodeMap;
    if isempty(activeNodeMap)
        activeNodeMap=containers.Map('KeyType','char','ValueType','any');
    end
    try
        if nargin==1
            aNode=activeNodeMap(varargin{1});
        else
            activeNodeMap(varargin{2})=varargin{1};
            aNode=varargin{1};
        end
    catch MEx
        rethrow(MEx);
    end
end