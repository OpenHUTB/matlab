function setHDLParameter(this,varargin)




    if(rem(nargin-1,2)~=0)
        error(message('HDLShared:hdlfilter:pvpairsmismatch'));
    end


    for n=1:2:nargin-1
        set(this.HDLParameters.CLI,varargin{n},varargin{n+1});
    end

    rxfilter=this.Rxchain;
    txfilter=this.TxChain;

    rxfilter.setHDLParameter(varargin{:});
    txfilter.setHDLParameter(varargin{:});
