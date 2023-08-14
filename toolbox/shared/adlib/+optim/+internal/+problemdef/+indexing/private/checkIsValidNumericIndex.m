function checkIsValidNumericIndex(ExprIdx,range,varargin)












    checkIsRealPositiveInteger(ExprIdx,varargin{:});

    if any(ExprIdx>range)
        if nargin>2
            pos=varargin{1};
            if isnumeric(pos)
                throwAsCaller(MException('MATLAB:matrix:indexExceedsDims',getString(message('MATLAB:matrix:indexExceedsDimsPositionSize',pos,range))));
            else
                throwAsCaller(MException('MATLAB:matrix:indexExceedsDims',getString(message('MATLAB:matrix:indexExceedsDimsPositionSize',find(pos,1),range))));
            end
        else
            throwAsCaller(MException('MATLAB:matrix:indexExceedsDims',getString(message('MATLAB:matrix:indexExceedsDims'))));
        end
    end

end