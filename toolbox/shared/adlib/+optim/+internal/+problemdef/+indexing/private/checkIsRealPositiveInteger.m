function checkIsRealPositiveInteger(idxVec,varargin)










    if any(~isreal(idxVec(:)))||any(isinf(idxVec(:)))...
        ||any(floor(idxVec(:))~=idxVec(:))...
        ||any(idxVec(:)<1)
        if nargin>1
            pos=varargin{1};
            if isnumeric(pos)
                throwAsCaller(MException('shared_adlib:operators:BadSubscript',getString(message('shared_adlib:operators:BadSubscriptPosition',pos))));
            else
                throwAsCaller(MException('shared_adlib:operators:BadSubscript',getString(message('shared_adlib:operators:BadSubscriptPosition',find(pos,1)))));
            end
        else
            throwAsCaller(MException(message('shared_adlib:operators:BadSubscript')));
        end
    end