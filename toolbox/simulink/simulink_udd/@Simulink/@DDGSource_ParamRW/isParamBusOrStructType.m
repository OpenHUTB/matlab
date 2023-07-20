function structInfo=isParamBusOrStructType(this,block,paramName)
    assert(isa(get_param(block,'Object'),'Simulink.ModelReference'));

    paramNamePath=regexp(paramName,'/','split');
    paramName=paramNamePath{1};
    instanceParams=get_param(block,'InstanceParameters');
    paramValue='';
    indexes=strfind(paramName,'.');
    paramNameWoMdlBlk=paramName;
    if~isempty(indexes)
        paramNameWoMdlBlk=paramName(indexes(end)+1:end);
    end
    for i=1:length(instanceParams)
        if strcmp(instanceParams(i).Name,paramNameWoMdlBlk)
            paramValue=instanceParams(i).Value;
            break;
        end
    end

    structInfo.isBusOrStructType=false;
    structInfo.treeItems{1}=paramName;
    if(~isempty(paramValue)&&length(paramValue)>8&&strcmp(paramValue(1:6),'struct'))
        structInfo.isBusOrStructType=true;
        structInfo.treeItems{end+1}=getTreeItems(paramValue);
    end
end

function TreeItems=getTreeItems(paramValue)

    paramValueNew=paramValue(8:end-1);
    count=0;preIdx=-1;curIdx=0;
    structEles={};
    for i=1:length(paramValueNew)
        if paramValueNew(i)=='('
            count=count+1;
        elseif paramValueNew(i)==')'
            count=count-1;
        end

        if count==0&&paramValueNew(i)==','
            curIdx=i;
            structEles{end+1}=paramValueNew(preIdx+2:curIdx-1);
            preIdx=curIdx;
        end
    end
    structEles{end+1}=paramValueNew(preIdx+2:end);

    lenStruct=length(structEles);
    TreeItems=cell(1,lenStruct);

    j=1;
    for i=1:2:lenStruct
        TreeItems{i}=structEles{i}(2:end-1);
        if(length(structEles{i+1})>8)&&strcmp(structEles{i+1}(1:6),'struct')
            TreeItems{i+1}=getTreeItems(structEles{i+1});
        else
            TreeItems{i+1}={};
        end
        j=j+1;
    end
end


