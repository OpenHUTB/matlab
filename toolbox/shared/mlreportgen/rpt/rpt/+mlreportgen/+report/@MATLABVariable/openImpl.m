function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2CxokCQAQVPiOBmYraMb45ZdzUqJNE0AMkdZMptciPn3mAxhEwdZ42tAsFA'...
        ,'jkaXRhiDM1JDqcRlVvHRbxSywFns0pwxw6YTRt9NgUak2X/x0cAFqXzNkPY5'...
        ,'hIzGH/D+yyJx342ve7VNxT3Zjm0B8ujlt07HFEkwHn5iU6xcEx1eQUe5m66k'...
        ,'3WgQi1QbGCqDdTAif4bLyXaCEOY4I7AZcpHAvvxak6wDDV02U7InNY3qLE7a'...
        ,'tTOzkJVI5fQTF0Q7guA9KdkFaOTlk3+3jqQEE5R1aKdc2ESeoixavwzHB3ve'...
        ,'/gL+sleDVh667A=='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end