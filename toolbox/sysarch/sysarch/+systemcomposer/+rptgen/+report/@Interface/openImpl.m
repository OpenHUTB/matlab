function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2CRpDz0ABVPjNBuum+sDcI6JN8GEe2IU8heN6l3ZDaKgAwKDT0+cVvYB7es'...
        ,'SG+rO1kYUqeSSFJhvHHD3gurzaOsGjB8ZqDeyoLaAKpqWMIg2HVfGWrXivS8'...
        ,'L1IdyMSwJz7AZz+XKxZinVN5ThiOErlvONmZMPbMvpPZhUC6hg+mOLXxRl34'...
        ,'MsMM3K+dCPZ0zGw+ghfj7fPxaGhhtw=='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end