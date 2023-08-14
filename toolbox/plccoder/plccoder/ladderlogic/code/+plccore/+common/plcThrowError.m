function plcThrowError(err_id,varargin)




    import plccore.common.PLCCoreException;
    msg_obj=message(err_id,varargin{:});
    assert(~isempty(msg_obj));
    ex=PLCCoreException(err_id,msg_obj.getString);
    throw(ex);
end
