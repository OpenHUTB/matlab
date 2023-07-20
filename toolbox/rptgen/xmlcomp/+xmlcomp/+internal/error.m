function error(key,varargin)









    key=['XMLComparison:',key];
    msgObj=message(key,varargin{:});

    exception=MException(msgObj);
    exception.throwAsCaller;
