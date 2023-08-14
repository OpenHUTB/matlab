function process(obj,stateId,controlCode)









    if obj.error>0

        return;
    end

    if stateId>=length(obj.stateOfCC)
        obj.error=6;
        return;
    end

    tnOfParam=obj.totalParamNum;
    nOfObjs=length(obj.objectives);

    slIdx=0;
    inList=cell(tnOfParam,1);

    scriptList=cell(tnOfParam,1);
    for i=1:tnOfParam
        inList{i}=0;
    end




    valueHash=coder.advisor.internal.HashMap('KeyType','uint32','ValueType','any');
    for i=1:nOfObjs
        for j=1:obj.objectives{i}.count
            paramId=obj.objectives{i}.params{j}.id;

            if~controlCode&&checkControlCondition(obj,paramId)
                continue;
            end
            if isempty(valueHash.get(paramId))
                slIdx=slIdx+1;
                scriptList{slIdx}.id=paramId;
                scriptList{slIdx}.value=obj.objectives{i}.params{j}.setting;
                valueHash.put(paramId,scriptList{slIdx}.value);
            end
        end
    end








    valueHash=coder.advisor.internal.HashMap('KeyType','uint32','ValueType','any');
    removedRecommendations=[];
    for i=1:slIdx
        conflict=false;%#ok<NASGU>
        newRecs=struct('id',scriptList{i}.id,'val',scriptList{i}.value);
        if~isempty(valueHash.get(scriptList{i}.id))
            if isequal(valueHash.get(scriptList{i}.id),scriptList{i}.value)


                continue;
            else
                conflict=true;
            end
        else

            [newRecs,conflict]=addAncestorValues(obj,valueHash,newRecs,...
            scriptList{i}.id,scriptList{i}.value);
            if~conflict
                [newRecs,conflict]=addDescendentValues(obj,valueHash,newRecs,...
                scriptList{i}.id,scriptList{i}.value);
            end
        end

        if conflict

            removedRecommendations(end+1)=i;%#ok<AGROW>
        else

            for j=1:length(newRecs)
                valueHash.put(newRecs(j).id,newRecs(j).val);
            end
        end
    end


    scriptList(removedRecommendations)=[];
    obj.lenOfList=slIdx-length(removedRecommendations);
    obj.scriptList=scriptList(1:obj.lenOfList);


    order=cellfun(@(x)obj.Parameters(x.id).DAGOrder,obj.scriptList);
    [~,reorder]=sort(order);
    obj.scriptList=scriptList(reorder);











    valueHash=coder.advisor.internal.HashMap('KeyType','uint32','ValueType','any');

    for i=1:length(obj.scriptList)
        newRecs=struct('id',obj.scriptList{i}.id,'val',obj.scriptList{i}.value);
        [newRecs,conflict]=addDescendentValues(obj,valueHash,newRecs,...
        obj.scriptList{i}.id,obj.scriptList{i}.value);
        assert(~conflict);
        for j=1:length(newRecs)
            valueHash.put(newRecs(j).id,newRecs(j).val);
        end

        depNode=obj.DAGNode{obj.scriptList{i}.id};
        obj.scriptList{i}.flag={};
        for p=1:depNode.numOfParents
            if depNode.parents{p}.force&&...
                isempty(valueHash.get(depNode.parents{p}.id))&&...
                ~isChildMatch(depNode.parents{p},obj.scriptList{i}.value)
                obj.scriptList{i}.flag{end+1}=...
                {obj.Parameters(depNode.parents{p}.id).name,...
                depNode.parents{p}.valueLeft,depNode.parents{p}.invertParent};
            end
        end
    end



end



function toContinue=checkControlCondition(obj,id)
    toContinue=0;

    for k=1:obj.CtrlCond{1}.len
        if id==obj.CtrlCond{1}.param{k}.id
            toContinue=1;
            return;
        end
    end
end

function[newRecs,conflict]=addAncestorValues(obj,valueHash,newRecs,id,value)
    node=obj.DAGNode{id};
    conflict=false;
    for i=1:node.numOfParents
        if node.parents{i}.force&&~strcmp(node.parents{i}.valueRight,'DISABLED')
            if isempty(valueHash.get(node.parents{i}.id))
                if~isChildMatch(node.parents{i},value)



                    parentValue=invertValue(node.parents{i}.valueLeft);
                    newRecs(end+1)=struct('id',node.parents{i}.id,'val',parentValue);%#ok<AGROW>
                    [newRecs,conflict]=addAncestorValues(obj,valueHash,newRecs,node.parents{i}.id,parentValue);
                end




            else

                if isParentMatch(node.parents{i},valueHash.get(node.parents{i}.id))&&...
                    ~isChildMatch(node.parents{i},value)



                    conflict=true;
                    return;
                elseif strcmp(valueHash.get(node.parents{i}.id),'DISABLED')
                    conflict=true;
                    return;
                end
            end
        end
    end
end

function[newRecs,conflict]=addDescendentValues(obj,valueHash,newRecs,id,value)
    node=obj.DAGNode{id};
    conflict=false;
    for i=1:node.numOfChildren
        if node.children{i}.force
            if isempty(valueHash.get(node.children{i}.id))
                if isParentMatch(node.children{i},value)


                    newRecs(end+1)=struct('id',node.children{i}.id,'val',node.children{i}.valueRight);%#ok<AGROW>
                    [newRecs,conflict]=addDescendentValues(obj,valueHash,newRecs,node.children{i}.id,node.children{i}.valueRight);
                end




            else

                if isParentMatch(node.children{i},value)&&...
                    ~isChildMatch(node.children{i},valueHash.get(node.children{i}.id))&&...
                    ~strcmp(node.children{i}.valueRight,'DISABLED')
                    conflict=true;
                    return;
                end
            end
        end
    end
end

function out=isChildMatch(node,value)
    out=strcmpi(node.valueRight,value);
end

function out=isParentMatch(node,value)
    out=strcmpi(node.valueLeft,value);
    if node.invertParent
        out=~out;
    end
end

function out=invertValue(val)
    switch(lower(val))
    case 'on'
        out='off';
    case 'off'
        out='on';
    otherwise
        out='';
    end
end
