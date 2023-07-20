function out=getRunCount(this,varargin)
    if~isempty(varargin)
        appName=varargin{1};
        out=length(this.getAllRunIDs(appName));
    else
        out=this.sigRepository.getRunCount();
    end
end