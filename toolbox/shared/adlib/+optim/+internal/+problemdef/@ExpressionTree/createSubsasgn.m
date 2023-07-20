function createSubsasgn(obj,sz,linIdxList,treeList,treeIdxList,variables)


















    nTrees=numel(treeList);



    roots=cell(nTrees,1);

    stack=cell(nTrees,1);

    depth=zeros(nTrees,1);

    childrenPos=zeros(nTrees,1);

    treei=treeList{1};
    roots{1}=treei.Root;
    stack{1}=treei.Stack;
    childrenPos(1)=numel(stack{1});
    depth(1)=treei.Depth;

    type=treei.Type;
    if nTrees>1
        typeList=optim.internal.problemdef.ImplType(zeros(nTrees,1));
        typeList(1)=type;

        for i=2:nTrees

            treei=treeList{i};
            roots{i}=treei.Root;

            depth(i)=treei.Depth;

            typeList(i)=treei.Type;

            stack{i}=treei.Stack;


            childrenPos(i)=childrenPos(i-1)+numel(stack{i});
        end

        type=optim.internal.problemdef.ImplType.typeSubsasgn(typeList);
    end


    Node=optim.internal.problemdef.SubsasgnExpressionImpl(sz,linIdxList,roots,treeIdxList);


    Node.ChildrenPosition=childrenPos;


    obj.Depth=max(depth)+1;


    obj.Stack=[stack{:},{Node}];

    Node.StackLength=numel(obj.Stack);


    obj.Type=type;


    obj.Variables=variables;

end
