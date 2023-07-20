function result=codegenReq(obj,varargin)






    if ischar(obj)&&any(obj=='|')

        source=strtok(obj,'|');
        if rmisl.isSidString(source)||exist(source,'file')==2
            reqs=rmiml.getReqs(obj);
            result=filterIdx(reqs,varargin{:});
            return;
        else

        end
    end

    [modelH,objH,isSf,isSigBuilder]=rmisl.resolveObj(obj);
    allReqs=rmi.getReqs(objH);
    if~isSf&&objH~=modelH&&~isSigBuilder

        if any(strcmp(get_param(objH,'StaticLinkStatus'),{'resolved','implicit'}))
            libObj=get_param(objH,'ReferenceBlock');
            libMdl=strtok(libObj,'/');
            if~rmiut.isBuiltinNoRmi(libMdl)
                load_system(libMdl);
                libReqs=rmi.getReqs(libObj);
                allReqs=[allReqs;libReqs];
            end
        end

        if~isempty(get_param(bdroot(objH),'DataDictionary'))
            ddReqs=rmide.getVarReqsForObj(objH);
            if~isempty(ddReqs)
                allReqs=[allReqs;ddReqs];
            end
        end
    end
    result=filterIdx(allReqs,varargin{:});
end

function req=filterIdx(reqs,idx)
    if nargin>1&&isnumeric(idx)
        if idx<=length(reqs)
            req=reqs(idx);
        else
            req=[];
        end
    else
        req=reqs;
    end
end
