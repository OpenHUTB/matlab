function out=getInstanceID(this,varargin)
    try
        if length(varargin)==1
            out=this.sigRepository.getInstanceID(varargin{1});
        else
            out=0;
        end
    catch
        out=0;
    end
end