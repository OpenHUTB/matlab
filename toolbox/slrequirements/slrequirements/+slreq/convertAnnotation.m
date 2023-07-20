
























function req=convertAnnotation(annotation,destination,varargin)

    req=slreq.Requirement.empty();
    rdata=slreq.data.ReqData.getInstance();
    if isa(destination,'slreq.Requirement')
        reqSet=destination.reqSet;
        dataReqSet=rdata.getReqSet(reqSet.Name);
        dest=dataReqSet.getItemFromID(destination.SID);
    elseif isa(destination,'slreq.ReqSet')
        dest=rdata.getReqSet(destination.Name);
    else
        error(message('Slvnv:slreq:AnnotationInvalidDest'))
    end

    opts=slreq.internal.AnnotationConversionHandler.Options;
    if nargin>2
        opts=handleOptions(opts,varargin);
    end

    [status,errMsg]=slreq.internal.AnnotationConversionHandler.checkCompatibility(annotation,opts);

    if~status
        exception=MException(errMsg.Identifier,getString(errMsg));
        throw(exception);
    end

    dataReq=slreq.internal.AnnotationConversionHandler.convert(annotation,dest,opts);
    for n=1:length(dataReq)
        req(end+1)=slreq.Requirement(dataReq(n));%#ok<AGROW>
    end
end

function opts=handleOptions(opts,args)

    availableOptions=fieldnames(opts);

    for n=1:2:numel(args)
        param=args{n};
        value=args{n+1};

        if~any(strcmp(param,availableOptions))
            error(message('Slvnv:slreq:AnnotationNoSuchAPIOption',param,mfilename));
        end
        try
            opts.(param)=value;
        catch ME
            error(message('Slvnv:slreq:AnnotationInvalidOptionValue',param));
        end
    end
end
