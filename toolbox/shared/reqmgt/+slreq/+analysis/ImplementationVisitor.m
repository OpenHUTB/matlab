classdef ImplementationVisitor<slreq.analysis.AbstractVisitor

    properties
        name='Implementation';
    end

    methods
        function visitRequirementSet(this,reqSet)

            reqSet.selfStatus.Implementation=slreq.analysis.Status.None;
            sumChildren(reqSet,this.name);
        end

        function visitRequirementAncestors(this,dataReq)







            cParent=dataReq.parent;
            while~isempty(cParent)



                cParent.status.Implementation=cParent.implStatus;
                this.visitRequirement(cParent);
                cParent=cParent.parent;
            end


            reqSet=dataReq.getReqSet;
            reqSet.initImplementationStatus();
            this.visitRequirementSet(reqSet);
        end


        function visitRequirement(this,dataReq)



            if dataReq.selfStatus.Implementation==slreq.analysis.Status.Justification
                return;
            end

            dataReq=sumChildren(dataReq,this.name);
            if slreq.app.RequirementTypeManager.isa(...
                dataReq.typeName,slreq.custom.RequirementType.Functional,dataReq.getReqSet)

                if dataReq.selfStatus.Implementation==slreq.analysis.Status.Justified
                    dataReq.incrementStatus(this.name,'justified');
                else

                    if reqmgt('rmiFeature','CustomRollup')

                        customAttributes=dataReq.getReqSet().CustomAttributeNames;
                        hasImplementationStatus=any(cellfun(@(x)strcmp(x,'ImplementationStatus'),customAttributes));

                        if(hasImplementationStatus)
                            customStatus=getAttribute(dataReq,'ImplementationStatus');


                            customStatus=lower(customStatus);
                            switch(customStatus)
                            case 'partially implemented'
                                dataReq.selfStatus.Implementation=slreq.analysis.Status.PartiallyImplemented;
                                dataReq.incrementStatus(this.name,'partiallyImplemented');
                            case 'just started'
                                dataReq.selfStatus.Implementation=slreq.analysis.Status.JustStarted;
                                dataReq.incrementStatus(this.name,'justStarted');
                            case 'almost done'
                                dataReq.selfStatus.Implementation=slreq.analysis.Status.AlmostDone;
                                dataReq.incrementStatus(this.name,'almostDone');
                            case 'not implemented'
                                dataReq.selfStatus.Implementation=slreq.analysis.Status.None;
                                dataReq.incrementStatus(this.name,'none');
                            case 'implemented'
                                dataReq.selfStatus.Implementation=slreq.analysis.Status.Implemented;
                                dataReq.incrementStatus(this.name,'implemented');
                            otherwise
                                implLinks=dataReq.getLinks(slreq.custom.LinkType.Implement);
                                if isempty(implLinks)
                                    dataReq.selfStatus.Implementation=slreq.analysis.Status.None;
                                    dataReq.incrementStatus(this.name,'none');
                                else
                                    dataReq.selfStatus.Implementation=slreq.analysis.Status.Implemented;
                                    dataReq.incrementStatus(this.name,'implemented');
                                end
                            end
                            dataReq.incrementStatus(this.name,'total');
                            return;
                        end
                    end
                    implLinks=dataReq.getLinks(slreq.custom.LinkType.Implement);
                    if isempty(implLinks)
                        dataReq.selfStatus.Implementation=slreq.analysis.Status.None;
                        dataReq.incrementStatus(this.name,'none');
                    else
                        dataReq.selfStatus.Implementation=slreq.analysis.Status.Implemented;
                        dataReq.incrementStatus(this.name,'implemented');
                    end
                end
                dataReq.incrementStatus(this.name,'total');
            elseif slreq.app.RequirementTypeManager.isa(dataReq.typeName,slreq.custom.RequirementType.Container,dataReq.getReqSet)


                dataReq.selfStatus.Implementation=slreq.analysis.Status.Container;
            else


            end
        end
    end

    methods(Static)
        function name=getName()
            name='Implementation';
        end
    end
end

function item=sumChildren(item,name)
    if(reqmgt('rmiFeature','CustomRollup'))

        if isa(item,"slreq.data.RequirementSet")
            customAttributes=item.CustomAttributeNames;
        elseif isa(item,"slreq.data.Requirement")
            customAttributes=item.getReqSet().CustomAttributeNames;
        end
        hasImplementationStatus=any(cellfun(@(x)strcmp(x,'ImplementationStatus'),customAttributes));

        if(hasImplementationStatus)
            children=item.children;
            for n=1:length(children)
                ch=children(n);
                item.addStatus(name,'total',ch.getStatus(name,'total'));
                item.addStatus(name,'justified',ch.getStatus(name,'justified'));
                item.addStatus(name,'implemented',ch.getStatus(name,'implemented'));
                item.addStatus(name,'partiallyImplemented',ch.getStatus(name,'partiallyImplemented'));
                item.addStatus(name,'justStarted',ch.getStatus(name,'justStarted'));
                item.addStatus(name,'almostDone',ch.getStatus(name,'almostDone'));
                item.addStatus(name,'none',ch.getStatus(name,'none'));
            end
            return;
        end
    end
    children=item.children;
    for n=1:length(children)
        ch=children(n);
        item.addStatus(name,'total',ch.getStatus(name,'total'));
        item.addStatus(name,'justified',ch.getStatus(name,'justified'));
        item.addStatus(name,'implemented',ch.getStatus(name,'implemented'));
        item.addStatus(name,'none',ch.getStatus(name,'none'));
    end
end
