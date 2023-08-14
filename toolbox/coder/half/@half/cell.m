function obj=cell(varargin)




    if nargin==0
        varargin={1};
    else
        for ii=1:nargin
            if isa(varargin{ii},'half')
                varargin{ii}=double(varargin{ii});
            end
        end
    end

    obj=cell(varargin{:});
end
