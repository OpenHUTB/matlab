function mustBeValidRange(val)
    if~isempty(val)
        if~isnumeric(val)||numel(val)~=2||val(1)>val(2)
            throw(createValidatorException('SDI:sdi:InvalidCustomRange'));
        end
    end
end


function E=createValidatorException(errorID,varargin)
    messageObject=message(errorID,varargin{1:end});
    E=MException(errorID,messageObject.getString);
end
