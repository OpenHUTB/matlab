function varargout=getSetConfigProp(mode,cfg,varargin)



    if strcmp(mode,'set')
        nargoutchk(0,0);
        narginchk(4,4);
        cfg.(varargin{1})=varargin{2};
    else
        nargoutchk(1,1);
        narginchk(3,3);
        varargout{1}=cfg.(varargin{1});
    end
