function result=getReqs(varargin)







    if slreq.data.ReqData.exists()
        links=slreq.utils.getLinks(varargin{:});
        if isempty(links)
            result=[];
        else
            result=slreq.utils.linkToStruct(links);
        end
    else

        result=[];
    end

end

