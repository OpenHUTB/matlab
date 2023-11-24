classdef SLTestArtifactHandler<alm.internal.AbstractArtifactHandler

    properties
        AbsoluteFileAddress string;
    end

    methods

        function h=SLTestArtifactHandler(metaData,container,g)
            h=h@alm.internal.AbstractArtifactHandler(metaData,container,g);
        end



        function postCreate(h)
            h.AbsoluteFileAddress=...
            fullfile(h.StorageHandler.getAbsoluteAddress(h.SelfContainedArtifact.Address));
        end



        function analyze(h)


            licPrev=alm.internal.sltest.SLTestLicenseCheckoutOverride();%#ok<NASGU>             


            rscs=h.Loader.load(h.SelfContainedArtifact,h.Graph);%#ok<NASGU>


            tf=alm.internal.sltest.Utils.getTestFileObj(h.AbsoluteFileAddress);
            if isempty(tf)
                error(message('alm:handler_services:FileNotLoaded',h.SelfContainedArtifact.Address));
            end


            v=alm.internal.sltest.visitor.TestHandler(h);
            traverser=alm.internal.sltest.SLTestTraverser(v);
            traverser.run(tf);

            if feature('ALMSLTestSubfileChecksum')

                aa=h.Graph.getAllContained(...
                h.Graph.getContained(h.MainArtifact));
                aa_w_checksum=aa(arrayfun(@(a)a.Checksum~="",aa));

                if numel(aa)~=numel(aa_w_checksum)

                    h.notifyUser("warn",message(...
                    'alm:sltest_handlers:InconsistentRevisionState',...
                    alm.internal.createOpenArtifactHyperlink(h.MainArtifact),...
                    h.AbsoluteFileAddress));

                    for i=1:numel(aa_w_checksum)
                        aa_w_checksum(i).Checksum="";
                    end
                end

            end

        end



        function openFile(h)
            absoluteFilePath=fullfile(h.StorageHandler.getAbsoluteAddress(...
            h.SelfContainedArtifact.Address));
            tf=sltest.testmanager.load(absoluteFilePath);
            alm.internal.sltest.SLTestArtifactHandler.openBlocking(absoluteFilePath,tf.UUID);
        end



        function openElement(h)
            absoluteFilePath=fullfile(h.StorageHandler.getAbsoluteAddress(...
            h.SelfContainedArtifact.Address));
            alm.internal.sltest.SLTestArtifactHandler.openBlocking(absoluteFilePath,h.MainArtifact.Address);

        end

    end



    methods(Static,Access=private)

        function openBlocking(absoluteFilePath,uuid)

            function openSTM(varargin)
                message.unsubscribe(sub);
                stm.internal.openTestCase(absoluteFilePath,uuid);
            end

            if~sltest.testmanager.isOpen

                sub=message.subscribe('/stm/messaging/stmrendered',@openSTM);
                sltestmgr;
            else

                stm.internal.openTestCase(absoluteFilePath,uuid);
            end

        end

    end
end
