function varargout=safeTransaction(this,func,varargin)






    notify(this,'transactionBegin',Simulink.sdi.internal.SDIEvent('transactionBegin'));


    numArgs=nargout(func);
    varargout=cell(1,numArgs);
    [varargout{:}]=this.sigRepository.safeTransaction(func,varargin{:});
    notify(this,'transactionEnd',Simulink.sdi.internal.SDIEvent('transactionEnd'));

end

