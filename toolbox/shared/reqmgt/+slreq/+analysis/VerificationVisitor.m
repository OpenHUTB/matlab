classdef VerificationVisitor<slreq.analysis.AbstractVisitor



    properties
        name='Verification';
    end

    methods
        function visitRequirementSet(this,reqSet)

            reqSet.selfStatus.Verification=slreq.analysis.Status.None;
            this.sumChildren(reqSet,this.name);
        end

        function visitRequirement(this,dataReq)



            if dataReq.selfStatus.Verification==slreq.analysis.Status.Justification
                return;
            end

            resultsManager=slreq.data.ResultManager.getInstance();

            dataReq=this.sumChildren(dataReq,this.name);
            if slreq.app.RequirementTypeManager.isa(dataReq.typeName,slreq.custom.RequirementType.Functional,dataReq.getReqSet)

                if dataReq.selfStatus.Verification==slreq.analysis.Status.Justified
                    dataReq.incrementStatus(this.name,'justified');
                else
                    verifLinks=dataReq.getLinks(slreq.custom.LinkType.Verify);
                    if reqmgt('rmiFeature','ExtVerif')
                        [~,externalVerifLinks]=dataReq.getLinks(slreq.custom.LinkType.Confirm);
                        verifLinks=[verifLinks,externalVerifLinks];
                    end
                    if isempty(verifLinks)
                        dataReq.selfStatus.Verification=slreq.analysis.Status.None;
                        dataReq.incrementStatus(this.name,'none');
                    else
                        singleStatus=slreq.verification.ResultStatus.Unknown;



                        for n=1:length(verifLinks)
                            thisResult=resultsManager.getResult(verifLinks(n));
                            if thisResult==slreq.verification.ResultStatus.Fail

                                singleStatus=thisResult;

                                break;
                            end
                            if n==1
                                singleStatus=thisResult;
                            else



                                if singleStatus~=thisResult
                                    singleStatus=slreq.verification.ResultStatus.Unknown;
                                end
                            end
                        end

                        switch singleStatus
                        case slreq.verification.ResultStatus.Pass
                            dataReq.selfStatus.Verification=slreq.analysis.Status.Pass;
                            dataReq.incrementStatus(this.name,'passed');
                        case slreq.verification.ResultStatus.Fail
                            dataReq.selfStatus.Verification=slreq.analysis.Status.Fail;
                            dataReq.incrementStatus(this.name,'failed');
                        case{slreq.verification.ResultStatus.Stale,slreq.verification.ResultStatus.Unknown}
                            dataReq.selfStatus.Verification=slreq.analysis.Status.Unexecuted;
                            dataReq.incrementStatus(this.name,'unexecuted');
                        otherwise
                            assert(false,'Unknown result status');
                        end
                    end
                end
                dataReq.incrementStatus(this.name,'total');

            elseif slreq.app.RequirementTypeManager.isa(dataReq.typeName,slreq.custom.RequirementType.Container,dataReq.getReqSet)


                dataReq.selfStatus.Verification=slreq.analysis.Status.Container;
            else


            end
        end

        function visitRequirementAncestors(this,dataReq)







            cParent=dataReq.parent;
            while~isempty(cParent)



                cParent.status.Verification=cParent.verifStatus;
                this.visitRequirement(cParent);
                cParent=cParent.parent;
            end


            reqSet=dataReq.getReqSet;
            reqSet.initVerificationStatus();
            this.visitRequirementSet(reqSet);
        end

    end

    methods(Static)
        function name=getName()
            name='Verification';
        end

        function item=sumChildren(item,name)

            children=item.children;
            for n=1:length(children)
                ch=children(n);
                item.addStatus(name,'total',ch.getStatus(name,'total'));
                item.addStatus(name,'passed',ch.getStatus(name,'passed'));
                item.addStatus(name,'justified',ch.getStatus(name,'justified'));
                item.addStatus(name,'failed',ch.getStatus(name,'failed'));
                item.addStatus(name,'unexecuted',ch.getStatus(name,'unexecuted'));
                item.addStatus(name,'none',ch.getStatus(name,'none'));
            end
        end
    end
end

