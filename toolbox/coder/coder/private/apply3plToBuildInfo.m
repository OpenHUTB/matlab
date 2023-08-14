function apply3plToBuildInfo(buildInfo,configInfo,bldDir,tplUseClassNames)



    function fail(ME,method)
        msgID='Coder:buildProcess:invalidExternalDependency';
        x=coderprivate.msgSafeException(msgID,method);
        x=x.addCause(coderprivate.makeCause(ME));
        x=MException(x.identifier,'%s',x.getReport());
        x.throwAsCaller();
    end

    function apply(tplUseClassName)
        context=generateBuildConfig(configInfo,bldDir);

        method=[tplUseClassName,'.isSupportedContext'];
        try
            isSupportedContext=feval(method,context);
        catch ME
            fail(ME,method);
        end
        if~isSupportedContext
            msgId='Coder:buildProcess:unsupportedExternalDependency';
            method=[tplUseClassName,'.getDescriptiveName'];
            try
                descriptiveName=feval(method,context);
            catch ME
                fail(ME,method);
            end
            error(message(msgId,descriptiveName));
        end

        method=[tplUseClassName,'.updateBuildInfo'];
        try
            feval(method,buildInfo,context);
        catch ME
            fail(ME,method);
        end
    end

    for i=1:numel(tplUseClassNames)
        apply(tplUseClassNames{i});
    end
end
