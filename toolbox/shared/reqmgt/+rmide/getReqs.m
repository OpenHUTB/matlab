function reqs=getReqs(varargin)




    if nargin==2

        if startsWith(varargin{2},'UUID_')

            dFile=varargin{1};
            id=varargin{2};
        else
            dictName=varargin{1};
            if~any(dictName=='.')
                dictName=[dictName,'.sldd'];
            end
            scopeAndLabel=varargin{2};
            if~any(scopeAndLabel=='.')

                scopeAndLabel=['Global.',scopeAndLabel];
            end
            [id,dFile]=rmide.getGuid([dictName,'|',scopeAndLabel]);
        end
    else

        ddEntry=varargin{1};
        if ischar(ddEntry)&&contains(ddEntry,'|UUID_')
            [dFile,rest]=strtok(ddEntry,'|');
            id=rest(2:end);
        else
            [id,dFile]=rmide.getGuid(varargin{1});
        end
    end

    if isempty(id)
        reqs=[];
    else









        if slreq.hasData(dFile)||slreq.utils.loadLinkSet(dFile)
            reqs=slreq.getReqs(dFile,id,'linktype_rmi_data');
        else
            reqs=[];
        end
    end

    if nargin==3

        reqs=rmi.filterReqs(reqs,varargin{2:end});
    end
end



