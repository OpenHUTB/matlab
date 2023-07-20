function reqs=getReqs(varargin)




    if nargin==2

        fiFile=varargin{1};
        id=varargin{2};
    else

        faEntry=varargin{1};
        if rmifa.containsFaultInfoFile(faEntry)
            [fiFile,rest]=strtok(faEntry,'|');
            id=rest(2:end);
        else
            obj=varargin{1};
            id=[':fault:',obj.Uuid];

            fiFile=obj.getTopModelName();
        end
    end

    if isempty(id)
        reqs=[];
    else
        reqs=slreq.getReqs(fiFile,id,'linktype_rmi_simulink');
    end

    if nargin==3

        reqs=rmi.filterReqs(reqs,varargin{2:end});
    end
end
