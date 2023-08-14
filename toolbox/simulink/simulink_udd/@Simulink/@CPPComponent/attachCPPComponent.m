function attachCPPComponent(hSrc)





    Simulink.CPPComponent.detachCPPComponent(hSrc);

    hConfig=hSrc.getConfigSet();

    if~isempty(hConfig)
        isERTTarget=strcmpi(hSrc.IsERTTarget,'on');

        aCopy=Simulink.CPPComponent;
        if(~isERTTarget)
            locDisableSetFunctions(aCopy);
        end
        hSrc.attachComponent(aCopy);


        aCopy.hasCachedValues='on';





        aCopy.cacheCodeInterfacePackaging=hSrc.CodeInterfacePackaging;




        aCopy.cacheGenerateAllocFcn=hSrc.GenerateAllocFcn;


        locForceSetParam(hSrc,'GenerateAllocFcn',0);

        aCopy.cacheGRTInterface=hSrc.GRTInterface;
        hSrc.GRTInterface=0;
        aCopy.cacheCombineOutputUpdateFcns=hSrc.CombineOutputUpdateFcns;


        locForceSetParam(hSrc,'CombineOutputUpdateFcns',1);

        aCopy.cacheExtMode=hSrc.ExtMode;
        if~isa(hSrc,'slrealtime.SimulinkRealTimeTargetCC')
            hSrc.ExtMode=0;
        end
        aCopy.cacheGenerateASAP2=hSrc.GenerateASAP2;
        hSrc.GenerateASAP2=0;


        if(isERTTarget)
            aCopy=locSetERTParams(hSrc,hConfig,aCopy);
        end
    end
end





function cache=locSetERTParams(hSrc,hConfig,cache)

    rtwComp=hConfig.getComponent('Code Generation');
    codeAppComp=rtwComp.getComponent('Code Appearance');


    if~codertarget.target.isCoderTarget(hConfig)
        cache.cacheCustomFileTem=hSrc.ERTCustomFileTemplate;
        hSrc.ERTCustomFileTemplate='example_file_process.tlc';
    else
        cache.cacheCustomFileTem='';
    end

    cache.cacheRootIOFormat=hSrc.RootIOFormat;
    hSrc.RootIOFormat='Structure reference';

end


function locDisableSetFunctions(acomp)

    props=fieldnames(acomp);
    for i_p=1:numel(props)
        acomp.setPropEnabled(props{i_p},'Off');
    end

end


function locForceSetParam(hSrc,param,val)

    cacheEnabledState=hSrc.getPropEnabled(param);
    if~cacheEnabledState
        hSrc.setPropEnabled(param,'On');
    end
    hSrc.(param)=val;
    if~cacheEnabledState
        hSrc.setPropEnabled(param,'Off');
    end

end


