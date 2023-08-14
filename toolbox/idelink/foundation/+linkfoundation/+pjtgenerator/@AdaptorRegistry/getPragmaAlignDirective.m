function resp=getPragmaAlignDirective(reg,AdaptorName,varargin)





    resp=reg.getAdaptorInfo(AdaptorName).PragmaAlignDirective(varargin{:});

end
