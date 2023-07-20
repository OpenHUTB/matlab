function result=countReqs(varargin)







    result=0;


    reqs=rmi.getReqs(varargin{:});

    if~isempty(reqs)
        result=length(reqs);
    end
end

