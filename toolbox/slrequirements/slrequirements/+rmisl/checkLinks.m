function varargout=checkLinks(obj,varargin)




    if nargout>1
        varargout{2}='';
    end

    reqs=reqsToCheck(obj,varargin{2:end});

    modelH=rmisl.getmodelh(obj);

    switch lower(varargin{1})

    case 'doc'
        for i=1:length(reqs)
            status(i)=rmicheck.checkDoc(reqs(i).reqsys,reqs(i).doc,modelH);%#ok<*AGROW>
            varargout{1}=status;
        end

    case 'id'
        for i=1:length(reqs)
            status(i)=rmicheck.checkId(reqs(i).reqsys,reqs(i).doc,reqs(i).id,modelH);
            varargout{1}=status;
        end

    case 'description'
        desc={};
        for i=1:length(reqs)
            [status(i),desc{i}]=rmicheck.checkDesc(reqs(i),modelH);
        end
        varargout{1}=status;
        varargout{2}=desc;

    case 'pathtype'
        new_path={};
        for i=1:length(reqs)
            [status(i),new_path{i}]=rmicheck.checkPath(reqs(i).reqsys,reqs(i).doc,modelH);
        end
        varargout{1}=status;
        varargout{2}=new_path;

    otherwise
        error(message('Slvnv:reqmgt:rmi:UnknownCheck'));
    end
end

function reqs=reqsToCheck(obj,index)
    reqs=rmi.getReqs(obj);
    if nargin>1




        if ceil(obj)~=obj&&obj~=bdroot(obj)
            try
                linkStatus=get_param(obj,'StaticLinkStatus');
                if any(strcmp(linkStatus,{'resolved','implicit'}))
                    libReqs=rmi.getReqs(obj,true);
                    reqs=[reqs;libReqs];
                end
            catch ME %#ok<NASGU>

            end
        end
        reqs=reqs(index);
    else

    end
end

