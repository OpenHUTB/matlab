function out=getSignalCount(this,varargin)





    if(nargin==2)
        if this.isValidRunID(varargin{:})
            out=this.sigRepository.getSignalCount(varargin{:});
        else
            out=0;
        end
    else



        out=this.sigRepository.getSignalCountInEngine(this.instanceID);
    end
end