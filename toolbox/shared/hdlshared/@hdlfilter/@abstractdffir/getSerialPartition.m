function varargout=getSerialPartition(this,varargin)





    if nargout>0
        [sp,ff,mul]=this.getFIRSerialPartition(varargin{:});
        varargout={sp,ff,mul};
    else
        this.getFIRSerialPartition(varargin{:});
    end



