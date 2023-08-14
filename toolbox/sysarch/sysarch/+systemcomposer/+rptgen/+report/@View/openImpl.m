function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2CRpMzwAAVPzNGax6+EsHWGp+4s2oKK6ZPgxqCBvjwoNoaTi9g5V9uf8l2x'...
        ,'K8CC0RGbqSshO9rT+eejixW8HpYUDkclIQWztw0t95Qjlnw+9sUwp0lv1+35'...
        ,'3nRhyIixXD7ov9jh4vEHqW79Yxs50b+3VaGf9PclzSNT1DytVwnV9pYdLK52'...
        ,'sMAqB6ySGlCjyTYGQwDGI1Lt5Q6Ouw=='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end