








function[root,fields,indices,unsupportedStruct]=parseStructureParam(mexpr)
    assert(~isempty(mexpr));
    unsupportedStruct=false;
    fields=[];
    indices=[];
    root='';

    mt=mtree(mexpr).root;
    assert(~isempty(mt));
    if strcmp(mt.kind,'ERR')
        return;
    end

    if any(strcmpi(mt.kind,{'EXPR','PRINT'}))

        [success,children]=slci.mlutil.getMtreeChildren(mt);
        assert(success&&~isempty(children));
        mRoot=children{1};
    else
        mRoot=mt;
    end


    mRoot=getEffectiveNode(mRoot);
    switch mRoot.kind
    case 'SUBSCR'
        [root,fields,indices]=translateSubscript(mRoot);
    case 'DOT'
        [root,fields]=translateDot(mRoot);
    otherwise

        unsupportedStruct=false;
        return;
    end



    if isempty(root)
        unsupportedStruct=true;
    end

end


function[root,fields,indices]=translateSubscript(node)
    assert(strcmpi(node.kind,'SUBSCR'));
    root='';
    fields=[];
    indices=[];
    [success,children]=slci.mlutil.getMtreeChildren(node);
    assert(success,DAStudio.message('Slci:slci:unsupportedNodeMtree','SUBSCR'));
    num_children=numel(children);
    if(num_children~=2)&&(num_children~=3)
        return;
    end
    baseNode=children{1};
    if strcmpi(baseNode.kind,'DOT')
        [root,fields]=translateDot(baseNode);
    else
        return;
    end
    indices=cell(1,num_children-1);

    index_for_cell=1;

    for i=2:num_children
        [succ_node,val]=translateIndex(children{i});
        if~succ_node

            root='';
            fields=[];
            indices=[];
            return;
        else
            indices{index_for_cell}=val;

            index_for_cell=index_for_cell+1;
        end
    end
end





function[root,fields]=translateDot(node)
    assert(strcmpi(node.kind,'DOT'));
    fields=[];
    [success,children]=slci.mlutil.getMtreeChildren(node);
    assert(success,DAStudio.message('Slci:slci:unsupportedNodeMtree','DOT'));
    assert(numel(children)==2);
    base=children{1};
    if strcmpi(base.kind,'ID')
        root=base.string;
    elseif strcmpi(base.kind,'DOT')
        [root,fields]=translateDot(base);
    else


        root=[];
        fields=[];
        return;
    end

    mField=children{2};
    fields=[fields,{mField.string}];

end


function[succ,val]=translateIndex(node)
    succ=false;
    val='';

    switch node.kind
    case 'INT'
        succ=true;
        val=node.string;
    case 'CALL'
        val='';
        rightChild=node.Right;

        if isempty(rightChild)

            leftChild=node.Left;
            if strcmpi(leftChild.kind,'ID')...
                &&strcmpi(leftChild.string,'end')
                succ=true;
                val=leftChild.string;
            end
        end
    case 'PARENS'
        [successflag,childs]=slci.mlutil.getMtreeChildren(node);
        assert(successflag,...
        DAStudio.message('Slci:slci:unsupportedNodeMtree','PARENS'));
        [succ,val]=translateIndex(childs{1});
    otherwise

    end
end




function node=getEffectiveNode(root)
    node=root;
    if strcmpi(root.kind,'PARENS')
        [successflag,children]=slci.mlutil.getMtreeChildren(root);
        assert(successflag,...
        DAStudio.message('Slci:slci:unsupportedNodeMtree','PARENS'));
        node=getEffectiveNode(children{1});
    end
end
