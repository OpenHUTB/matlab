function importProfilesAndCopyStereotypes(source,destination)













    import systemcomposer.internal.arch.internal.*;

    COMP_TO_REF=1;
    REF_TO_COMP=2;
    ARCH_TO_ARCH=3;

    if ishandle(source)&&ishandle(destination)
        srcModelHdl=bdroot(source);
        dstModelHdl=bdroot(destination);

        srcType=get_param(source,'Type');
        dstType=get_param(destination,'Type');


        srcM=get_param(srcModelHdl,'SystemComposerModel');


        profiles=srcM.Profiles;
        if isempty(profiles)
            return;
        end



        if strcmpi(srcType,'block')&&strcmpi(dstType,'block_diagram')
            mode=COMP_TO_REF;
            src=srcM.lookup('SimulinkHandle',get_param(source,'handle'));

        else
            assert(strcmpi(srcType,'block_diagram')&&strcmpi(dstType,'block'));
            mode=REF_TO_COMP;
            src=srcM.Architecture;
        end



        dstM=getOrCreateSystemComposerModel(dstModelHdl);
        if mode==COMP_TO_REF
            dst=dstM.Architecture;
        else
            assert(mode==REF_TO_COMP);
            dst=dstM.lookup('SimulinkHandle',get_param(destination,'handle'));
        end

    else
        mode=ARCH_TO_ARCH;
        srcM=get_param(source.modelName,'SystemComposerModel');


        profiles=srcM.Profiles;
        if isempty(profiles)
            return;
        end

        dstM=get_param(destination.modelName,'SystemComposerModel');
        src=srcM.lookup('UUID',source.UUID);
        dst=dstM.lookup('UUID',destination.UUID);
    end





    if(mode==COMP_TO_REF&&...
        strcmpi(get_param(dstModelHdl,'SimulinkSubdomain'),'Simulink'))

        srcArchPorts=src.Architecture.Ports;
        dstArchImpl=dstM.getImpl.getRootArchitecture;

        for idx=1:length(srcArchPorts)
            srcArchPort=srcArchPorts(idx);
            dstArchPortImpl=dstArchImpl.getPort(srcArchPort.Name);
            dstArchPort=systemcomposer.arch.ArchitecturePort(dstArchPortImpl);
            applyStereotypeAndCopyValues(srcArchPort,dstArchPort,dstM);
        end
    end


    applyStereotypeAndCopyValues(src,dst,dstM);

end
