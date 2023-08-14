function mapObj=breadthFirstSearch(diG,inputNames,nameToLayerObj,fun,varargin)







    assert(numel(varargin)<=1,'Only a single flag can be passed in as varargin');
    mapObj=containers.Map;

    keys=diG.Nodes.Name;
    values=cell(1,numel(keys));
    values(:)={0};

    VisitedMap=containers.Map(keys,values);
    uniqueLayerNames={};
    for i=1:numel(inputNames)
        inputLayerName=strsplit(inputNames{i},'/');
        inputLayerName=inputLayerName{1};
        uniqueLayerNames=[uniqueLayerNames,inputLayerName];%#ok
    end
    uniqueLayerNames=unique(uniqueLayerNames,'stable');
    nodeList=uniqueLayerNames;

    while~isempty(nodeList)
        node=nodeList{1};
        nodeList(1)=[];

        if VisitedMap(node)==0
            nodeSuccessors=successors(diG,node);
            for i=1:numel(nodeSuccessors)
                nodeList=[nodeList,nodeSuccessors{i}];%#ok<AGROW> % queue.push()
            end
            VisitedMap(node)=1;


            mapObj=fun(node,nameToLayerObj,mapObj,diG,varargin{1});

        end
    end

end
