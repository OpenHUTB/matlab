function validateYRange(this,val)
    numPlots=this.Rows*this.Columns;
    if length(val)~=numPlots
        throw(createValidatorException('SDI:sdi:InvalidCustomYRange',numPlots));
    end
    for idx=1:numPlots
        Simulink.sdi.CustomSnapshot.mustBeValidRange(val{idx});
    end
end


function E=createValidatorException(errorID,varargin)
    messageObject=message(errorID,varargin{1:end});
    E=MException(errorID,messageObject.getString);
end
