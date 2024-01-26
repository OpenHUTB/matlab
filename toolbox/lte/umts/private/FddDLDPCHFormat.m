function phychdata=FddDLDPCHFormat(nsft,data,varargin)

    if isempty(data)
        phychdata=[];
        return
    end
    if min(size(data))==1
        phychdata=fdd(['FddDLDPCHFormat',nsft,data,varargin]);
        tout=size(data,1)~=1;
    else
        phychdata=fdd(['FddDLDPCHFormat',nsft,data(:,1),varargin]);
        for i=2:size(data,2)
            phychdata(i,:)=fdd('FddDLDPCHFormat',nsft,data(:,i));
        end
        tout=1;
    end

    if tout
        phychdata=transpose(phychdata);
    end

end
