








function phychdata=FddPCCPCHFormat(varargin)

    if isempty(varargin{2})
        phychdata=[];
        return
    end
    phychdata=transpose(fdd(['FddPCCPCHFormat',varargin]));

    if size(phychdata,1)~=1
        phychdata=transpose(phychdata);
    end

end
