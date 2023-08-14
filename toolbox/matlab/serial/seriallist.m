function ports=seriallist(varargin)




















    instrument.internal.ICTRemoveFunctionalityHelper("seriallist","Warn","Function");
    ports=serialportlist(varargin{:});
end
