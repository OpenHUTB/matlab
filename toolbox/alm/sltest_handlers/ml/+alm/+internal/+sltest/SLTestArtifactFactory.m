classdef SLTestArtifactFactory<alm.internal.AbstractArtifactFactory





    methods

        function h=SLTestArtifactFactory(metaData,storage,g)
            h=h@alm.internal.AbstractArtifactFactory(metaData,storage,g);
        end



        function type=getSelfContainedType(h,address)

            type="";

            if endsWith(address,".mldatx")

                absoluteAddress=h.StorageHandler.getAbsoluteAddress(address);

                description=...
                matlabshared.mldatx.internal.getDescription(absoluteAddress);

                if description=="Simulink Test Definition"
                    type="sl_test_file";
                end

            end

        end



        function das=getDirtyArtifacts(~)
            das=alm.internal.AddressAndType.empty(0,0);
            testFiles=sltest.testmanager.getTestFiles();
            for i=1:length(testFiles)
                if testFiles(i).Dirty
                    a=alm.internal.AddressAndType;
                    a.Type='sl_test_file';
                    a.Address=testFiles(i).FilePath;
                    a.ParentType='';
                    a.ParentAddress='';
                    das=[das,a];%#ok<AGROW>
                end
            end
        end
    end
end
