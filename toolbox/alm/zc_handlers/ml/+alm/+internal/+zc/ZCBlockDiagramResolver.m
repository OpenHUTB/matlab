classdef ZCBlockDiagramResolver<alm.internal.AbstractArtifactResolver

    methods
        function h=ZCBlockDiagramResolver(metaData,artifact,g,loader)
            h=h@alm.internal.AbstractArtifactResolver(metaData,artifact,g,loader);

            if artifact.Type~=alm.internal.zc.ZCConstants.ZC_BLOCK_DIAGRAM
                error(message('alm:handler_services:UnsupportedType',artifact.Type));
            end

        end



        function convertedAddress=convertAddressSpace(h,slot,index)
            address=slot.ContainedAddresses(index);
            address=string(address{1});

            if isempty(address)
                convertedAddress="";
                return;
            end
            [~,modelname]=fileparts(h.MainArtifact.Address);
            a_bd=h.Graph.getArtifactByAddress(...
            h.Storage.CustomId,h.SelfContainedArtifact.Address,...
            string(modelname));
            if isempty(a_bd)
                return;
            end

            h.Loader.load(a_bd,h.Graph);

            if startsWith(address,"ZC:")
                address=erase(address,"ZC:");
            end
            archObj=systemcomposer.loadModel(modelname);
            if isempty(archObj)
                archObj=autosar.arch.loadModel(modelname);
            end


            if alm.internal.uuid.isUuid(address)
                obj=archObj.lookup("UUID",address);
                if~isempty(obj)
                    try
                        convertedAddress=erase(Simulink.ID.getSID(obj.SimulinkHandle),archObj.Name+":");
                        return;
                    catch
                        convertedAddress="";
                        return;
                    end
                else
                    convertedAddress="";
                    return;
                end
            end
            mgr=alm.internal.HandlerServiceManager.get();
            service=mgr.getService(alm.internal.zc.ZCConstants.SIMULINK_SERVICE_ID);
            resolver=service.createResolver(h.MainArtifact,h.Graph,h.Loader);
            convertedAddress=resolver.convertAddressSpace(slot,index-1);

        end



        function redirectedArtifact=redirectAddress(h,convertedAddress,slot,index)
            mgr=alm.internal.HandlerServiceManager.get();
            service=mgr.getService(alm.internal.zc.ZCConstants.SIMULINK_SERVICE_ID);
            resolver=service.createResolver(h.MainArtifact,h.Graph,h.Loader);

            redirectedArtifact=resolver.redirectAddress(convertedAddress,slot,index-1);
        end
    end
end
