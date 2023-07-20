function this=StylesheetEditor(varargin)












    this=feval(mfilename('class'));

    if~isempty(varargin)
        registryLoad(this,varargin{:});
    end

