


classdef SLTestResolver<alm.internal.AbstractArtifactResolver

    properties
        AbsoluteFileAddress string;
    end

    methods

        function h=SLTestResolver(metaData,container,g,loader)
            h=h@alm.internal.AbstractArtifactResolver(metaData,container,g,loader);
        end



        function postCreate(h)
            h.AbsoluteFileAddress=...
            fullfile(h.StorageHandler.getAbsoluteAddress(h.SelfContainedArtifact.Address));
        end




        function address=convertAddressSpace(~,slot,addressIndex)


            address=string(slot.ContainedAddresses(addressIndex));
        end



        function redirectedArtifact=redirectAddress(h,...
            convertedAddress,~,~)

            licPrev=alm.internal.sltest.SLTestLicenseCheckoutOverride();%#ok<NASGU> % RAII

            h.Loader.load(h.MainArtifact,h.Graph);











            redirectedArtifact=alm.Artifact.empty(0,1);



            assessmentUuid=extractBefore(convertedAddress,":");
            assNum=str2double(extractAfter(convertedAddress,":"));

            if~alm.internal.uuid.isUuid(assessmentUuid)||...
                isempty(assNum)||isnan(assNum)
                return;
            end





            assId=stm.internal.getTestIdFromUUIDAndTestFile(...
            convertedAddress,h.AbsoluteFileAddress);

            if assId==0
                return;
            end

            tcId=stm.internal.getAssessmentsTestCaseID(assId);

            if tcId==0
                return;
            end

            tcObj=sltest.testmanager.TestCase([],tcId);

            if~isvalid(tcObj)
                return;
            end

            tcUuid=tcObj.UUID;






            assNums=[];
            assInfo=stm.internal.getAssessmentsInfo(assId);

            if~isempty(assInfo)
                assInfo=jsondecode(assInfo);
                if isfield(assInfo,'AssessmentsInfo')
                    assInfo=assInfo.AssessmentsInfo;

                    for jAss=1:numel(assInfo)
                        if isfield(assInfo{jAss},'id')
                            assNums(end+1)=assInfo{jAss}.id;%#ok<AGROW>
                        end
                    end
                end
            end




            if any(ismember(assNums,assNum))
                redirectedArtifact=h.Graph.getArtifactByAddress(h.Storage.CustomId,...
                h.MainArtifact.Address,string(tcUuid));
            end
        end
    end
end
