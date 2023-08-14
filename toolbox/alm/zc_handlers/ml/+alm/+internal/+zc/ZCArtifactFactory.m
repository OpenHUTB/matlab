classdef ZCArtifactFactory<alm.internal.AbstractArtifactFactory




    methods

        function h=ZCArtifactFactory(metaData,storage,g)
            h=h@alm.internal.AbstractArtifactFactory(metaData,storage,g);
        end



        function type=getSelfContainedType(h,address)

            type="";

            absolutPath=h.StorageHandler.getAbsoluteAddress(address);
            [~,modelName,~]=fileparts(absolutPath);


            if~isempty(modelName)
                mdlInfo=Simulink.MDLInfo(absolutPath);
                if~isempty(mdlInfo.Interface)
                    mdlType=mdlInfo.Interface.SimulinkSubDomainType;
                    if any(strcmp(mdlType,["AUTOSARArchitecture","SoftwareArchitecture","Architecture"]))
                        type="zc_file";
                    end
                end
            end

        end

    end
end
