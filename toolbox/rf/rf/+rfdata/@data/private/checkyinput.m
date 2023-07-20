function checkyinput(h,numformat,varargin)






    inputvars=reshape(varargin,2,[]);
    yparams=inputvars(1,1:end-1);
    paramslist=listparam(h);
    nyparams=numel(yparams);
    for ii=1:nyparams
        if~any(strcmpi(yparams{ii},paramslist))
            error(message('rf:rfdata:data:checkyinput:InvalidYParam',yparams{ii}));
        end
    end

    yformats=inputvars(2,1:end-1);
    nyformats=numel(yformats);
    for ii=1:nyformats
        yformats{ii}=modifyformat(h,yformats{ii});
    end

    uformats=unique(yformats);
    if numel(uformats)>numformat
        error(message('rf:rfdata:data:checkyinput:FormatsExceedLimit',numformat))
    end

    for ii=1:nyparams
        allformats=[listformat(h,yparams{ii});'None'];
        if~any(strcmpi(yformats{ii},allformats))
            error(message('rf:rfdata:data:checkyinput:InvalidYFormat',yformats{ii},yparams{ii}));
        end
    end