function resp=getPragmaSectionDirective(reg,AdaptorName,varargin)





    resp=reg.getAdaptorInfo(AdaptorName).PragmaSectionDirective(varargin{:});

end
