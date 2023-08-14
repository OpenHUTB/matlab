

























function obj=vertcat(varargin)
    halfOutput=true;

    for ii=1:nargin
        if~(isfloat(varargin{ii})||islogical(varargin{ii}))
            halfOutput=false;
        end
    end

    if(halfOutput)
        obj=vertcat@uint16(varargin{:});
    else
        s=varargin;

        for ii=1:nargin
            if isa(s{ii},'half')
                s{ii}=single(s{ii});
            end
        end

        obj=vertcat(s{:});
    end
end
