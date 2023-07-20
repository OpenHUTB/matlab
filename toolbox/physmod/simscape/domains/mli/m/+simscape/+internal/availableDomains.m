function domains=availableDomains(varargin)




    ad=simscape.internal.AvailableDomains(varargin{:});
    in=ad();
    domains=sort(reshape({in.Path},[],1));
end
