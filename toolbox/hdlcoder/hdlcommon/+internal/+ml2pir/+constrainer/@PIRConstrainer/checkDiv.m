function checkDiv(this,node)





    lhsType=this.getType(node.Left);
    lhsIsConst=this.isConst(node.Left);
    rhsType=this.getType(node.Right);
    rhsIsConst=this.isConst(node.Right);

    isComplex=lhsType.isComplex||rhsType.isComplex;

    if isComplex
        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:DivUnsupportedComplex');
    end


    if~((lhsType.isFloat&&~lhsIsConst)||(rhsType.isFloat&&~rhsIsConst))

        isLogical=lhsType.isLogical||rhsType.isLogical;
        if isLogical
            return;
        end

        nodeType=this.getType(node);
        rndMode=nodeType.getRoundMode;

        if~ismember(rndMode,{'Zero','Simplest','Floor'})

            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:DivUnsupportedRnd',...
            rndMode);
        elseif strcmp(rndMode,'Floor')&&...
            ((nodeType.isInt||nodeType.isFi)&&nodeType.isSigned)


            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:DivUnsupportedRnd',...
            rndMode);
        end

        satMode=nodeType.getOverflowMode;


        if~strcmpi(satMode,'Saturate')
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:DivUnsupportedSat',...
            satMode);
        end
    end
end
