function checkTreeSumAndProd(this,node)






    inType=this.getType(node.Right);

    if inType.isLogical

        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:SumProdLogicalTypeUnsupported',...
        node.tree2str);
    end

    if~isempty(node.Right)
        optArg=node.Right.Next;

        if~isempty(optArg)
            optArgType=this.getType(optArg);

            if~(optArgType.isNumeric||optArgType.isChar&&strcmpi(optArg.string,'''all'''))
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:TreeSumProdInvalidOptArg',...
                node.tree2str);
            end
        end
    end

end


