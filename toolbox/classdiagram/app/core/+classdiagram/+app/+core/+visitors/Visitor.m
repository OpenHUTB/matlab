classdef Visitor<handle


    methods(Abstract)
        visitPackage(self,package);
        visitClass(self,class);
        visitMethod(self,method);
        visitProperty(self,property);
        visitEvent(self,event);
        visitEnum(self,enum);
        visitEnumLiteral(self,enumLiteral);
        visitRelationship(self,relationship);
        visitRelationshipEnd(self,relationshipEnd);
    end
end

