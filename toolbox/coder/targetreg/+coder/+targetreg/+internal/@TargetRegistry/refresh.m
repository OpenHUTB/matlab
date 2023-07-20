function refresh(h,requestedClass)









    assert(any(strcmp(requestedClass,...
    {'RTW.TflRegistry',...
    'rtw.connectivity.ConfigRegistry',...
    'coder.make.ToolchainInfoRegistry',...
    'coder.make.BuildConfigurationRegistry'})),...
    'Requested class must be one of expected classes')

    numFcns=length(h.TargetInfoFcns);

    if numFcns==0
        return;
    end

    fcns=h.TargetInfoFcns;
    h.TargetInfoFcns={};
    removeIdx=false(size(fcns));

    for idx_fcns=1:numFcns

        removeIdx(idx_fcns)=true;

        try
            anonymousFunction=fcns{idx_fcns};
            nOut=nargout(anonymousFunction);
        catch exc
            if strcmp(exc.identifier,'MATLAB:err_parse_cannot_access_previously_accessible_file')


                continue
            end
        end

        try
            if nOut==1
                TargetInfoArray=feval(anonymousFunction);
                mode='check';
            else
                [TargetInfoArray,mode]=feval(anonymousFunction);
            end
        catch me
            msg=message('coder_target_registry:messages:errEvalfcn',...
            func2str(anonymousFunction),functions(anonymousFunction).file,me.message);
            warning(msg);



            continue
        end

        registered=false(size(TargetInfoArray));
        for idx_objs=1:length(TargetInfoArray)
            try
                registered(idx_objs)=h.registerTargetInfo...
                (TargetInfoArray(idx_objs),mode,requestedClass);

            catch me
                registered(idx_objs)=true;

                msg=message('coder_target_registry:messages:registrationFailed',...
                functions(anonymousFunction).file,...
                me.message);


                warning('RTW:targetRegistry:registrationFailed','%s',string(msg));
            end
        end
        removeIdx(idx_fcns)=all(registered);

    end


    h.TargetInfoFcns=fcns(~removeIdx);

