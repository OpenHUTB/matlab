function E=createValidatorException(errorID,varargin)
    messageObject=message(errorID,varargin{1:end});
    E=MException(errorID,messageObject.getString);
end
