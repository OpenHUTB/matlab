classdef BaseVisitor<handle







    methods
        function h=BaseVisitor()
        end
        function reset(~)
        end
        function status=visitConst(~,theObj)
            status=isa(theObj,'dds.datamodel.types.Const');
        end

        function status=visitEnum(~,theObj)
            status=isa(theObj,'dds.datamodel.types.Enum');
        end

        function status=visitStruct(~,theObj)
            status=isa(theObj,'dds.datamodel.types.Struct');
        end

        function status=visitModule(h,theObj)
            status=isa(theObj,'dds.datamodel.types.Module');
            if isprop(theObj,'Elements')
                status=h.visitElements(theObj);
            end
        end

        function status=visitAlias(~,theObj)
            status=isa(theObj,'dds.datamodel.types.Alias');
        end

        function status=visitModel(h,mf0Model)



            status=false;
            if isempty(mf0Model)||~isa(mf0Model,'mf.zero.Model')

                return;
            end
            tpe=mf0Model.topLevelElements;
            if isempty(tpe)
                return;
            end
            for i=1:numel(tpe)
                elem=tpe(i);
                switch(class(elem))
                case 'dds.datamodel.system.System'
                    status=h.visitSystem(elem);
                    if~status
                        break;
                    end
                end
            end
        end

        function status=visitSystem(h,syselem)
            status=h.visitTypeLibraries(syselem);
            if~status
                return;
            end
            status=h.visitQosLibraries(syselem);
            if~status
                return;
            end
            status=h.visitDomainLibraries(syselem);
            if~status
                return;
            end
            status=h.visitDomainParticipantLibraries(syselem);
            if~status
                return;
            end
            status=h.visitApplicationLibraries(syselem);
        end

        function status=visitSeqToAcceptVisitor(h,elem,seqName)
            status=true;
            theSeq=elem.(seqName);
            for i=1:theSeq.Size
                elem=theSeq(i);
                if ismethod(elem,'acceptVisitor')
                    status=elem.acceptVisitor(h);
                    if~status
                        break;
                    end
                end
            end
        end

        function status=visitMapToAcceptVisitor(h,elem,mapName)
            status=true;
            theMap=elem.(mapName);
            keys=theMap.keys;
            for i=1:theMap.Size
                elem=theMap{keys{i}};
                if ismethod(elem,'acceptVisitor')
                    status=elem.acceptVisitor(h);
                    if~status
                        break;
                    end
                end
            end
        end

        function status=visitTypeLibraries(h,syselem)
            status=true;
            for i=1:syselem.TypeLibraries.Size
                elem=syselem.TypeLibraries(i);
                status=h.visitElements(elem);
                if~status
                    break;
                end
            end
        end

        function status=visitElements(h,typeLib)

            status=h.visitMapToAcceptVisitor(typeLib,'Elements');
        end

        function status=visitQosLibraries(h,syselem)
            status=true;
            keys=syselem.QosLibraries.keys;
            for i=1:syselem.QosLibraries.Size
                elem=syselem.QosLibraries{keys{i}};
                status=h.visitQosLibrary(elem);
                if~status
                    break;
                end
            end
        end

        function status=visitQosLibrary(h,elem)
            status=h.visitMapToAcceptVisitor(elem,'QosProfiles');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(elem,'TopicQoses');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(elem,'DataWriterQoses');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(elem,'DataReaderQoses');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(elem,'PublisherQoses');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(elem,'SubscriberQoses');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(elem,'DomainParticipantQoses');
            if~status
                return;
            end
        end

        function status=visitDomainParticipantQos(~,elem)
            status=isa(elem,'dds.datamodel.qos.DomainParticipantQos');
        end

        function status=visitPublisherQos(~,elem)
            status=isa(elem,'dds.datamodel.qos.PublisherQos');
        end

        function status=visitSubscriberQos(~,elem)
            status=isa(elem,'dds.datamodel.qos.SubscriberQos');
        end

        function status=visitTopicQos(~,elem)
            status=isa(elem,'dds.datamodel.qos.TopicQos');
        end

        function status=visitDataReaderQos(~,elem)
            status=isa(elem,'dds.datamodel.qos.DataReaderQos');
        end

        function status=visitDataWriterQos(~,elem)
            status=isa(elem,'dds.datamodel.qos.DataWriterQos');
        end

        function status=visitQosProfile(h,elem)
            status=isa(elem,'dds.datamodel.qos.QosProfile');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(elem,'TopicQoses');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(elem,'DataWriterQoses');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(elem,'DataReaderQoses');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(elem,'PublisherQoses');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(elem,'SubscriberQoses');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(elem,'DomainParticipantQoses');
        end

        function status=visitDomainLibraries(h,syselem)
            status=true;
            keys=syselem.DomainLibraries.keys;
            for i=1:syselem.DomainLibraries.Size
                elem=syselem.DomainLibraries{keys{i}};
                status=h.visitDomainLibrary(elem);
                if~status
                    break;
                end
            end
        end

        function status=visitDomainLibrary(h,domainLib)

            status=h.visitMapToAcceptVisitor(domainLib,'Domains');
        end

        function status=visitRegisterType(~,theObj)
            status=isa(theObj,'dds.datamodel.domain.RegisterType');
        end

        function status=visitTopic(~,theObj)
            status=isa(theObj,'dds.datamodel.domain.Topic');
        end

        function status=visitDomain(h,theObj)
            status=isa(theObj,'dds.datamodel.domain.Domain');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(theObj,'RegisterTypes');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(theObj,'Topics');
        end

        function status=visitDomainParticipantLibraries(h,syselem)
            status=true;
            keys=syselem.DomainParticipantLibraries.keys;
            for i=1:numel(keys)
                elem=syselem.DomainParticipantLibraries{keys{i}};
                status=h.visitDomainParticipantLibrary(elem);
                if~status
                    break;
                end
            end
        end

        function status=visitDomainParticipantLibrary(h,domainParticipant)

            status=h.visitMapToAcceptVisitor(domainParticipant,'DomainParticipants');
        end

        function status=visitDataReader(~,theObj)
            status=isa(theObj,'dds.datamodel.domainparticipant.DataReader');
        end

        function status=visitDataWriter(~,theObj)
            status=isa(theObj,'dds.datamodel.domainparticipant.DataWriter');
        end

        function status=visitSubscriber(h,theObj)
            status=isa(theObj,'dds.datamodel.domainparticipant.Subscriber');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(theObj,'DataReaders');
        end

        function status=visitPublisher(h,theObj)
            status=isa(theObj,'dds.datamodel.domainparticipant.Publisher');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(theObj,'DataWriters');
        end

        function status=visitDomainParticipant(h,theObj)
            status=isa(theObj,'dds.datamodel.domainparticipant.DomainParticipant');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(theObj,'Publishers');
            if~status
                return;
            end
            status=h.visitMapToAcceptVisitor(theObj,'Subscribers');
        end

        function status=visitApplicationLibraries(~,~)

            status=true;
        end
    end
end
