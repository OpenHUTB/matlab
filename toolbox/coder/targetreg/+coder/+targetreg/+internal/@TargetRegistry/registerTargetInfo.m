function registered=registerTargetInfo(h,targetInfo,mode,requestedClass)

    if nargin<3
        mode='check';
    end

    if nargin<4
        requestedClass='';
    end

    supportedClasses={'RTW.TflRegistry',...
    'rtw.connectivity.ConfigRegistry',...
    'coder.make.ToolchainInfoRegistry',...
    'function_handle'};
    if~any(strcmp(class(targetInfo),supportedClasses))
        msg=('coder_target_registry:messages:InvalidRegistryClass');
        exc=MException(msg.Identifier,string(msg));
        throw(exc);
    end

    registered=true;

    if~isempty(requestedClass)
        if~isa(targetInfo,requestedClass)

            registered=false;
            return;
        end
    end


    if isa(targetInfo,'RTW.TflRegistry')
        coder.internal.addTargetFunctionLibrary(h,targetInfo,mode);
    elseif isa(targetInfo,'rtw.connectivity.ConfigRegistry')
        coder.internal.addConnectivityConfig(h,targetInfo);
    elseif isa(targetInfo,'coder.make.ToolchainInfoRegistry')
        coder.make.internal.addToolchainInfo(h,targetInfo);
    elseif isa(targetInfo,'function_handle')
        h.addFunctionHandle(targetInfo);
    end
