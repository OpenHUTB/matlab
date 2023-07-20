function refresh(this,varargin)




    mdlObj=getParent(this);
    if~isempty(mdlObj)
        this.ModelName=mdlObj.name;
        this.ModelHandle=get_param(this.ModelName,'Handle');
        this.DisplayName=this.ModelName;
    end
    this.load(varargin{:});

