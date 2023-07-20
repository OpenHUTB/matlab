function checkSumAndProd(this,node)





    outType=this.getType(node);
    inType=this.getType(node.Right);

    if outType.isDouble&&~inType.isDouble

        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:SumProdUnsupportedTyping',...
        node.tree2str);
    end

    if inType.isFloat

        optionArg=node.Right.Next;
        while~isempty(optionArg)
            optionArgDesc=this.getVarDesc(optionArg);
            if optionArgDesc.isConst&&ischar(optionArgDesc.constVal{1})&&strcmpi(optionArgDesc.constVal{1},'omitnan')
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:SumProdNaNOmitted',...
                node.tree2str);
            end
            optionArg=optionArg.Next;
        end
    end

    if inType.isLogical

        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:SumProdLogicalTypeUnsupported',...
        node.tree2str);
    end

end
