function varargout=addCustomReqType(varargin)
    reqData=slreq.data.ReqData.getInstance();
    [varargout{1:nargout}]=reqData.addCustomRequirementType(varargin{:});
end
