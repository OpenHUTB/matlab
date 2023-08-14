function checkIsValidLogicalIndex(ExprIdx,range,varargin)











    if numel(ExprIdx)>range&&any(ExprIdx(range+1:end))
        if nargin>2
            pos=varargin{1};
            if isnumeric(pos)
                throwAsCaller(MException('MATLAB:matrix:indexExceedsDims',getString(message('MATLAB:matrix:logicalIndexExceedsDimsPosition',pos))));
            else
                throwAsCaller(MException('MATLAB:matrix:indexExceedsDims',getString(message('MATLAB:matrix:logicalIndexExceedsDimsPosition',find(pos,1)))));
            end
        else
            throwAsCaller(MException('MATLAB:matrix:indexExceedsDims',getString(message('MATLAB:matrix:logicalIndexExceedsDims'))));
        end
    end

end