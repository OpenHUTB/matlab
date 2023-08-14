function resultObjs=runWrapper(varargin)






    stm.internal.apiDetail.checkAPIRunningPermission('sltest.testmanager.run');

    idMap=[];
    parallelize=false;
    tagStr='';
    rootIds=-1;

    for k=1:2:length(varargin)
        propertyName=varargin{k};
        value=varargin{k+1};
        switch propertyName
        case 'idMap'
            idMap=value;
        case 'parallel'
            parallelize=value;
        case 'tag'
            tagStr=value;
        case 'rootId'
            rootIds=value;
        end
    end

    resultObjs=sltest.testmanager.ResultSet.empty;

    validateattributes(idMap,"numeric",{'2d'});

    isTree=false;
    if(~isempty(tagStr)&&~isempty(rootIds))
        isTree=true;
        idMap=zeros(0,4,'int32');
        for idx=1:length(rootIds)
            nodeList=stm.internal.filterTestsByTags(rootIds(idx),tagStr);

            tmpMap=zeros(length(nodeList),4,'int32');
            for k=1:length(nodeList)
                tmpMap(k,1)=nodeList(k).id;
                tmpMap(k,2)=nodeList(k).type;
                tmpMap(k,3)=nodeList(k).isRoot;
                tmpMap(k,4)=nodeList(k).runAll;
            end
            idMap=[idMap;tmpMap];
        end

    end
    if(isempty(idMap))
        return;
    end


    fileList=idMap(:,1)';
    payload=struct('TestFileIDList',fileList);
    payloadStruct=struct('VirtualChannel','Results/ExecutionFromCMD','Payload',payload);

    if connector.isRunning
        message.publish('/stm/messaging',payloadStruct);
    end

    resultSetIds=stm.internal.executeTests(idMap,parallelize,isTree);
    resultObjs=sltest.internal.getResultSets(resultSetIds);
end
