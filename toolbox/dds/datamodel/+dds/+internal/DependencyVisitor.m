classdef DependencyVisitor<dds.internal.GetFullNamesVisitor





    properties(Constant)
        TOPSYSCHILDCLASSNAMEMAP=containers.Map(...
        {'TypeLibraries',...
        'QosLibraries',...
        'DomainLibraries',...
        'DomainParticipantLibraries',...
        'ApplicationLibraries'},...
        {'dds.datamodel.types.TypeLibrary',...
        'dds.datamodel.qos.QosLibrary',...
        'dds.datamodel.domain.DomainLibrary',...
        'dds.datamodel.domainparticipant.DomainParticipantLibrary',...
        'dds.datamodel.application.ApplicationLibrary'});
    end

    properties
TypeLibraries
QosLibraries
DomainLibraries
DomainParticipantLibraries
ApplicationLibraries
    end

    methods
        function h=DependencyVisitor()
            h@dds.internal.GetFullNamesVisitor('::',false);
        end

        function reset(h)
            reset@dds.internal.GetFullNamesVisitor(h);
            h.TypeLibraries=digraph();
            h.QosLibraries=digraph();
            h.DomainLibraries=digraph();
            h.DomainParticipantLibraries=digraph();
            h.ApplicationLibraries=digraph();
        end

        function[depStruct,depStructUUID]=getDepedencies(h,varargin)
            function sortList=getSortedList(g)
                simpG=g.simplify;
                [~,sortedG]=simpG.toposort();
                sortList=sortedG.Nodes.Variables;
            end
            depStruct=struct('TypeLibraries',{{}},...
            'QosLibraries',{{}},...
            'DomainLibraries',{{}},...
            'DomainParticipantLibraries',{{}},...
            'ApplicationLibraries',{{}});
            mapList={'TypesMap',...
            'QosMap',...
            'DomainMap',...
            'DomainParticipantMap',...
            'ApplicationMap'};
            depStructUUID=depStruct;
            flds=fields(depStruct);
            for ii=1:numel(flds)
                depStruct.(flds{ii})=getSortedList(h.(flds{ii}));
                if~isempty(depStruct.(flds{ii}))
                    depStructUUID.(flds{ii})=cellfun(@(x)h.(mapList{ii})(x),depStruct.(flds{ii}),'UniformOutput',false);
                end
            end
        end


        function status=addToGraph(h,graphName,nodeName,depName)
            graph=h.(graphName);
            nodeList=graph.Nodes.Variables;
            if~isempty(nodeList)
                match=cellfun(@(x)isequal(nodeName,x),nodeList);
            end
            if isempty(nodeList)||~any(match)
                graph=graph.addnode(nodeName);
            end
            if~isempty(depName)
                graph=graph.addedge(depName,nodeName);
            end
            h.(graphName)=graph;
            status=true;
        end

        function[addClassName,containerClass]=getContainerClass(~,graphName)
            addClassName=~isequal(graphName,'TypeLibraries');
            if addClassName
                containerClass='dds.datamodel.system.System';
            else
                containerClass='dds.datamodel.types.TypeLibrary';
            end
        end

        function[status,fullName,depName,myLineage]=addDepToContainer(h,graphName,theObj)
            [addClassName,containerClass]=h.getContainerClass(graphName);
            if~isa(theObj.Container,containerClass)
                if h.ReverseMap.isKey(theObj.Container.UUID)
                    depName=h.ReverseMap(theObj.Container.UUID);
                else
                    depName=dds.internal.getFullNameUpto(theObj.Container,containerClass,h.TypeSep,addClassName);
                end
                [fullName,myLineage]=dds.internal.getFullNameUpto(theObj,containerClass,h.TypeSep,addClassName);
            else
                depName='';
                fullName=theObj.Name;
                myLineage={};
            end
            status=h.addToGraph(graphName,fullName,depName);
        end

        function status=addDep(h,graphName,fullName,depName,myLineage,depLineage)
            function adjusted=adjust(lineage)
                fliped=flip(lineage);
                adjusted=fliped;
                for ii=2:numel(adjusted)
                    adjusted{ii}=strjoin(fliped(1:ii),h.TypeSep);
                end
                adjusted=flip(adjusted);
            end
            status=h.addToGraph(graphName,fullName,depName);
            if~status
                return;
            end
            myLineage=adjust(myLineage);
            depLineage=adjust(depLineage);
            for i=2:numel(myLineage)
                if ismember(myLineage{i},depLineage)
                    return;
                end
                status=h.addToGraph(graphName,myLineage{i},depName);
                if~status
                    return;
                end
            end
        end

        function status=checkAndAddDimension(h,dimension,fullName,myLineage)
            status=true;
            if isempty(dimension)
                return;
            end
            status=h.checkAndAddLen(dimension.MaxLength,fullName,myLineage);
            if~status
                return;
            end
            status=h.checkAndAddLen(dimension.CurLength,fullName,myLineage);
        end

        function status=checkAndAddType(h,type,fullName,myLineage)
            status=h.checkAndAddDimension(type.Dimension,fullName,myLineage);
            if~status
                return;
            end
            if h.objHasProperty(type,'MaxLength')
                if~isempty(type.MaxLength)&&~isempty(type.MaxLength.ValueConst)
                    [depName,depLineage]=dds.internal.getFullNameUpto(type.MaxLength.ValueConst,'dds.datamodel.types.TypeLibrary',h.TypeSep);
                    status=h.addDep('TypeLibraries',fullName,depName,myLineage,depLineage);
                end
            end
        end

        function has=objHasProperty(~,obj,propertyName)
            has=any(cellfun(@(x)isequal(propertyName,x),properties(obj)));
        end

        function status=checkAndAddLen(h,seq,fullName,myLineage)
            status=true;
            for ii=1:seq.Size
                if~isempty(seq(ii).ValueConst)
                    [depName,depLineage]=dds.internal.getFullNameUpto(seq(ii).ValueConst,'dds.datamodel.types.TypeLibrary',h.TypeSep);
                    status=h.addDep('TypeLibraries',fullName,depName,myLineage,depLineage);
                    if~status
                        return;
                    end
                end
            end
        end


        function status=visitConst(h,theObj)
            status=visitConst@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                [status,fullName,~,myLineage]=h.addDepToContainer('TypeLibraries',theObj);
                if~status
                    return;
                end
                if~isempty(theObj.TypeRef)
                    [depName,depLineage]=dds.internal.getFullNameUpto(theObj.TypeRef,'dds.datamodel.types.TypeLibrary',h.TypeSep);
                else
                    depName='';
                    myLineage={};
                    depLineage={};
                end
                status=h.addDep('TypeLibraries',fullName,depName,myLineage,depLineage);
            end
        end

        function status=visitEnum(h,theObj)
            status=visitEnum@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                [status,fullName]=h.addDepToContainer('TypeLibraries',theObj);
                if~status
                    return;
                end
                status=h.addToGraph('TypeLibraries',fullName,'');
            end
        end

        function status=visitStruct(h,theObj)
            status=visitStruct@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                [status,fullName,~,myLineage]=h.addDepToContainer('TypeLibraries',theObj);
                if~status
                    return;
                end
                if~isempty(theObj.BaseRef)
                    [depBaseTypeName,depBaseTypeLineage]=dds.internal.getFullNameUpto(theObj.BaseRef,'dds.datamodel.types.TypeLibrary',h.TypeSep);
                    status=h.addDep('TypeLibraries',fullName,depBaseTypeName,myLineage,depBaseTypeLineage);
                    if~status
                        return;
                    end
                end
                status=h.addToGraph('TypeLibraries',fullName,'');
                if~status
                    return;
                end
                keys=theObj.Members.keys;
                for pIdx=1:theObj.Members.Size
                    member=theObj.Members{keys(pIdx)};
                    if~isempty(member.TypeRef)
                        [depMemTypeName,depMemTypeLineage]=dds.internal.getFullNameUpto(member.TypeRef,'dds.datamodel.types.TypeLibrary',h.TypeSep);
                        status=h.addDep('TypeLibraries',fullName,depMemTypeName,myLineage,depMemTypeLineage);
                        if~status
                            return;
                        end
...
...
...
...
...
...
...
...
...
                    else
                        status=h.checkAndAddType(member.Type,fullName,myLineage);
                        if~status
                            return;
                        end
                    end
                    status=h.checkAndAddDimension(member.Dimension,fullName,myLineage);
                    if~status
                        return;
                    end
                end
            end
        end

        function status=visitAlias(h,theObj)
            status=visitAlias@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                [status,fullName,~,myLineage]=h.addDepToContainer('TypeLibraries',theObj);
                if~status
                    return;
                end
                if~isempty(theObj.TypeRef)
                    [depName,depLineage]=dds.internal.getFullNameUpto(theObj.TypeRef,'dds.datamodel.types.TypeLibrary',h.TypeSep);
                    status=h.addDep('TypeLibraries',fullName,depName,myLineage,depLineage);
                    if~status
                        return;
                    end
                else
                    status=h.checkAndAddType(theObj.Type,fullName,myLineage);
                    if~status
                        return;
                    end
                end
                status=h.checkAndAddDimension(theObj.Dimension,fullName,myLineage);
            end
        end

        function status=visitElements(h,theObj)
            if~isa(theObj,'dds.datamodel.types.TypeLibrary')
                status=h.addDepToContainer('TypeLibraries',theObj);
                if~status
                    return;
                end
            end
            status=visitElements@dds.internal.GetFullNamesVisitor(h,theObj);
        end


        function status=addDepInfoForQos(h,theObj)
            [status,fullName,~,myLineage]=h.addDepToContainer('QosLibraries',theObj);
            if~status
                return;
            end
            if~isempty(theObj.Base)
                [depName,depLineage]=dds.internal.getFullNameUpto(theObj.Base,'dds.datamodel.system.System',h.TypeSep,true);
            else
                depName='';
                depLineage={};
            end
            status=h.addDep('QosLibraries',fullName,depName,myLineage,depLineage);
        end

        function status=visitDomainParticipantQos(h,theObj)
            status=visitDomainParticipantQos@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepInfoForQos(theObj);
            end
        end

        function status=visitPublisherQos(h,theObj)
            status=visitPublisherQos@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepInfoForQos(theObj);
            end
        end

        function status=visitSubscriberQos(h,theObj)
            status=visitSubscriberQos@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepInfoForQos(theObj);
            end
        end

        function status=visitTopicQos(h,theObj)
            status=visitTopicQos@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepInfoForQos(theObj);
            end
        end

        function status=visitDataReaderQos(h,theObj)
            status=visitDataReaderQos@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepInfoForQos(theObj);
            end
        end

        function status=visitDataWriterQos(h,theObj)
            status=visitDataWriterQos@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepInfoForQos(theObj);
            end
        end

        function status=visitQosProfile(h,theObj)
            status=visitQosProfile@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepInfoForQos(theObj);
            end
        end


        function status=visitRegisterType(h,theObj)
            status=visitRegisterType@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepToContainer('DomainLibraries',theObj);
            end
        end

        function status=visitTopic(h,theObj)
            status=visitTopic@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                [status,fullName]=h.addDepToContainer('DomainLibraries',theObj);
                if~status
                    return;
                end
                depName=dds.internal.getFullNameUpto(theObj.RegisterTypeRef,'dds.datamodel.system.System',h.TypeSep,true);
                status=h.addToGraph('DomainLibraries',fullName,depName);
            end
        end

        function status=visitDomain(h,theObj)
            status=visitDomain@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepToContainer('DomainLibraries',theObj);
            end
        end


        function status=visitDataReader(h,theObj)
            status=visitDataReader@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepToContainer('DomainParticipantLibraries',theObj);
            end
        end

        function status=visitDataWriter(h,theObj)
            status=visitDataWriter@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepToContainer('DomainParticipantLibraries',theObj);
            end
        end

        function status=visitSubscriber(h,theObj)
            status=visitSubscriber@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepToContainer('DomainParticipantLibraries',theObj);
            end
        end

        function status=visitPublisher(h,theObj)
            status=visitPublisher@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepToContainer('DomainParticipantLibraries',theObj);
            end
        end

        function status=visitDomainParticipant(h,theObj)
            status=visitDomainParticipant@dds.internal.GetFullNamesVisitor(h,theObj);
            if status
                status=h.addDepToContainer('DomainParticipantLibraries',theObj);
            end
        end
    end
end
