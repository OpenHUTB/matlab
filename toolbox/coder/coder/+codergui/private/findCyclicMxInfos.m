function[cyclicInfoIds,infoIdFilter]=findCyclicMxInfos(inferenceFuncs,mxInfos)




    possible=false;
    if~isempty(inferenceFuncs)
        allMessages=[inferenceFuncs.Messages];
        if~isempty(allMessages)
            possible=any(ismember({allMessages.MsgID},{...
            'Coder:builtins:MCOSSeaLimitationNew',...
            'Coder:builtins:MCOSSeaLimitationInstance',...
            'Coder:builtins:MCOSSeaLimitationInstanceNamedVar',...
            'Coder:builtins:MCOSSeaLimitationInstanceProp'}));
        end
    end
    if~possible
        cyclicInfoIds=[];
        infoIdFilter=[];
        return;
    end

    infoIds=1:numel(mxInfos);
    infoIdFilter=false(size(mxInfos));

    for i=1:numel(infoIds)
        testCyclic(infoIds(i),[]);
    end

    cyclicInfoIds=infoIds(infoIdFilter);



    function testCyclic(infoId,path)
        if infoIdFilter(infoId)
            return;
        end
        if any(path==infoId)
            infoIdFilter(infoId)=true;
            return;
        end
        path=[path,infoId];
        info=mxInfos{infoId};
        if isa(info,'eml.MxCellInfo')
            for j=1:numel(info.CellElements)
                testCyclic(info.CellElements(j),path)
            end
        elseif isa(info,'eml.MxClassInfo')
            for j=1:numel(info.ClassProperties)
                testCyclic(info.ClassProperties(j).MxInfoID,path)
            end
        elseif isa(info,'eml.MxStructInfo')
            for j=1:numel(info.StructFields)
                testCyclic(info.StructFields(j).MxInfoID,path)
            end
        end
    end
end