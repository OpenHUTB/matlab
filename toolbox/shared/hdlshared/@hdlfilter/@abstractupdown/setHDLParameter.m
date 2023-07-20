function setHDLParameter(this,varargin)




    if(rem(nargin-1,2)~=0)
        error(message('HDLShared:hdlfilter:pvpairsmismatch'));
    end

    pvvalues=varargin;

    for n=1:2:length(pvvalues)
        set(this.HDLParameters.CLI,pvvalues{n},pvvalues{n+1});
    end


    this.Filters.setHDLParameter(varargin{:});
    if~isempty(this.NCO)
        this.NCO.setHDLParameter(varargin{:});
    end


