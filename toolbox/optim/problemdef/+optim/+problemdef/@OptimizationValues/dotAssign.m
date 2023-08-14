function obj=dotAssign(obj,indexOp,varargin)









    thisProperty=indexOp(1).Name;


    try
        optim.internal.problemdef.mustBeCharVectorOrString(thisProperty,'Property name');
    catch ME
        throwAsCaller(ME);
    end


    if~any(strcmp(thisProperty,properties(obj)))
        ME=MException(message('MATLAB:noSuchMethodOrField',thisProperty,class(obj)));
        throwAsCaller(ME);
    end


    if isempty(varargin{1})
        assignData=NaN;
    else
        assignData=varargin{1};
    end


    if numel(indexOp)>1

        rhs=obj.Values.(thisProperty);
        rhs.(indexOp(2:end))=assignData;
    else
        rhs=assignData;
    end


    propertySize=size(obj.Values.(thisProperty));
    isScalarExpansion=~isscalar(obj)&&isscalar(rhs);
    if isScalarExpansion
        rhs=rhs*ones(propertySize);
    else

        if~isequal(size(rhs),propertySize)
            ME=MException(message('optim_problemdef:OptimizationValues:indexing:CannotGrowOrShrinkViaDotIndexing'));
            throwAsCaller(ME);
        end
    end


    obj.Values.(thisProperty)=rhs;

end
