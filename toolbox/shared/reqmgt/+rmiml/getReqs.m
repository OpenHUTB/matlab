function reqs=getReqs(varargin)




    [fPath,id]=rmiml.getBookmark(varargin{:});

    if isempty(id)
        reqs=[];
    elseif any(id=='-')


        reqs=[];
    else

        reqs=slreq.getReqs(fPath,id,'linktype_rmi_matlab');
    end
end

