classdef SLTestResultArtifactFactory<alm.internal.AbstractArtifactFactory

    methods

        function h=SLTestResultArtifactFactory(metaData,storage,g)
            h=h@alm.internal.AbstractArtifactFactory(metaData,storage,g);
        end



        function type=getSelfContainedType(h,address)

            type="";

            if endsWith(address,".mldatx")
                absoluteAddress=h.StorageHandler.getAbsoluteAddress(address);

                description=...
                matlabshared.mldatx.internal.getDescription(absoluteAddress);

                if description=="Simulink Test Results"
                    type="sl_test_result_file";
                end
            elseif endsWith(address,".sltsrf")
                type="sl_test_session_result_file";
            end

        end
    end
end
