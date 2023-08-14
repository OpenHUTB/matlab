function newException=solverErrorFcn(blockHandle,~,originalException)









    blockPath=pmsl_sanitizename(getfullname(blockHandle));


    containedBlocks=find_system(blockHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on');
    newException=recreateException(blockHandle,blockPath,containedBlocks,originalException);

end


function handles=adjustBlockHandles(handles,top,contained)




    handles(ismember(handles,contained))=top;
end


function str=adjustBlockReferences(str,topBlockPath)


    pat=['''',topBlockPath,'/([^'']*)'''];
    rep=['''',topBlockPath,''''];
    str=regexprep(str,pat,rep);


    pat=['>',topBlockPath,'/([^<]*)<'];
    rep=['>',topBlockPath,'<'];
    str=regexprep(str,pat,rep);
end


function[errid,errmsg]=adjustErrorIdAndMessage(errid,errmsg,topBlockPath)


    switch errid

    case 'Simulink:blocks:BlockDoesNotSupportRowMajor'

        err=pm_errorstruct('physmod:simscape:engine:sli:error:NoSupportForRowMajorCodeGeneration',...
        topBlockPath);
        errid=err.identifier;
        errmsg=err.message;

    otherwise

    end
end


function newEx=recreateException(topBlockHandle,topBlockPath,containedHandles,oldEx)

    hh=adjustBlockHandles([oldEx.handles{:}],topBlockHandle,containedHandles);

    [errid,errmsg]=adjustErrorIdAndMessage(oldEx.identifier,oldEx.message,topBlockPath);

    errmsg=adjustBlockReferences(errmsg,topBlockPath);


    newEx=recreateTopException(oldEx,errid,errmsg,hh);


    causes=[oldEx.cause{:}];
    for i=1:length(causes)
        newEx=newEx.addCause(...
        recreateException(topBlockHandle,topBlockPath,containedHandles,causes(i)));
    end
end
