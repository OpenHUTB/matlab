function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2CxpDD0QAVHCeFq0m0HvHVuwHrSI59qXe6SHP6UEZEktuEdeLC484s902l+'...
        ,'naL/O9JPIj+OWnwjIXzn7dBeRHL6DjLtxO7LCAAEl55MHBvDQpAXCU0qFGct'...
        ,'gjKGx95lgNEfS8FXyA9qLLa3zn0VIqo3awayc7ZaOrfhPY6jI/CaqovHJv4b'...
        ,'3IZ0C/PU9Qp+NT2IwYYDRQKPbsBeHT2SxCSSz07fWyaCUrx9LbPYbkcYAgzF'];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end