














function initialize(this,rootCompId,varargin)

    if nargin>1
        rootCompId=convertStringsToChars(rootCompId);
    end

    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    this.RootCompId=rootCompId;
    this.NodeIDMap=containers.Map('KeyType','char','ValueType','any');
    this.TaskIDMap=containers.Map('KeyType','char','ValueType','any');


    if~isempty(varargin)
        this.setConfigFilePath(varargin{1});
    else
        this.setConfigFilePath('');
    end

    this.IsInitialized=true;
end