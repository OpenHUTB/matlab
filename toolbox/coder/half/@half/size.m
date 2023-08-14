







































function[varargout]=size(this,varargin)
    narginchk(1,intmax);

    if(nargin==1)
        [varargout{1:nargout}]=size@uint16(this);
    else
        s=varargin;
        for ii=1:length(s)
            if isa(s{ii},'half')
                s{ii}=double(s{ii});
            end
        end

        if isa(this,'half')
            [varargout{1:nargout}]=size@uint16(this,s{:});
        else

            [varargout{1:nargout}]=size(this,s{:});
        end
    end
end
