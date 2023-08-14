function checkFunctionCall(this,node,calleeFcnInfo)





    switch node.kind
    case 'CALL'
        callee=node.Left.string;
    case 'SUBSCR'
        callee=node.Left.tree2str(0,1);
    otherwise
        assert(strcmp(node.kind,'DOT'));
        callee=node.tree2str(0,1);
    end

    if nargin<3
        calleeFcnInfo=[];
    end

    if~this.fcnSupported(callee)&&~(~isempty(calleeFcnInfo)&&...
        internal.mtree.isTranslatableInternalFunction(calleeFcnInfo.scriptPath))


        this.addMessage(...
        node.Left,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedFunctionCall',...
        callee);
    end

    switch callee
    case 'abs'
        this.checkAbs(callee,node);
    case 'any'
        this.checkAny(callee,node);
    case 'bitget'
        this.checkBitGet(callee,node);
    case{'bitrol','bitror'}
        this.checkBitRotate(callee,node);
    case 'bitset'
        this.checkBitSet(node);
    case{'bitshift','bitsrl','bitsll','bitsra'}
        this.checkBitShift(callee,node);
    case 'complex'
        this.checkComplexFunc(callee,node);
    case{'cordicsin','cordiccos','cordicsincos'}
        this.checkCordicSinCos(callee,node);
    case{'min','max'}
        this.checkMinMax(callee,node);
    case{'sin','cos','tan','asin','acos','atan','atan2',...
        'sinh','cosh','tanh','asinh','acosh','atanh',...
        'exp','log','log10','power','hypot','sqrt','rem','mod'}
        this.checkMathTrigOps(callee,node);
    case{'sum','prod'}
        this.checkSumAndProd(node);
    case{'hdl.treesum','hdl.treeprod'}
        this.checkTreeSumAndProd(node);
    case{'half','double'}
        this.checkHalfDoubleConversions(callee,node);
    case{'ceil','fix','floor','round'}
        this.checkRoundingFunc(callee,node);
    case 'sign'
        this.checkSign(callee,node);
    case 'isequal'
        this.checkIsEqual(callee,node);
    case 'hdl.npufun'
        this.checkNpufun(callee,node);
    case 'hdl.iteratorfun'
        this.checkIteratorfun(callee,node);
    case 'internal.hdl.imfilter'
        this.checkImfilter(node);
    end
end


