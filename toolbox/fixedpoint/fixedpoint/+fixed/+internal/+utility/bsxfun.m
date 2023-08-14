function C=bsxfun(op,A,B)


























    narginchk(3,3);
    validateattributes(op,{'function_handle'},{'scalar'},1);
    assert(nargin(op)==2,...
    message("fixed:utility:expectedFcnWithNInputs",2));

    if isempty(A)||isempty(B)
        C=[];
    else
        szA=size(A);
        szB=size(B);
        if isequal(szA,szB)

            C=arrayfun(op,A,B);
        elseif numel(szA)==2&&numel(szB)==2...
            &&isequal(min([szA;szB]),[1,1])

            C=cell2mat(arrayfun(@(x1)arrayfun(@(x2)...
            op(x1,x2),B),A,'UniformOutput',false));
        else
            throwAsCaller(MException(...
            message("fixed:utility:expectedMatchedDimensions")));
        end
    end
end
