function printTree(treeOrBlock,depth)
    if ishandle(treeOrBlock)
        tree=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(treeOrBlock).port.tree;
    else
        tree=treeOrBlock;
    end

    if isempty(tree)||~isvalid(tree)||~isa(tree,'sl.mfzero.treeNode.TreeNode')
        error('*** Invalid tree object ***');
    end

    if nargin==1
        depth=0;
    end

    function locPrintWithIndent(format,str)
        fprintf(1,['%s',format,'\n'],repmat(' ',1,4*depth),str{:});
    end

    ca=tree.childAttrs;
    pa=tree.parentAttrs;
    ba=tree.blockAttrs;
    sa=tree.signalAttrs;
    btra=tree.busTypeRootAttrs;
    btea=tree.busTypeElementAttrs;
    addl={};

    if isvalid(ca)
        fmt='|- %s';
        args={ca.name};
        addl=[addl,{{'indexOne: %d',ca.indexOne}}];
    else
        fmt='%s';
        args={'[root]'};
    end

    if isvalid(ba)
        addl=[addl,{{'hasBlocks: %s','true'}}];
    end

    if isvalid(btra)
        addl=[addl,{{'btra: %s','true'}}];
    end

    if isvalid(btea)
        addl=[addl,{{'btea: %s','true'}}];
    end

    if isvalid(sa)
        addl=[addl,{...
        {'complexity: %s',sa.complexity},...
        {'min: %s',mat2str(sa.min)},...
        {'max: %s',mat2str(sa.max)},...
        {'unit: %s',mat2str(sa.unit)},...
        {'dataType: %s',mat2str(sa.dataType)},...
        {'dims: %s',mat2str(sa.dims)},...
        {'dimsMode: %s',sa.dimsMode},...
        {'sampleTime: %s',mat2str(sa.sampleTime)},...
        {'isNonVirtual: %s',mat2str(sa.virtuality)}...
        }];
    end

    for i=1:numel(addl)
        if i==1
            fmt=[fmt,' ('];
        end
        fmt=[fmt,addl{i}{1}];
        args=[args,addl{i}(2)];
        if i==numel(addl)
            fmt=[fmt,')'];
        else
            fmt=[fmt,', '];
        end
    end

    locPrintWithIndent(fmt,args);

    if isvalid(pa)
        children=pa.children.toArray();
        for i=1:numel(children)
            Simulink.internal.CompositePorts.printTree(children(i),depth+1);
        end
    end

end
