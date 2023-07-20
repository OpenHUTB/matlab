function varargout=getSerialPartition(this,varargin)




    if nargout>0
        if nargout<=3
            [ff,mul,il]=this.getFIRSerialPartition(varargin{:});
            varargout={ff,mul,il};
        else
            error(message('HDLShared:hdlfilter:wrongnumoutputargs'));
        end
    else
        this.getFIRSerialPartition(varargin{:});
    end
