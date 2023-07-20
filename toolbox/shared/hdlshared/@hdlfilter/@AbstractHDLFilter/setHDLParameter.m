function setHDLParameter(this,varargin)





    if(rem(nargin-1,2)~=0)
        error(message('HDLShared:hdlfilter:pvpairsmismatch'));
    end

    for n=1:2:nargin-1
        if isPropertyCascaded(this,varargin{n})&&iscell(varargin{n+1})
            error(message('HDLShared:hdlfilter:pvvaluesCantbeCell'));
        else
            set(this.HDLParameters.CLI,varargin{n},varargin{n+1});
        end
    end



