classdef ClassDiagramConnectionHandler

    properties(Access=private)
        App;
        Syntax;
        DeletionVisitor classdiagram.app.core.visitors.DeleteObjectVisitor;
    end

    methods
        function obj=ClassDiagramConnectionHandler(app)
            obj.App=app;
            obj.Syntax=app.syntax;
            obj.DeletionVisitor=classdiagram.app.core.visitors.DeleteObjectVisitor(app.getClassDiagramFactory);
        end

        function handleConnections(obj,operations)


            names=obj.App.getAllDiagramEntityNames;
            if isempty(names)
                return;
            end

            showAssociations=obj.App.getGlobalSetting('ShowAssociations');
            [relationships,toRemove,toUpdate]...
            =obj.App.getClassDiagramFactory.getRelationships(names,showAssociations);

            obj.createConnections(operations,relationships);
            obj.removeConnections(operations,toRemove);
            obj.updateElementFlags(operations,toUpdate);
        end
    end

    methods(Access=private)
        function createConnections(obj,operations,relationships)



            for irelationship=1:numel(relationships)
                relationship=relationships(irelationship);
                if(isempty(relationship.getDiagramElementUUID()))
                    if(~obj.doRelationshipEndDiagramElementsExist(relationship))
                        continue;
                    end

                    if(isempty(relationship.getSrcEnd().getDiagramElementUUID()))
                        srcPort=obj.createPort(operations,relationship.getSrcEnd());

                    else
                        srcPort=obj.Syntax.findElement(relationship.getSrcEnd().getDiagramElementUUID());

                    end
                    if(isempty(relationship.getDstEnd().getDiagramElementUUID()))
                        dstPort=obj.createPort(operations,relationship.getDstEnd());

                    else
                        dstPort=obj.Syntax.findElement(relationship.getDstEnd().getDiagramElementUUID());

                    end



                    obj.createConnection(operations,relationship,srcPort,dstPort);
                end
                obj.updateConnectionHierarchy(operations,relationship);
            end
        end

        function connection=createConnection(obj,operations,relationship,srcPort,dstPort)
            connection=[];
            if isempty(srcPort)||isempty(dstPort)
                return;
            end

            connection=operations.createConnection(srcPort,dstPort);
            operations.setType(connection,classdiagram.app.core.domain.ClassDiagramTypes.typeMap(relationship.getRelationshipType()));
            operations.setTitle(connection,relationship.getName());
            operations.setTag(connection,...
            relationship.getSrcClass.getName+"->"+...
            relationship.getDstClass.getName);
            operations.setAttributeValue(connection,'ObjectID',relationship.getObjectID());
            relationship.setDiagramElementUUID(connection.uuid);

        end

        function port=createPort(obj,operations,relationshipEnd)
            port=[];
            factory=obj.App.getClassDiagramFactory;

            function classElement=getClassElement(class)
                classElement=obj.Syntax.findElement(class.getDiagramElementUUID());
            end
            class=relationshipEnd.getParentClass();
            classElement=getClassElement(class);


            if~classElement.isValid
                classElement=getClassElement(factory.getClass(class.getName));
                if~classElement.isValid
                    obj.App.notifier.processNotification(...
                    classdiagram.app.core.notifications.notifications.ErrMInvalidDiagramObject(...
                    class.getName));
                    return;
                end
            end
            port=operations.createPort(classElement);
            operations.setType(port,classdiagram.app.core.domain.ClassDiagramTypes.typeMap(relationshipEnd.getType()));
            operations.setAttributeValue(port,"Label",relationshipEnd.getLabel());
            operations.setAttributeValue(port,"Multiplicity",relationshipEnd.getMultiplicity());
            operations.setAttributeValue(port,"Role",relationshipEnd.getRole());
            operations.setAttributeValue(port,"ObjectID",string(relationshipEnd.getObjectID()));
            relationshipEnd.setDiagramElementUUID(port.uuid);

        end

        function elementsExists=doRelationshipEndDiagramElementsExist(~,relationship)


            srcClass=relationship.getSrcEnd().getParentClass();
            dstClass=relationship.getDstEnd().getParentClass();
            elementsExists=~isempty(srcClass.getDiagramElementUUID())&&~isempty(dstClass.getDiagramElementUUID());
        end

        function removeConnections(obj,operations,toRemove)
            for iconn=1:numel(toRemove)
                conn=toRemove(iconn);
                uuid=conn.getDiagramElementUUID;
                if isempty(uuid)
                    continue;
                end
                diagramElement=obj.Syntax.findElement(uuid);
                conn.accept(obj.DeletionVisitor);
                if isempty(diagramElement)||~diagramElement.isValid
                    continue;
                end
                operations.destroy(diagramElement,false);
            end
        end

        function updateConnectionHierarchy(obj,operations,relationship)
            connection=obj.Syntax.findElement(relationship.getDiagramElementUUID());
            hierarchy=relationship.getInheritanceHierarchy();
            if~isempty(hierarchy)
                hierarchyPath=join(hierarchy.path,',');
                operations.setAttributeValue(connection,'InheritanceHierarchy',hierarchyPath{:});
                operations.setAttributeValue(connection,'InheritanceHierarchyMixinsOnly',hierarchy.mixinsOnly);
            end
        end
        function updateElementFlags(obj,operations,toUpdate)
            factory=obj.App.getClassDiagramFactory;
            for iclassName=1:numel(toUpdate)
                className=toUpdate(iclassName);
                class=factory.getPackageElement(className{1});
                if isempty(class)||isempty(class.getDiagramElementUUID)
                    continue;
                end
                diagramElement=obj.Syntax.findElement(class.getDiagramElementUUID);
                if isempty(diagramElement)||~diagramElement.isValid
                    continue;
                end
                operations.setAttributeValue(diagramElement,"InheritanceFlags",int8(class.getInheritanceFlags));
            end
        end
    end
end
