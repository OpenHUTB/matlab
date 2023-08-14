function str=message(key,varargin)







    key=['SimulinkXMLComparison:',key];
    msg=message(key,varargin{:});
    str=msg.getString();
