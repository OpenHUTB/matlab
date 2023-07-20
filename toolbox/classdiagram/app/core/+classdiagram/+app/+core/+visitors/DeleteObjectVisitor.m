classdef DeleteObjectVisitor<classdiagram.app.core.visitors.Visitor



    properties(Constant,Access=private)
        EmptyUUID='';
    end

    properties(Access=private)
        factory;
    end

    methods(Access=private)
        function resetDiagramElementUUID(self,object)
            if~isempty(object)
                object.setDiagramElementUUID(self.EmptyUUID);
            end
        end

        function deleteObjects(self,objects)
            for iobj=1:numel(objects)
                obj=objects(iobj);
                obj.accept(self);
            end
        end
    end

    methods
        function obj=DeleteObjectVisitor(factory)
            obj.factory=factory;
        end

        function visitPackage(self,package)
            self.resetDiagramElementUUID(package);
            self.factory.updatePackageInDiagramCache(package,false);
        end

        function visitClass(self,class)
            if(isempty(class)||isempty(self.factory))
                return;
            end


            self.deleteObjects(self.factory.getMethods(class));


            self.deleteObjects(self.factory.getProperties(class));


            self.deleteObjects(self.factory.getEvents(class));

            relationships=self.factory.getDiagramedRelationships(class);
            self.deleteObjects(relationships);

            self.resetDiagramElementUUID(class);
            self.factory.updatePackageInDiagramCache(class,false);
        end

        function visitMethod(self,method)
            self.resetDiagramElementUUID(method);
        end

        function visitProperty(self,property)
            self.resetDiagramElementUUID(property);
        end

        function visitEvent(self,event)
            self.resetDiagramElementUUID(event);
        end

        function visitEnum(self,enum)
            if(isempty(enum)||isempty(self.factory))
                return;
            end


            self.deleteObjects(self.factory.getEnumLiterals(enum));


            self.deleteObjects(self.factory.getMethods(enum));


            self.deleteObjects(self.factory.getProperties(enum));


            self.deleteObjects(self.factory.getEvents(enum));

            relationships=self.factory.getDiagramedRelationships(enum);
            self.deleteObjects(relationships);
            self.resetDiagramElementUUID(enum);
            self.factory.updatePackageInDiagramCache(enum,false);
        end

        function visitEnumLiteral(self,enumLiteral)
            self.resetDiagramElementUUID(enumLiteral);
        end

        function visitRelationship(self,relationship)
            if(isempty(relationship))
                return;
            end


            if(~isempty(relationship.getSrcEnd()))
                relationship.getSrcEnd().accept(self);
            end

            if(~isempty(relationship.getDstEnd()))
                relationship.getDstEnd().accept(self);
            end


            self.factory.removeFromRelationshipMaps(relationship);

            self.resetDiagramElementUUID(relationship);
        end

        function visitRelationshipEnd(self,relationshipEnd)
            self.resetDiagramElementUUID(relationshipEnd);
        end
    end
end

