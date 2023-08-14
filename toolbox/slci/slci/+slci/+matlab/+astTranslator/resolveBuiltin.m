


function cObj=resolveBuiltin(mtreeNode,astObj)

    [cObj,resolved]=createBuiltin(mtreeNode,astObj);
    if~resolved

        AstClassName='slci.ast.SFAstUnsupported';
        cmd=['cObj = ',AstClassName,' (mtreeNode, astObj);'];
        eval(cmd);
    end

end



function[cObj,resolved]=createBuiltin(node,astObj)
    cObj=[];
    resolved=true;
    assert(any(strcmp(node.kind,{'CALL','LP'})),'Invalid function node');
    ch1=node.Left;
    assert(strcmpi(ch1.kind,'ID'));

    fname=ch1.string;
    if strcmp(fname,'cast')
        cObj=slci.ast.SFAstCastFunction(node,astObj);
    elseif(strcmp(fname,'true')||...
        strcmp(fname,'false'))
        cObj=slci.ast.SFAstTrueFalse(node,astObj);
    elseif strcmp(fname,'end')
        cObj=slci.ast.SFAstEnd(node,astObj);
    elseif strcmp(fname,'zeros')
        cObj=slci.ast.SFAstZeros(node,astObj);
    elseif strcmp(fname,'ones')
        cObj=slci.ast.SFAstOnes(node,astObj);
    elseif strcmp(fname,'eye')
        cObj=slci.ast.SFAstEye(node,astObj);
    elseif slci.ast.SFAstMathBuiltin.isMathType(fname)
        mathType=fname;
        cObj=slci.ast.SFAstMathBuiltin(node,mathType,astObj);
    elseif strcmp(fname,'size')
        cObj=slci.ast.SFAstSize(node,astObj);
    elseif strcmp(fname,'length')
        cObj=slci.ast.SFAstLength(node,astObj);
    elseif strcmp(fname,'numel')
        cObj=slci.ast.SFAstNumel(node,astObj);
    elseif strcmp(fname,'assert')

    elseif any(strcmp(fname,{'uint8','uint16','uint32','int8',...
        'int16','int32','double','single'}))
        cObj=slci.ast.SFAstDirectCast(node,fname,astObj);
    elseif strcmp(fname,'diag')
        cObj=slci.ast.SFAstDiag(node,astObj);
    elseif any(strcmp(fname,{'isempty','isinteger','isfloat','islogical'...
        ,'isnumeric','isscalar','isvector','ismatrix',...
        'isrow','iscolumn'}))
        cObj=slci.ast.SFAstIsTester(node,fname,astObj);
    elseif strcmp(fname,'min')
        cObj=slci.ast.SFAstMin(node,astObj);
    elseif strcmpi(fname,'max')
        cObj=slci.ast.SFAstMax(node,astObj);
    elseif strcmpi(fname,'bitand')
        cObj=slci.ast.SFAstBitAnd(node,astObj);
    elseif strcmpi(fname,'bitor')
        cObj=slci.ast.SFAstBitOr(node,astObj);
    elseif strcmpi(fname,'bitxor')
        cObj=slci.ast.SFAstBitXor(node,astObj);
    elseif strcmpi(fname,'bitcmp')
        cObj=slci.ast.SFAstBitCmp(node,astObj);
    elseif strcmpi(fname,'bitget')
        cObj=slci.ast.SFAstBitGet(node,astObj);
    elseif strcmpi(fname,'bitset')
        cObj=slci.ast.SFAstBitSet(node,astObj);
    elseif strcmpi(fname,'bitshift')
        cObj=slci.ast.SFAstBitShift(node,astObj);
    elseif strcmpi(fname,'prod')
        cObj=slci.ast.SFAstProd(node,astObj);
    elseif strcmpi(fname,'reshape')
        cObj=slci.ast.SFAstReshape(node,astObj);
    elseif strcmpi(fname,'sum')
        cObj=slci.ast.SFAstSum(node,astObj);
    elseif strcmpi(fname,'nnz')
        cObj=slci.ast.SFAstNnz(node,astObj);
    elseif strcmpi(fname,'sign')
        cObj=slci.ast.SFAstSign(node,astObj);
    elseif strcmp(fname,'pi')
        cObj=slci.ast.SFAstPi(node,astObj);
    elseif strcmp(fname,'eps')
        cObj=slci.ast.SFAstEps(node,astObj);
    elseif strcmp(fname,'send')
        cObj=slci.ast.SFAstSendFunction(node.Right,astObj);
    else
        resolved=false;
    end
end
