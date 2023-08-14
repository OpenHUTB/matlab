function str=message(key,varargin)







    key=['XMLComparison:',key];
    msg=message(key,varargin{:});
    str=msg.getString();
