classdef RelationshipEnd<classdiagram.app.core.domain.BaseObject


    properties(Access=private)

        ParentClass classdiagram.app.core.domain.PackageElement;
        OppositeEndClass classdiagram.app.core.domain.PackageElement;
        RelationshipType string;

        Multiplicity;
        Label;
        Role;
    end

    properties(Constant)
        ConstantType="RelationshipEnd";
    end

    methods
        function obj=RelationshipEnd(parentClass,oppositeEndClass,relationshipType)
            obj.Type=classdiagram.app.core.domain.RelationshipEnd.ConstantType;
            obj.ParentClass=parentClass;
            obj.OppositeEndClass=oppositeEndClass;
            obj.RelationshipType=relationshipType;
            obj.Label='';
            obj.Multiplicity="";
            obj.Role="";
            obj.Name="";
            obj.Metadata=containers.Map;
        end

        function setParentClass(self,parentClass)
            self.ParentClass=parentClass;
        end

        function parentClass=getParentClass(self)
            parentClass=self.ParentClass;
        end

        function oppositeEndClass=getOppositeEndClass(self)
            oppositeEndClass=self.OppositeEndClass;
        end

        function relationshipType=getRelationshipType(self)
            relationshipType=self.RelationshipType;
        end

        function setMultiplicity(self,multiplicity)
            self.Multiplicity=multiplicity;
        end

        function multiplicity=getMultiplicity(self)
            multiplicity=self.Multiplicity;
        end

        function setLabel(self,label)
            self.Label=label;
        end

        function label=getLabel(self)
            label=self.Label;
        end

        function setRole(self,role)
            self.Role=role;
        end

        function role=getRole(self)
            role=self.Role;
        end

        function accept(self,visitor)
            visitor.visitRelationshipEnd(self);
        end
    end
end
