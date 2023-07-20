function fcnIntList=getFunctionInterfaces(libModel,subsys)





    fcnIntList=[];
    subsysHdl=get_param(subsys,'Handle');


    if Simulink.harness.internal.isRLS(subsysHdl)
        fcnIntList=Simulink.libcodegen.internal.getBlockCodeContexts(libModel,subsysHdl);
        fcnIntList={fcnIntList.name};
    end

end

