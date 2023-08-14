


























function obj=repmat(this,varargin)
    narginchk(2,intmax);

    s=varargin;
    for ii=1:length(s)
        if isa(s{ii},'half')
            s{ii}=double(s{ii});
        end
    end

    if isa(this,'half')
        obj=matlab.internal.builtinhelper.repmat(this,s{:});
    else

        obj=repmat(this,s{:});
    end
end
