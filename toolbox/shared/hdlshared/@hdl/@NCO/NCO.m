function this=NCO(varargin)










    this=hdl.NCO;

    indices=strncmpi(varargin,'source',6);
    pos=1:length(indices);
    pos=pos(indices);

    if~isempty(pos)
        srcobj=varargin{pos+1};
        parseNCOSrc(this,srcobj);

        varargin(pos)=[];
        varargin(pos)=[];
    end

    hdl.setpvpairs(this,varargin{:});













