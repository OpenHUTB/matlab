classdef QualifiedNameSequenceMerger<autosar.mm.util.SequenceMerger




    properties(SetAccess=private)
        ScopeQualifiedName;
    end
    methods(Access=protected,Static=true)

        function lutKey=getLUTKeyFromM3iObj(m3iObj)
            lutKey=autosar.api.Utils.getQualifiedName(m3iObj);
        end

        function shortName=getShortName(qualifiedName)
            [~,shortName]=autosar.utils.splitQualifiedName(qualifiedName);
        end
    end
    methods(Access=public)
        function this=QualifiedNameSequenceMerger(m3iModel,m3iModelScope,metaClassName)


            m3iSeq=autosar.mm.Model.findObjectByMetaClass(m3iModelScope,...
            eval([metaClassName,'.MetaClass']),1,0);
            this=this@autosar.mm.util.SequenceMerger(m3iModel,m3iSeq,metaClassName);

            if isa(m3iModelScope,'Simulink.metamodel.foundation.Domain')
                this.ScopeQualifiedName='';
            else
                this.ScopeQualifiedName=autosar.api.Utils.getQualifiedName(m3iModelScope);
            end
        end

        function isTrue=isWithinScope(this,qualifiedName)
            isTrue=contains(qualifiedName,this.ScopeQualifiedName);
        end

        function[m3iObj,action_taken]=mergeByQualifiedName(this,qualifiedName)
            assert(this.isWithinScope(qualifiedName),...
            sprintf("Qualified Name of object: %s is out of the original scope: %s",...
            qualifiedName,this.ScopeQualifiedName));
            [m3iObj,action_taken]=this.mergeByName(qualifiedName);
        end
    end
end


