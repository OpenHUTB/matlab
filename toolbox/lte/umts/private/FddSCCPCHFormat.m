


















function phychdata=FddSCCPCHFormat(varargin)

    if isempty(varargin{2})
        phychdata=[];
        return
    end
    phychdata=transpose(fdd(['FddSCCPCHFormat',varargin]));

    if size(phychdata,1)~=1
        phychdata=transpose(phychdata);
    end

end
