function out=any(varargin)






    narginchk(1,2);

    s=varargin;

    for ii=1:nargin
        if isa(s{ii},'half')
            s{ii}=single(s{ii});
        end
    end

    out=any(s{:});
end
