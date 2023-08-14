














function out=FddDLChannel(data,modulation,sf,sprdcodes,scrmcode,varargin)

    if isempty(data)
        out=[];
        return;
    end
    if nargin<6
        scramoffset=0;
    else
        scramoffset=varargin{1};
    end

    md=FddDLModulation(data,modulation)/sqrt(2);

    sd=FddSpreading(md,sf*ones(1,length(sprdcodes),class(sf)),sprdcodes,1);
    if~isvector(sd)
        sd=sum(sd,2);
    end

    out=FddScrambling(sd,1,scrmcode,scramoffset)/sqrt(2);


    out=circshift(out(:),scramoffset);

end
