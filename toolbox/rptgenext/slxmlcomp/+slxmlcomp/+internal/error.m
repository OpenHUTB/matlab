function error(key,varargin)









    key=['SimulinkXMLComparison:',key];
    msg=message(key,varargin{:});
    exception=MException(msg);
    exception.throwAsCaller;
