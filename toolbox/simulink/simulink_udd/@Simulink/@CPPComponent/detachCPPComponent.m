function detachCPPComponent(hSrc)




    hConfig=hSrc.getConfigSet();
    if~isempty(hConfig)&&~isempty(hSrc.getComponent('CPPClassGenComp'))
        theCppComponent=hSrc.detachComponent('CPPClassGenComp');

        isERTTarget=strcmpi(hSrc.IsERTTarget,'on');

        cCopy=theCppComponent;

        if strcmp(cCopy.hasCachedValues,'on')











            if isERTTarget&&~strcmpi(get_param(hConfig,'CodeInterfacePackaging'),'Nonreusable function')
                locForceSetParam(hSrc,'GenerateAllocFcn',cCopy.cacheGenerateAllocFcn);
            end

            hSrc.GRTInterface=cCopy.cacheGRTInterface;
            locForceSetParam(hSrc,'CombineOutputUpdateFcns',cCopy.cacheCombineOutputUpdateFcns);
            hSrc.IncludeMdlTerminateFcn=cCopy.cacheIncludeMdlTerminateFcn;

            hSrc.ExtMode=cCopy.cacheExtMode;
            hSrc.GenerateASAP2=cCopy.cacheGenerateASAP2;


            if(isERTTarget)
                locRestoreERTParams(hSrc,hConfig,cCopy);
            end
        end

        if slfeature('RTWCGStdArraySupport')&&isERTTarget
            hSrc.ArrayContainerType='C-style array';
        end
    end

end





function locRestoreERTParams(hSrc,hConfig,cache)

    if~isempty(cache.cacheCustomFileTem)
        hSrc.ERTCustomFileTemplate=cache.cacheCustomFileTem;
    end
    hSrc.RootIOFormat=cache.cacheRootIOFormat;

end


function locForceSetParam(hSrc,param,val)

    cacheEnabledState=hSrc.getPropEnabled(param);
    if~cacheEnabledState
        hSrc.setPropEnabled(param,'On');
    end

    hSrc.set_param(param,val);
    if~cacheEnabledState
        hSrc.setPropEnabled(param,'Off');
    end

end


