function[newTAArray,objectsCopied]=copyTree(rootObj,startPosition,objectsCopied)
    newTAArray{1}=copy(rootObj);
    objectsCopied=[objectsCopied,rootObj.Index];
    newTAArray{1}.Index=1+startPosition;
    if isa(rootObj,'ModelAdvisor.Group')
        for i=1:numel(rootObj.ChildrenObj)
            if isa(rootObj.ChildrenObj{i},'ModelAdvisor.Task')
                newTaskObj=copy(rootObj.ChildrenObj{i});
                objectsCopied=[objectsCopied,rootObj.ChildrenObj{i}.Index];%#ok<AGROW>
                newTaskObj.Index=numel(newTAArray)+1+startPosition;
                newTaskObj.ParentIndex=newTAArray{1}.Index;
                newTAArray{1}.ChildrenIndex{i}=newTaskObj.Index;
                newTAArray{end+1}=newTaskObj;
            else
                newTAArray{1}.ChildrenIndex{i}=numel(newTAArray)+startPosition+1;
                [childArray,objectsCopied]=Advisor.Utils.copyTree(rootObj.ChildrenObj{i},numel(newTAArray)+startPosition,objectsCopied);
                childArray{1}.ParentIndex=newTAArray{1}.Index;
                newTAArray=[newTAArray,childArray];
            end
        end
    end
end
