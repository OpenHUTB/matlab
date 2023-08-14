function paths=find(this,rootPath,category,varargin)



















    if nargin>1
        rootPath=convertStringsToChars(rootPath);
    end

    if nargin>2
        category=convertStringsToChars(category);
    end

    if nargin>3
        [varargin{:}]=convertStringsToChars(varargin{:});
    end
    p_update_read(this);


    paths=autosar.api.getAUTOSARProperties.find_impl(this.arModel,rootPath,category,[],varargin{:});

