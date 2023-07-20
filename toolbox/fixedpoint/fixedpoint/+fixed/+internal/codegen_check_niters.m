function codegen_check_niters(n,fcnStr)%#codegen











    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(n);

    coder.internal.assert(coder.internal.isConst(n),...
    'fixed:cordic:nitersConstCodeGen');
    coder.internal.assert(~isempty(n)&&isscalar(n)&&isnumeric(n)&&...
    isreal(n)&&n>0&&floor(n)==n,...
    'fixed:cordic:invalidNiters',fcnStr);
end
