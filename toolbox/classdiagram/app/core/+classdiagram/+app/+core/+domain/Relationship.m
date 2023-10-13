classdef Relationship<classdiagram.app.core.domain.BaseObject

    properties(Access=private)
        SrcEnd classdiagram.app.core.domain.RelationshipEnd;
        DstEnd classdiagram.app.core.domain.RelationshipEnd;
        RelationshipType string;
        IsStale=false;



        InheritanceHierarchy struct;
    end

    properties(Constant)
        ConstantType="Relationship";
    end

    methods
        function obj=Relationship(srcEnd,dstEnd,relationshipType,globalSettingsFcn)
            obj.Type=classdiagram.app.core.domain.Relationship.ConstantType;

            obj.RelationshipType=relationshipType;
            obj.SrcEnd=srcEnd;
            obj.DstEnd=dstEnd;
            obj.Name='';
            obj.Metadata=containers.Map;
            obj.GlobalSettingsFcn=globalSettingsFcn;
        end

        function isstale=getIsStale(self)
            isstale=self.IsStale;
        end

        function setIsStale(self,value)
            self.IsStale=value;
        end

        function inheritanceHierarchy=getInheritanceHierarchy(self)
            showDetails=self.GlobalSettingsFcn('ShowDetails');
            inheritanceHierarchy=self.InheritanceHierarchy;
            if showDetails&&~isempty(inheritanceHierarchy)
                inheritanceHierarchy.mixinsOnly=0;
            end
        end

        function setInheritanceHierarchy(self,value)
            self.InheritanceHierarchy=value;
        end

        function srcEnd=getSrcEnd(self)
            srcEnd=self.SrcEnd;
        end

        function dstEnd=getDstEnd(self)
            dstEnd=self.DstEnd;
        end

        function srcClass=getSrcClass(self)
            srcClass=self.SrcEnd.getParentClass;
        end

        function dstClass=getDstClass(self)
            dstClass=self.DstEnd.getParentClass;
        end

        function relationshipType=getRelationshipType(self)
            relationshipType=self.RelationshipType;
        end

        function rName=setRelationshipName(~,srcEnd,dstEnd,relationshipType)
            rName='';
            if(strcmpi(relationshipType,'INHERITANCE'))
                return;
            end
            srcClass=srcEnd.getParentClass().getNonQualifiedName();
            dstClass=dstEnd.getParentClass().getNonQualifiedName();
            rName=srcClass+" - "+dstClass;


        end

        function accept(self,visitor)
            visitor.visitRelationship(self);
        end
    end
end
