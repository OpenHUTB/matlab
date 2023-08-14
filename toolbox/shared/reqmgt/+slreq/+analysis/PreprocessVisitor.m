classdef PreprocessVisitor<slreq.analysis.AbstractVisitor






    properties
        name='PreprocessVisitor';
        isHierarchicallyJustifiedForImplementation=false;
        isHierarchicallyJustifiedForVerification=false;

        isInInformational=false;
    end

    properties(Access=private)
        analysisType='';
    end

    methods

        function setAnalysisForImplementation(this)
            this.analysisType='Implementation';
        end

        function setAnalysisForVerification(this)
            this.analysisType='Verification';
        end

        function visitRequirementSet(this,reqSet)
            this.initializeNode(reqSet);
        end

        function visitRequirement(this,dataReq)

            this.initializeNode(dataReq);

            if this.isInInformational

                dataReq.selfStatus.Implementation=slreq.analysis.Status.Excluded;
                dataReq.selfStatus.Verification=slreq.analysis.Status.Excluded;
                return;
            elseif dataReq.isJustification

                dataReq.selfStatus.Implementation=slreq.analysis.Status.Justification;
                dataReq.selfStatus.Verification=slreq.analysis.Status.Justification;
                return;
            end


            if slreq.app.RequirementTypeManager.isa(dataReq.typeName,slreq.custom.RequirementType.Informational,dataReq.getReqSet)...
                ||(~dataReq.isJustification&&slreq.app.RequirementTypeManager.isUnresolvedType(dataReq.typeName,dataReq.getReqSet))

                this.isInInformational=true;
                dataReq.selfStatus.Implementation=slreq.analysis.Status.Excluded;
                dataReq.selfStatus.Verification=slreq.analysis.Status.Excluded;
                return;
            end


            if this.isHierarchicallyJustifiedForImplementation


                dataReq.selfStatus.Implementation=slreq.analysis.Status.Justified;
            else
                [isJustfiedImpl,isHierJustifiedImpl]=dataReq.isJustifiedFor(slreq.custom.LinkType.Implement);
                if isHierJustifiedImpl
                    this.isHierarchicallyJustifiedForImplementation=true;
                end
                if isJustfiedImpl
                    dataReq.selfStatus.Implementation=slreq.analysis.Status.Justified;
                end
            end

            if this.isHierarchicallyJustifiedForVerification


                dataReq.selfStatus.Verification=slreq.analysis.Status.Justified;
            else
                [isJustfiedVerif,isHierarJustifiedVerif]=dataReq.isJustifiedFor(slreq.custom.LinkType.Verify);
                if isHierarJustifiedVerif
                    this.isHierarchicallyJustifiedForVerification=true;
                end
                if isJustfiedVerif
                    dataReq.selfStatus.Verification=slreq.analysis.Status.Justified;
                end
            end
        end

        function initializeNode(this,item)
            if strcmp(this.analysisType,'Implementation')
                item.initImplementationStatus();
            elseif strcmp(this.analysisType,'Verification')
                item.initVerificationStatus();
            end
        end
    end
end
