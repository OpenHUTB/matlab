function localizedError(id,varargin)


    for i=1:nargin-1
        if ischar(varargin{i})||isstring(varargin{i})
            varargin{i}=strrep(varargin{i},'\','\\');
        end
    end
    MException(id,getString(message(id,varargin{:}))).throwAsCaller;
end

