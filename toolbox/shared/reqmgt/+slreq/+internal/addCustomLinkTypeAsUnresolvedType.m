function varargout=addCustomLinkTypeAsUnresolvedType(typeName)






    reqData=slreq.data.ReqData.getInstance();
    [varargout{1:nargout}]=reqData.addCustomLinkType(typeName,'Unset',...
    getString(message('Slvnv:slreq:UnresolvedType',typeName)),...
    getString(message('Slvnv:slreq:UnresolvedType',typeName)),'');
end
