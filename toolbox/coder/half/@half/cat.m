

























function obj=cat(dim,varargin)
    narginchk(1,intmax);

    if isa(dim,'half')
        obj=cat(double(dim),varargin{1:(nargin-1)});
    else
        halfOutput=true;

        for ii=1:(nargin-1)
            if~(isfloat(varargin{ii})||islogical(varargin{ii}))
                halfOutput=false;
            end
        end

        if(halfOutput)
            obj=cat@uint16(dim,varargin{1:(nargin-1)});
        else
            s=varargin;

            for ii=1:(nargin-1)
                if isa(s{ii},'half')
                    s{ii}=single(s{ii});
                end
            end

            obj=cat(dim,s{:});
        end
    end
end
