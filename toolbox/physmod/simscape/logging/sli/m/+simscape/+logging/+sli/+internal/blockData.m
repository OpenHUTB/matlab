function data=blockData(blockHandle)








    data=struct('time',{},'values',{},'unit',{},'label',{});

    model=bdroot(blockHandle);
    loggingEnabled=~strcmpi(get_param(model,'SimscapeLogType'),'none');

    if loggingEnabled
        simlog=simscape.logging.sli.internal.getModelLog(model);
        if~isempty(simlog)
            [isValid,nodePath]=simscape.logging.findPath(simlog,blockHandle);
            if isValid
                blockNode=node(simlog,nodePath);
                data=lGetData(blockNode);
            end
        end
    end

end




function data=lGetData(node)


    data=[];
    childIds=node.childIds;
    for idx=1:numel(childIds)

        childNode=node.child(childIds{idx});
        t=childNode.series.time;
        if~isempty(t)
            childData.time=t;
            childData.unit=childNode.series.unit;
            dim=childNode.series.dimension;
            if(dim(1)>1||dim(2)>1)
                childData.label=[childIds{idx},'(1,1) of (',...
                num2str(dim(1)),',',num2str(dim(2)),')'];
                values=childNode.series.values(childData.unit);
                childData.values=values(1:dim(1)*dim(2):numel(values));
            else
                childData.label=childIds{idx};
                childData.values=childNode.series.values(childData.unit);
            end
            if isempty(data)
                data=childData;
            else
                data(end+1)=childData;%#ok<AGROW>
            end
        end

        childrenData=lGetData(childNode);
        for jdx=1:numel(childrenData)

            childrenData(jdx).label=[childIds{idx},'.',childrenData(jdx).label];
            if isempty(data)
                data=childrenData(jdx);
            else
                data(end+1)=childrenData(jdx);%#ok<AGROW>
            end
        end
    end

end
