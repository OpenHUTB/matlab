classdef GetFullNamesVisitor<dds.internal.BaseVisitor












    properties
TypesMap
StructsMap
AllowConflicts
IgnoreModuleConflicts
ConflictsInTypesMap
TypeSep
VisitOnlyTypes
DomainMap
DomainParticipantMap
QosMap
ReverseMap
    end

    methods
        function h=GetFullNamesVisitor(varargin)
            h@dds.internal.BaseVisitor();
            h.AllowConflicts=false;
            h.IgnoreModuleConflicts=false;
            if nargin>0
                h.TypeSep=varargin{1};
            else
                h.TypeSep='_';
            end
            if nargin>1
                h.VisitOnlyTypes=varargin{2};
            else
                h.VisitOnlyTypes=true;
            end
            h.reset();
        end

        function reset(h)
            reset@dds.internal.BaseVisitor(h);
            h.TypesMap=containers.Map();
            h.StructsMap=containers.Map();
            h.ConflictsInTypesMap=containers.Map();
            h.DomainMap=containers.Map();
            h.DomainParticipantMap=containers.Map();
            h.QosMap=containers.Map();
            h.ReverseMap=containers.Map();
        end

        function addObject(h,theObj,upToClass,mapName)
            if nargin<3
                upToClass='dds.datamodel.types.TypeLibrary';
                mapName='TypesMap';
            end
            addClassName=~isequal(mapName,'TypesMap');
            fullName=dds.internal.getFullNameUpto(theObj,upToClass,h.TypeSep,addClassName);
            uuid=theObj.UUID;
            if h.(mapName).isKey(fullName)&&~isequal(uuid,h.(mapName)(fullName))
                if h.AllowConflicts


                    if isa(theObj,'dds.datamodel.types.Module')
                        if~h.IgnoreModuleConflicts
                            h.addToConflicts(fullName,uuid);
                        end
                    else
                        h.addToConflicts(fullName,uuid);
                    end
                else
                    error(message('dds:io:AnotherSimulinkObjectWithSameName',fullName));
                end
            end



            if isequal(mapName,'TypesMap')
                if isa(theObj,'dds.datamodel.types.Struct')
                    h.StructsMap(fullName)=uuid;
                end
            end
            h.(mapName)(fullName)=uuid;
            h.ReverseMap(uuid)=fullName;
        end

        function addToConflicts(h,fullName,uuid)
            if h.ConflictsInTypesMap.isKey(fullName)

                h.ConflictsInTypesMap(fullName)=[h.ConflictsInTypesMap(fullName),uuid];
            else
                h.ConflictsInTypesMap(fullName)={h.TypesMap(fullName),uuid};
            end
        end

        function status=visitSystem(h,syselem)

            if(h.VisitOnlyTypes)
                status=h.visitTypeLibraries(syselem);
            else
                status=visitSystem@dds.internal.BaseVisitor(h,syselem);
            end
        end


        function status=visitConst(h,theObj)
            status=visitConst@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj);
            end
        end

        function status=visitEnum(h,theObj)
            status=visitEnum@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj);
            end
        end

        function status=visitStruct(h,theObj)
            status=visitStruct@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj);
            end
        end

        function status=visitAlias(h,theObj)
            status=visitAlias@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj);
            end
        end

        function status=visitModule(h,theObj)
            status=visitModule@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj);
            end
        end


        function status=visitDomainParticipantQos(h,theObj)
            status=visitDomainParticipantQos@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','QosMap');
            end
        end

        function status=visitPublisherQos(h,theObj)
            status=visitPublisherQos@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','QosMap');
            end
        end

        function status=visitSubscriberQos(h,theObj)
            status=visitSubscriberQos@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','QosMap');
            end
        end

        function status=visitTopicQos(h,theObj)
            status=visitTopicQos@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','QosMap');
            end
        end

        function status=visitDataReaderQos(h,theObj)
            status=visitDataReaderQos@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','QosMap');
            end
        end

        function status=visitDataWriterQos(h,theObj)
            status=visitDataWriterQos@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','QosMap');
            end
        end

        function status=visitQosProfile(h,theObj)
            status=visitQosProfile@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','QosMap');
            end
        end

        function status=visitQosLibrary(h,theObj)
            status=visitQosLibrary@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','QosMap');
            end
        end



        function status=visitRegisterType(h,theObj)
            status=visitRegisterType@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','DomainMap');
            end
        end

        function status=visitTopic(h,theObj)
            status=visitTopic@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','DomainMap');
            end
        end

        function status=visitDomain(h,theObj)
            status=visitDomain@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','DomainMap');
            end
        end

        function status=visitDomainLibrary(h,theObj)
            status=visitDomainLibrary@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','DomainMap');
            end
        end


        function status=visitDataReader(h,theObj)
            status=visitDataReader@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','DomainParticipantMap');
            end
        end

        function status=visitDataWriter(h,theObj)
            status=visitDataWriter@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','DomainParticipantMap');
            end
        end

        function status=visitSubscriber(h,theObj)
            status=visitSubscriber@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','DomainParticipantMap');
            end
        end

        function status=visitPublisher(h,theObj)
            status=visitPublisher@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','DomainParticipantMap');
            end
        end

        function status=visitDomainParticipant(h,theObj)
            status=visitDomainParticipant@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','DomainParticipantMap');
            end
        end

        function status=visitDomainParticipantLibrary(h,theObj)
            status=visitDomainParticipantLibrary@dds.internal.BaseVisitor(h,theObj);
            if status
                h.addObject(theObj,'dds.datamodel.system.System','DomainParticipantMap');
            end
        end
    end
end

