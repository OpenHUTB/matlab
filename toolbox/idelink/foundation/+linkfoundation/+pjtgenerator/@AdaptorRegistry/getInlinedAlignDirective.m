function resp=getInlinedAlignDirective(reg,AdaptorName,varargin)







    resp=reg.getAdaptorInfo(AdaptorName).InlinedAlignDirective(varargin{:});

end
