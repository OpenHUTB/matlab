function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2CxpDa0BgVPzNFuGq3wq6YLo1NvlpN7jmdPx6+mgYS35OKd/bKJLx4+rVCy'...
        ,'XDHHA7F3Nnz/yf5o4dSPeJkqbyzoZ8jA5vmX22BZBYFaxk3LtDWdh3BDKd8B'...
        ,'LwkDmQybTI/ge9RS/Pe7gAHkUImixsY0933EVC3RNBj3Rx+f+oPaZ9jLMuxm'...
        ,'tj05QZcC2txsiK8zYJtX7iF8PWVrwOVb244djvuqOtE36W9coflLSkwC5HIo'...
        ,'tuKWdDQ5LnZhsnAf5aqBcDaC3QwZWSg8MZeXfb7VKLvzNiqZI7ItYfqB6g=='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end