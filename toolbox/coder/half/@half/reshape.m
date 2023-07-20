

















function obj=reshape(this,varargin)
    narginchk(2,intmax);

    s=varargin;
    for ii=1:length(s)
        if isa(s{ii},'half')
            s{ii}=double(s{ii});
        end
    end

    if isa(this,'half')
        obj=reshape@uint16(this,s{:});
    else

        obj=reshape(this,s{:});
    end
end
