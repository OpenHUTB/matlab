function matrixMul=getMatMulKind(this)


    dpImpl=this.getImplParams('DotProductStrategy');
    if~isempty(dpImpl)&&strcmpi(dpImpl,'Serial Multiply-Accumulate')
        matrixMul='serialmac';
    elseif~isempty(dpImpl)&&strcmpi(dpImpl,'Parallel Multiply-Accumulate')
        matrixMul='parallelmac';
    elseif~isempty(dpImpl)&&strcmpi(dpImpl,'Fully Parallel Scalarized')
        matrixMul='scalarized';
    else
        matrixMul='linear';
    end

end
