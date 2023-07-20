classdef GenerateIDVisitor<classdiagram.app.core.visitors.Visitor








    properties
id
    end

    methods
        function visitFolder(self,folder)
            self.id=classdiagram.app.core.utils.ObjectIDUtility.generateFolderID(folder.getName());
        end

        function visitProject(self,project)
            self.id=classdiagram.app.core.utils.ObjectIDUtility.generateProjectID(project.getName());
        end

        function visitPackage(self,package)
            self.id=classdiagram.app.core.utils.ObjectIDUtility.generatePackageID(package.getName());
        end

        function visitClass(self,class)
            self.id=classdiagram.app.core.utils.ObjectIDUtility.generateClassID(class.getName());
        end

        function visitMethod(self,method)
            self.id=classdiagram.app.core.utils.ObjectIDUtility.generateMethodID(method.getOwningClass().getName(),method.getName());
        end

        function visitProperty(self,property)
            self.id=classdiagram.app.core.utils.ObjectIDUtility.generatePropertyID(property.getOwningClass().getName(),property.getName());
        end

        function visitEvent(self,event)
            self.id=classdiagram.app.core.utils.ObjectIDUtility.generateEventID(event.getOwningClass().getName(),event.getName());
        end

        function visitEnum(self,enum)
            self.id=classdiagram.app.core.utils.ObjectIDUtility.generateEnumID(enum.getName());
        end

        function visitEnumLiteral(self,enumLiteral)
            self.id=classdiagram.app.core.utils.ObjectIDUtility.generateEnumLiteralID(enumLiteral.getOwningEnum().getName(),enumLiteral.getName());
        end

        function visitRelationship(self,relationship)
            srcClass=relationship.getSrcEnd().getParentClass();
            dstClass=relationship.getDstEnd().getParentClass();
            self.id=classdiagram.app.core.utils.ObjectIDUtility.generateRelationshipID(srcClass.getName(),dstClass.getName(),relationship.getRelationshipType());
        end

        function visitRelationshipEnd(self,relationshipEnd)
            self.id=classdiagram.app.core.utils.ObjectIDUtility.generateRelationshipEndID(relationshipEnd.getType(),relationshipEnd.getParentClass.getName(),relationshipEnd.getOppositeEndClass.getName(),relationshipEnd.getRelationshipType());
        end
    end
end

